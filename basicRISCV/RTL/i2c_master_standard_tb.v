`timescale 1ns/1ps

module tb_I2C_master_standard;

    // ----------------------------------
    // TB signals
    // ----------------------------------
    reg         clk;
    reg         rst_n;
    reg         wr_en;
    reg         r_en;
    reg [7:0]   addr_offset;
    reg [31:0]  data_in;
    wire [31:0] data_out;
    wire        scl;
    wire        sda;

    // Slave-side SDA drive (open drain)
    reg sda_slave_drive;

    // Open-drain behavior
    assign sda = (sda_slave_drive) ? 1'b0 : 1'bz;

    // ----------------------------------
    // DUT
    // ----------------------------------
    I2C_master_standard dut (
        .clk(clk),
        .rst_n(rst_n),
        .wr_en(wr_en),
        .r_en(r_en),
        .addr_offset(addr_offset),
        .data_in(data_in),
        .data_out(data_out),
        .scl(scl),
        .sda(sda)
    );

    // ----------------------------------
    // Clock generation (50 MHz)
    // ----------------------------------
    initial clk = 0;
    always #10 clk = ~clk;

    // ----------------------------------
    // Register write task
    // ----------------------------------
    task reg_write(input [7:0] addr, input [31:0] data);
        begin
            @(posedge clk);
            wr_en     <= 1'b1;
            r_en      <= 1'b0;
            addr_offset<= addr;
            data_in    <= data;
            // @(posedge clk);
            // wr          <= 1'b0;
            // addr_offset<= 8'h00;
            // data_in    <= 32'h0;
        end
    endtask

    // ----------------------------------
    // Register read task
    // ----------------------------------
    task reg_read(input [7:0] addr);
        begin
            @(posedge clk);
            wr_en     <= 1'b0;
            r_en      <= 1'b1;
            addr_offset<= addr;
            @(posedge clk);
            $display("[%0t] READ  addr 0x%02h -> 0x%08h",
                     $time, addr, data_out);
        end
    endtask

    // ----------------------------------
    // Very simple I2C slave ACK model
    // ----------------------------------
    // Pull SDA low during ACK bit (bit_index == 8)
    always @(posedge scl) begin
        if (dut.bit_index == 8)
            sda_slave_drive <= 1'b1; // ACK
        else
            sda_slave_drive <= 1'b0;
    end

    // ----------------------------------
    // Test sequence
    // ----------------------------------
    initial begin
        $display("====================================");
        $display("   I2C MASTER STANDARD TB START");
        $display("====================================");
        $dumpfile("i2c_master_standard.vcd");
        $dumpvars(0, tb_I2C_master_standard);

        // Init
        wr_en = 0;
        r_en = 0;
        addr_offset = 0;
        data_in = 0;
        sda_slave_drive = 0;
        rst_n = 0;

        // Reset
        #100;
        rst_n = 1;

        // -----------------------------
        // Program registers
        // -----------------------------
        wr_en = 1;
        reg_write(8'h04, 32'd2);   // clk_div
        reg_write(8'h08, 32'h55);   // slave address
        reg_write(8'h0C, 32'hA6);   // data to send
        reg_write(8'h18, 32'd0);    // mode = transmit
        reg_write(8'h00, 32'd1);    // start_enable

        #40;
        wr_en = 0; // Stop writing registers
        // Let I2C activity run
        #3000;

        // -----------------------------
        // Readback registers
        // -----------------------------
        r_en = 1;
        reg_read(8'h00);
        reg_read(8'h04);
        reg_read(8'h08);
        reg_read(8'h0C);
        reg_read(8'h10);
        reg_read(8'h14);
        reg_read(8'h18);

        #500;
        $display("====================================");
        $display("   I2C MASTER STANDARD TB END");
        $display("====================================");
        $stop;
    end

endmodule
