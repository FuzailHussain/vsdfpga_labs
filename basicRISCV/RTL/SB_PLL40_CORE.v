module SB_PLL40_CORE 
(
    input       REFERENCECLK,
    input       RESETB,
    input       BYPASS,
    output      PLLOUTCORE
);
    parameter FEEDBACK_PATH = "SIMPLE";
    parameter PLLOUT_SELECT = "GENCLK";
    parameter DIVR = 4'b0000;
    parameter DIVF = 7'b0000000;
    parameter DIVQ = 3'b000;
    parameter FILTER_RANGE = 3'b001;
endmodule