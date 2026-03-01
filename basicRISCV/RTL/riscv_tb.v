`timescale 1ns/1ns

module bench();
   reg CLK;
   reg RESET = 0; 
   wire [4:0] LEDS;
   reg  RXD = 1'b0;
   wire TXD;

   SOC uut(
     .CLK(CLK),
     .RESET(RESET),
     .LEDS(LEDS),
     .RXD(RXD),
     .TXD(TXD)
   );

   reg[4:0] prev_LEDS = 0;
   initial begin
      CLK = 0;
	   RXD = 0;
      RESET = 1;
      #100;
      RESET = 0;
      end

      always #5 CLK = ~CLK;

      initial begin
         #52000;
         $stop;
      end
endmodule   
   