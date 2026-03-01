`timescale 1ns/1ns

module bench();
   reg CLK;
   reg RESET = 0; 
   wire [4:0] LEDS;
   reg  RXD = 1'b0;
   wire TXD;

   wire scl;
   wire sda;


   SOC uut(
     .CLK(CLK),
     .RESET(RESET),
     .LEDS(LEDS),
     .RXD(RXD),
     .TXD(TXD),
     .scl(scl),
     .sda(sda)
   );

   reg[4:0] prev_LEDS = 0;

   initial begin
      $dumpfile("wave.vcd");
      $dumpvars(0, bench);
   end

   initial begin
      CLK = 0;
	   RXD = 0;
      RESET = 1;
      #100;
      RESET = 0;
      end

      always #5 CLK = ~CLK;

      initial begin
         #100000;
         $stop;
      end
endmodule   
   