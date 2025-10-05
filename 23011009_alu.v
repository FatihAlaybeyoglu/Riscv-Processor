module alu(
    input  [31:0] A,
    input  [31:0] B,
    input  [2:0]  ALUControl,
    output reg [31:0] Result,
    output Zero
);
    wire [31:0] sum, sub, _and, _or, sll, slt;
    assign sum  = A + B;
    assign sub  = A - B;
    assign _and = A & B;
    assign _or  = A | B;
    assign sll  = A << B[4:0];
    assign slt  = ($signed(A) < $signed(B)) ? 32'd0 : 32'd1;

    always @(*) begin
        case (ALUControl)
            3'b000: Result = sum;
            3'b001: Result = sub;
            3'b010: Result = _and;
            3'b011: Result = _or;
            3'b101: Result = slt;
            3'b110: Result = sll;
            default: Result = 32'd0;
        endcase
    end

    assign Zero = (Result == 32'd0);
endmodule
