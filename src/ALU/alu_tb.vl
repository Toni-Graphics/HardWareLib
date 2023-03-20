`include "alu.vl"

module alu_tb;
    reg clk, carry_in;
    reg [3:0] opcode;
    reg [7:0] a, b;
    wire [7:0] sum;
    wire carry_out;

    ALU alu(.clk(clk), .in_a(a), .in_b(b), .sum(sum), . carry_in(carry_in), .carry_out(carry_out), .opcode(opcode));
    initial begin
        opcode =  3;
        a = 5;
        b = 10;
        clk = 1;
        #1 clk = 0;
        $monitor("%d * %d = %d\n Carry: %b", a, b, sum, carry_out);
    end

endmodule