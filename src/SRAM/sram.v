module SRAM#(parameter ADR = 16,
                parameter BITS = 32,
                parameter CELLS = 2**ADR)
            (clk, in, out, adr, WE, OE);

    input wire clk, WE, OE;
    input wire [BITS-1:0] in;
    input wire [ADR-1:0] adr;

    output reg [BITS-1:0] out;

    reg [BITS-1:0] RAM [CELLS-1:0];

    always @ (posedge clk) begin
        if (WE) 
            RAM[adr] <= in;
        if (OE) 
            out <= RAM[adr];
    end

endmodule