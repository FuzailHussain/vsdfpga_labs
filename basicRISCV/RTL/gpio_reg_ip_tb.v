`timescale 1ns/1ps

module tb_gpio_reg_ip;
  reg en;
  reg clk;
  reg wr;
  reg [7:0] addr_offset;
  reg [31:0] data_in;
  wire [31:0] data_out;

  GPIO_register_ip dut (
    .en(en),
    .clk(clk),
    .wr(wr),
    .addr_offset(addr_offset),
    .data_in(data_in),
    .data_out(data_out)
  );

  always #5 clk = ~clk;

  initial begin
    $dumpfile("gpio_reg_ip.vcd");
    $dumpvars(0, tb_gpio_reg_ip);

    en = 1;
    clk = 0;
    wr = 0;

    addr_offset = 0;

    #10;
    addr_offset = 32'h4; 

    #10;
    addr_offset = 32'h8; 

    #10;
    wr = 1;
    addr_offset = 32'h0; // Set address offset to 0x0 (data register)
    data_in = 32'hA5A5A5A5;
    
    #10;
    wr = 1;
    addr_offset = 32'h4; // Set address offset to 0x4 (direction register)
    data_in = 32'hFFFFFFF0; // Set all pins as output except the last 4

    #10
    wr = 0;
    addr_offset = 32'h0; // Set address offset to 0x0 (data register)

    #10
    addr_offset = 32'h4; // Set address offset to 0x4 (direction register)

    #10
    addr_offset = 32'h8; // Set address offset to 0x8 (read register)


    #20;
    $finish;
  end

endmodule