module I2C_master_standard (
    input         clk,
    input         rst_n,
    input         wr_en,
    input         r_en,
    input  [7:0]  addr_offset,
    input  [31:0] data_in,
    output reg [31:0] data_out,
    output reg    scl,
    inout         sda
);

    // ---------------------------------
    // Registers
    // ---------------------------------
    reg        start_enable;
    reg [23:0]  clk_div;
    reg [6:0]  slave_addr;
    reg [31:0]  data_to_send;
    reg [7:0]  data_received;
    reg [1:0]  status;
    reg        mode;          // 0 = TX, 1 = RX

    reg [23:0]  clk_count;
    reg [5:0]  bit_index;

    // SDA open-drain control
    reg sda_drive_low;
    assign sda = sda_drive_low ? 1'b0 : 1'bz;

    reg scl_drive_low;
    assign scl = scl_drive_low ? 1'b0 : 1'bz;
    // ---------------------------------
    // Register interface
    // ---------------------------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            start_enable <= 1'b0;
            clk_div      <= 24'd1;
            slave_addr   <= 7'd0;
            data_to_send <= 32'd0;
            data_received <= 8'd0;
            status       <= 2'd0;
            mode         <= 1'b0;
            data_out     <= 32'd0;
        end else begin
            if (wr_en) begin
                case (addr_offset)
                    8'h00: start_enable <= |data_in;
                    8'h04:  clk_div      <= data_in[7:0];
			    //  clk_div <= 24'hbbbbbb;	
                    8'h08: slave_addr   <= data_in[6:0];
                    8'h0C: data_to_send <= data_in[31:0];
                    8'h18: mode         <= data_in[0];
                    default: ;
                endcase
            end
        end
    end

    always @(*) begin
        if (r_en) begin
            case (addr_offset)
                8'h00: data_out = start_enable;
                8'h04: data_out = clk_div;
                8'h08: data_out = {25'd0, slave_addr};
                8'h10: data_out = {24'd0, data_received};
                8'h14: data_out = status;
                8'h18: data_out = {31'd0, mode};
                default: data_out = 32'd0;
            endcase
        end else begin
            data_out = 32'd0;
        end
        
    end

    // ---------------------------------
    // SCL clock divider
    // ---------------------------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            clk_count <= 24'd0;
            scl_drive_low <= 1'b0;
        end else if (!start_enable) begin
            scl_drive_low <= 1'b0; // Idle state of SCL is high
        end else if (clk_div <= 1) begin
            scl_drive_low <= ~clk;
        end else begin
            if (clk_count == (clk_div >> 1) - 1) begin
                clk_count <= 24'd0;
                scl_drive_low <= ~scl_drive_low; // Toggle SCL
            end else begin
                clk_count <= clk_count + 1'b1;
            end
        end
    end

    // ---------------------------------
    // I2C transmit / receive (simplified)
    // ---------------------------------
    always @(posedge scl or negedge rst_n) begin
        if (!rst_n) begin
            bit_index     <= 6'd0;
            sda_drive_low <= 1'b0;
            data_received <= 8'd0;
        end else begin

            if (bit_index == 0) begin
                status <= 2'b00; // BUSY
            end
            // Address + R/W bit
            if (bit_index < 7) begin
                sda_drive_low <= ~slave_addr[6 - bit_index];
                bit_index <= bit_index + 1;
            end else if (bit_index == 7) begin
                sda_drive_low <= ~mode; // R/W bit
                bit_index <= bit_index + 1;
            end

            // ACK bit
            else if (bit_index == 8) begin
                sda_drive_low <= 1'b0; // release SDA
                bit_index <= bit_index + 1;
            end else if (bit_index == 9) begin
                if (sda == 1'b0) begin
                    status[1:0] <= 2'b10;
                    bit_index <= bit_index + 1;
                end else status[1:0] <= 2'b11;
            end

            // Data phase
            else if (bit_index < 42 && mode == 1'b0) begin
                sda_drive_low <= ~data_to_send[41 - bit_index];
                bit_index <= bit_index + 1;
            end else if (bit_index < 42 && mode == 1'b1) begin
                data_received[15 - bit_index] <= sda;
                bit_index <= bit_index + 1;
            end

            // Done
            else begin
                sda_drive_low <= 1'b0;
                bit_index <= 6'd0;
                status <= 2'b01; // done
                start_enable <= 1'b0; // auto-clear start
            end
        end
    end

endmodule
