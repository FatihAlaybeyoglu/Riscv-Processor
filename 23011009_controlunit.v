module control_unit(
    input  [6:0] opcode,
    input  [2:0] funct3,
    input        funct7_5,
    input        Zero, 
    output reg        RegWrite,
    output reg        MemWrite,
    output reg        ALUSrc,
    output reg [2:0]  ImmSrc,
    output reg [1:0]  ResultSrc,
    output reg        PCSrc,
    output reg [1:0]  ALUOp,
    output reg [2:0]  ALUControl
);  
    // opcode kodları
    localparam OP_R     = 7'b0110011;
    localparam OP_I     = 7'b0010011;
    localparam OP_LW    = 7'b0000011;
    localparam OP_SW    = 7'b0100011;
    localparam OP_BEQ   = 7'b1100011;
    localparam OP_JAL   = 7'b1101111;
    localparam OP_LUI   = 7'b0110111;

    // ALUControl kodları
    localparam ALU_ADD  = 3'b000;
    localparam ALU_SUB  = 3'b001;
    localparam ALU_SLL  = 3'b110;
    localparam ALU_SLT  = 3'b101;
    localparam ALU_OR  = 3'b011;
    localparam ALU_AND  = 3'b010;
    always @(*) begin
        // Varsayılan değerler
        RegWrite   = 0;
        MemWrite   = 0;
        ALUSrc     = 0;
        ImmSrc     = 3'b000;
        ResultSrc  = 2'b00;
        PCSrc      = 0;
        ALUOp      = 2'b00;
        ALUControl = ALU_ADD;

        case (opcode)
            OP_R: begin
                RegWrite = 1;
                ALUSrc   = 0;
                ALUOp    = 2'b10;
            end
            OP_I: begin 
                RegWrite = 1;
                ALUSrc   = 1;
                ALUOp    = 2'b10;
                ImmSrc   = 3'b000; // I-type
            end
            OP_LW: begin
                RegWrite   = 1;
                ALUSrc     = 1;
                ImmSrc     = 3'b000; // I-type
                ResultSrc  = 2'b01; // Memory
            end
            OP_SW: begin
                MemWrite = 1;
                ALUSrc   = 1;
                ImmSrc   = 3'b001; // S-type
            end
            OP_BEQ: begin
                ALUOp    = 2'b01; //zero flag
                ImmSrc   = 3'b010; // B-type
                PCSrc = Zero;
            end
            OP_JAL: begin
                RegWrite  = 1;
                PCSrc     = 1;
                ImmSrc    = 3'b011; // J-type
                ResultSrc = 2'b10; // PC+4
            end
            OP_LUI: begin
                RegWrite  = 1;
                ALUSrc    = 1;
                ImmSrc    = 3'b100; // U-type
                ResultSrc = 2'b11; // U-type immediate
            end
        endcase

        // ALUControl belirleme
        case (ALUOp)
            2'b00: ALUControl = ALU_ADD; // load/store
            2'b01: ALUControl = ALU_SUB; // branch karşılaştırma
            2'b10: begin // R/I-tip ALU işlemleri
                case (funct3)
                    3'b000: ALUControl = (opcode==OP_R && funct7_5) ? ALU_SUB : ALU_ADD; // SUB/ADD veya ADDI
                    3'b001: ALUControl = ALU_SLL; // SLL/SLLI
                    3'b010: ALUControl = ALU_SLT; // SLT/SLTI
                    3'b110: ALUControl = ALU_OR;  // OR/ORI
                    3'b111: ALUControl = ALU_AND; // AND/ANDI
                    default: ALUControl = ALU_ADD;
                endcase
            end
            default: ALUControl = ALU_ADD;
        endcase
    end
endmodule