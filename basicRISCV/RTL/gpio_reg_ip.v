module GPIO_register_ip (
    input en,
    input clk,
    input wr,
    input [7:0] addr_offset,
    input [31:0] data_in,
    output reg [31:0] data_out);

reg [31:0] data;
reg [31:0] dir;
reg [31:0] gpio_in = 32'h0;
reg [31:0] gpio_out;

initial
    begin
      $display("Hello, World");
    //   $monitor("Time=%0t | data_in=%b, data_out=%b, clk=%b, en=%b, wr=%b", $time, data_in, data_out, clk, en, wr);
    end


always @ (posedge clk) begin
    if (en) begin
        if (wr) begin
            case (addr_offset)
                8'h00: data <= data_in; // Write to GPIO Data Register
                8'h04: dir <= data_in; // Write to GPIO Direction Register
                default: ; // Do nothing for other addresses
            endcase
        end else begin
            case (addr_offset)
                8'h00: data_out <= data; // Read from GPIO Data Register
                8'h04: data_out <= dir; // Read from GPIO Direction Register
                8'h08: data_out <= (data & dir)|(gpio_in & ~dir); // Read from GPIO Input Register (masked by direction)
                default: ; // Default read value
            endcase
        end
     gpio_out <= data & dir;
    end
end
endmodule

