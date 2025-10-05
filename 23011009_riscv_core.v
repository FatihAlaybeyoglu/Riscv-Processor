module riscv_core(
    input        clk,
    input        rst
);
    // PC counter
    wire [31:0] pc;
    wire [31:0] pc_plus4;
    // PC+4 hesaplama (writeback ve pipeline dışı gereksinimler için)
    assign pc_plus4 = pc + 32'd4;

    // Branch hedef adresi hesaplama
    wire [31:0] imm_ext; // daha aşağıda oluşturuluyor
    wire [31:0] branch_target = pc + imm_ext;

    pc_counter pc_reg (
        .clk(clk),
        .rst(rst),
        .next_pc(branch_target),
        .pc_src(PCSrc),
        .pc(pc)
    );

    // Instruction Memory
    wire [31:0] instr;
    instructionmemory imem(
        .addr(pc),
        .instr(instr)
    );

    // Decode alanı
    wire [6:0]  opcode   = instr[6:0];
    wire [2:0]  funct3   = instr[14:12];
    wire        funct7_5 = instr[30];
    wire [4:0]  rs1      = instr[19:15];
    wire [4:0]  rs2      = instr[24:20];
    wire [4:0]  rd       = instr[11:7];

    // Register File
    wire [31:0] reg_data1, reg_data2;
    wire [31:0] write_data;
    wire        reg_write;
    regfile rf(
        .clk(clk),
        .rst(rst),
        .wr(reg_write),
        .addr1(rs1),
        .addr2(rs2),
        .addr3(rd),
        .data1(reg_data1),
        .data2(reg_data2),
        .data3(write_data)
    );

    // Immediate Generator
    reg [31:0] imm;
    always @(*) begin
        case (ImmSrc)
            3'b000: // I-type
                imm = {{20{instr[31]}}, instr[31:20]};
            3'b001: // S-type
                imm = {{20{instr[31]}}, instr[31:25], instr[11:7]};
            3'b010: // B-type
                imm = {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};
            3'b011: // J-type
                imm = {{11{instr[31]}}, instr[31], instr[19:12], instr[20], instr[30:21], 1'b0};
            3'b100: // U-type
                imm = {instr[31:12], 12'b0};
            default:
                imm = 32'd0;
        endcase
    end
    assign imm_ext = imm;

    // Control Unit
    wire MemWrite, ALUSrc, PCSrc;
    wire [1:0] ResultSrc, ALUOp;
    wire [2:0] ALUControl , ImmSrc;
    control_unit cu(
        .opcode(opcode),
        .funct3(funct3),
        .funct7_5(funct7_5),
        .Zero(zero_flag),
        .RegWrite(reg_write),
        .MemWrite(MemWrite),
        .ALUSrc(ALUSrc),
        .ImmSrc(ImmSrc),
        .ResultSrc(ResultSrc),
        .PCSrc(PCSrc),
        .ALUOp(ALUOp),
        .ALUControl(ALUControl)
    );

    // ALU operand seçicileri
    wire [31:0] alu_b = ALUSrc ? imm_ext : reg_data2;
    wire [31:0] alu_result;
    wire        zero_flag;
    alu alu_unit(
        .A(reg_data1),
        .B(alu_b),
        .ALUControl(ALUControl),
        .Result(alu_result),
        .Zero(zero_flag)
    );

    // Data Memory
    wire [31:0] mem_read;
    data_mem dmem(
        .clk(clk),
        .we(MemWrite),
        .addr(alu_result),
        .write_data(reg_data2),
        .read_data(mem_read)
    );
assign write_data = (ResultSrc == 2'b00) ? alu_result  :  // R/I sonuç
                    (ResultSrc == 2'b01) ? mem_read    :  // LW sonucu
                    (ResultSrc == 2'b10) ? pc_plus4    :  // JAL link
                    (ResultSrc == 2'b11) ? imm_ext     :  // LUI sonucu
                                          32'd0;  

endmodule