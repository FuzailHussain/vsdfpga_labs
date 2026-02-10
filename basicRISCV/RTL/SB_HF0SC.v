module SB_HFOSC (
    input       CLKHFEN,
    input       CLKHFPU,
    output reg  CLKHF
);
    parameter CLKHF_DIV = "0b00";
    initial CLKHF = 0;
    always #41.666 CLKHF = ~CLKHF; // ~12MHz
endmodule