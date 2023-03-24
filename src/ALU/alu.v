
module ALU#(parameter BITS = 8,
            parameter opcode_size = 4)
        (clk, in_a, in_b, sum, carry_in, carry_out, opcode);

    input wire clk, carry_in;
    input wire [BITS-1:0] in_a;
    input wire [BITS-1:0] in_b;
    input wire [opcode_size-1:0] opcode;
    output reg [BITS-1:0] sum;
    output reg carry_out;

    always @(posedge clk) begin
        case (opcode)
            1: {carry_out, sum} <= in_a + in_b + carry_in;
            2: {carry_out, sum} <= in_a - in_b;
            3: {carry_out, sum} <= in_a * in_b;
            4: {carry_out, sum} <= in_a / in_b;
            5: {carry_out, sum} <= in_a >> in_b;
            6: {carry_out, sum} <= in_a << in_b;
            7: {carry_out, sum} <= in_a | in_b;
            8: {carry_out, sum} <= in_a & in_b;
            9: {carry_out, sum} <= in_a ~& in_b;
            10: {carry_out, sum} <= in_a ^ in_b;
            11: {carry_out, sum} <= in_a ^~ in_b;
            12: {carry_out, sum} <= in_a ~| in_b;
            default:  {carry_out, sum} <= 0;
        endcase
    end
endmodule