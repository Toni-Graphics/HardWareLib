// (C) Copyright aklim; https://github.com/akilm/

module FPU_Addition #(parameter BITS=32)
                        (input [BITS-1:0]A,
                         input [BITS-1:0]B,
                         input clk,
                         output overflow,
                         output underflow,
                         output exception,
                         output reg  [BITS-1:0] result);

    reg [23:0] A_Mantissa,B_Mantissa;
    reg [23:0] Temp_Mantissa;
    reg [22:0] Mantissa;
    reg [7:0] Exponent;
    reg Sign;
    wire MSB;
    reg [7:0] A_Exponent,B_Exponent,Temp_Exponent,diff_Exponent;
    reg A_sign,B_sign,Temp_sign;
    reg [32:0] Temp;
    reg carry;
    reg [2:0] one_hot;
    reg comp;
    reg [7:0] exp_adjust;
    always @(posedge clk) begin
        comp =  (A[30:23] >= B[30:23])? 1'b1 : 1'b0;
        
        A_Mantissa = comp ? {1'b1,A[22:0]} : {1'b1,B[22:0]};
        A_Exponent = comp ? A[30:23] : B[30:23];
        A_sign = comp ? A[31] : B[31];
        
        B_Mantissa = comp ? {1'b1,B[22:0]} : {1'b1,A[22:0]};
        B_Exponent = comp ? B[30:23] : A[30:23];
        B_sign = comp ? B[31] : A[31];

        diff_Exponent = A_Exponent-B_Exponent;
        B_Mantissa = (B_Mantissa >> diff_Exponent);
        {carry,Temp_Mantissa} =  (A_sign ~^ B_sign)? A_Mantissa + B_Mantissa : A_Mantissa-B_Mantissa ; 
        exp_adjust = A_Exponent;
        if(carry)
            begin
                Temp_Mantissa = Temp_Mantissa>>1;
                exp_adjust = exp_adjust+1'b1;
            end
        else
            begin
            while(!Temp_Mantissa[23])
                begin
                Temp_Mantissa = Temp_Mantissa<<1;
                exp_adjust =  exp_adjust-1'b1;
                end
            end
        Sign = A_sign;
        Mantissa = Temp_Mantissa[22:0];
        Exponent = exp_adjust;
        result = {Sign,Exponent,Mantissa};
        //Temp_Mantissa = (A_sign ~^ B_sign) ? (carry ? Temp_Mantissa>>1 : Temp_Mantissa) : (0); 
        //Temp_Exponent = carry ? A_Exponent + 1'b1 : A_Exponent; 
        //Temp_sign = A_sign;
        //result = {Temp_sign,Temp_Exponent,Temp_Mantissa[22:0]};
    end
endmodule

module FPU_Multiplication #(parameter BITS=32)
                                (input [BITS-1:0]A,
                                 input [BITS-1:0]B,
                                 input clk,
                                 output overflow,
                                 output underflow,
                                 output exception,
                                 output reg  [BITS-1:0] result);

    reg [23:0] A_Mantissa,B_Mantissa;
    reg [22:0] Mantissa;
    reg [47:0] Temp_Mantissa;
    reg [7:0] A_Exponent,B_Exponent,Temp_Exponent,diff_Exponent,Exponent;
    reg A_sign,B_sign,Sign;
    reg [32:0] Temp;
    reg [6:0] exp_adjust;
    always @(posedge clk) begin
        A_Mantissa = {1'b1,A[22:0]};
        A_Exponent = A[30:23];
        A_sign = A[31];
        
        B_Mantissa = {1'b1,B[22:0]};
        B_Exponent = B[30:23];
        B_sign = B[31];

        Temp_Exponent = A_Exponent+B_Exponent-127;
        Temp_Mantissa = A_Mantissa*B_Mantissa;
        Mantissa = Temp_Mantissa[47] ? Temp_Mantissa[46:24] : Temp_Mantissa[45:23];
        Exponent = Temp_Mantissa[47] ? Temp_Exponent+1'b1 : Temp_Exponent;
        Sign = A_sign^B_sign;
        result = {Sign,Exponent,Mantissa};
    end
endmodule

module FPU_Division#(parameter BITS=32)
                        (input [BITS-1:0]A,
                         input [BITS-1:0]B,
                         input clk,
                         output overflow,
                         output underflow,
                         output exception,
                         output [BITS-1:0] result);                 
    reg [23:0] A_Mantissa,B_Mantissa;
    reg [22:0] Mantissa;
    wire [7:0] exp;
    reg [23:0] Temp_Mantissa;
    reg [7:0] A_Exponent,B_Exponent,Temp_Exponent,diff_Exponent;
    wire [7:0] Exponent;
    reg [7:0] A_adjust,B_adjust;
    reg A_sign,B_sign,Sign;
    reg [32:0] Temp;
    wire [31:0] temp1,temp2,temp3,temp4,temp5,temp6,temp7,debug;
    wire [31:0] reciprocal;
    wire [31:0] x0,x1,x2,x3;
    reg [6:0] exp_adjust;
    reg [BITS-1:0] B_scaled; 
    reg en1,en2,en3,en4,en5;
    reg dummy;
    /*----Initial value----*/
    FPU_Multiplication M1(.A({{1'b0,8'd126,B[22:0]}}),.B(32'h3ff0f0f1),.clk(clk),.result(temp1)); //verified
    assign debug = {1'b1,temp1[30:0]};
    FPU_Addition A1(.A(32'h4034b4b5),.B({1'b1,temp1[30:0]}),.result(x0));

    /*----First Iteration----*/
    FPU_Multiplication M2(.A({{1'b0,8'd126,B[22:0]}}),.B(x0),.clk(clk),.result(temp2));
    FPU_Addition A2(.A(32'h40000000),.B({!temp2[31],temp2[30:0]}),.result(temp3));
    FPU_Multiplication M3(.A(x0),.B(temp3),.clk(clk),.result(x1));

    /*----Second Iteration----*/
    FPU_Multiplication M4(.A({1'b0,8'd126,B[22:0]}),.B(x1),.clk(clk),.result(temp4));
    FPU_Addition A3(.A(32'h40000000),.B({!temp4[31],temp4[30:0]}),.result(temp5));
    FPU_Multiplication M5(.A(x1),.B(temp5),.clk(clk),.result(x2));

    /*----Third Iteration----*/
    FPU_Multiplication M6(.A({1'b0,8'd126,B[22:0]}),.B(x2),.clk(clk),.result(temp6));
    FPU_Addition A4(.A(32'h40000000),.B({!temp6[31],temp6[30:0]}),.result(temp7));
    FPU_Multiplication M7(.A(x2),.B(temp7),.clk(clk),.result(x3));

    /*----Reciprocal : 1/B----*/
    assign Exponent = x3[30:23]+8'd126-B[30:23];
    assign reciprocal = {B[31],Exponent,x3[22:0]};

    /*----Multiplication A*1/B----*/
    FPU_Multiplication M8(.A(A),.B(reciprocal),.clk(clk),.result(result));
endmodule

module FPU_Sqrt#(parameter BITS=32)
                    (input [BITS-1:0]A,
                     input clk,
                     output overflow,
                     output underflow,
                     output exception,
                     output [BITS-1:0] result);
    wire [7:0] Exponent;
    wire [22:0] Mantissa;
    wire Sign;
    wire [BITS-1:0] temp1,temp2,temp3,temp4,temp5,temp6,temp7,temp8,temp;
    wire [BITS-1:0] x0,x1,x2,x3;
    wire [BITS-1:0] sqrt_1by05,sqrt_2,sqrt_1by2;
    wire [7:0] Exp_2,Exp_Adjust;
    wire remainder;
    wire pos;
    assign x0 = 32'h3f5a827a;
    assign sqrt_1by05 = 32'h3fb504f3;  // 1/sqrt(0.5)
    assign sqrt_2 = 32'h3fb504f3;
    assign sqrt_1by2 = 32'h3f3504f3;
    assign Sign = A[31];
    assign Exponent = A[30:23];
    assign Mantissa = A[22:0];
    /*----First Iteration----*/
    FPU_Division D1(.A({1'b0,8'd126,Mantissa}),.B(x0),.result(temp1));
    FPU_Addition A1(.A(temp1),.B(x0),.result(temp2));
    assign x1 = {temp2[31],temp2[30:23]-1,temp2[22:0]};
    /*----Second Iteration----*/
    FPU_Division D2(.A({1'b0,8'd126,Mantissa}),.B(x1),.result(temp3));
    FPU_Addition A2(.A(temp3),.B(x1),.result(temp4));
    assign x2 = {temp4[31],temp4[30:23]-1,temp4[22:0]};
    /*----Third Iteration----*/
    FPU_Division D3(.A({1'b0,8'd126,Mantissa}),.B(x2),.result(temp5));
    FPU_Addition A3(.A(temp5),.B(x2),.result(temp6));
    assign x3 = {temp6[31],temp6[30:23]-1,temp6[22:0]};
    FPU_Multiplication M1(.A(x3),.B(sqrt_1by05),.result(temp7));

    assign pos = (Exponent>=8'd127) ? 1'b1 : 1'b0;
    assign Exp_2 = pos ? (Exponent-8'd127)/2 : (Exponent-8'd127-1)/2 ;
    assign remainder = (Exponent-8'd127)%2;
    assign temp = {temp7[31],Exp_2 + temp7[30:23],temp7[22:0]};
    //assign temp7[30:23] = Exp_2 + temp7[30:23];
    FPU_Multiplication M2(.A(temp),.B(sqrt_2),.result(temp8));
    assign result = remainder ? temp8 : temp;
endmodule

//Copyright TheCPP;
module FPU#(parameter BITS=32,
            parameter Opsize=4)
            (clk, A, B, sum, operation, overflow, underflow, exception);
    input clk;
    input [BITS-1] A;
    input [BITS-1] B;
    input [Opsize-1] operation;
    
    output overflow, underflow, exception;
    output [BITS-1] sum;

    always @(posedge clk) begin
        case operation:
            default: sum <= 0;
        endcase
    end
endmodule