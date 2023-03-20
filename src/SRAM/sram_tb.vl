`include "sram.vl";

module sram_tb;
    reg clk, WE, OE;
    reg [15:0] adr;
    reg [31:0] in;
    wire [31:0] out;

    SRAM ram ( .clk(clk), .adr(adr), .in(in), .out(out), .OE(OE), .WE(WE) );

    initial begin
        WE = 1;
        adr = 1;
        in = 32;
        clk = 1;
        #1 clk = 0;

        WE = 0;
        OE = 1;
        clk = 1;
        #1 clk = 0;
        $monitor("Output: %d, Input: %d", out, in);
    end
endmodule