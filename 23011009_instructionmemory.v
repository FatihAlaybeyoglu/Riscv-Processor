module instructionmemory #(
    parameter WORD_SIZE = 32,
    parameter MEM_DEPTH = 25      // 256 kelime (1024 byte) derinlik
)(
    input  wire [WORD_SIZE-1:0]  addr,      // byte adresi
    output reg  [WORD_SIZE-1:0]  instr
);
    // kelime adreslemesi için [2] bitinden sonraki bitleri kullanıyoruz
    reg [WORD_SIZE-1:0] mem [0:MEM_DEPTH-1];

    integer i;  
    initial begin
        // Tüm fonksiyonlar ve senaryo komutları (binary format)
        $readmemh("23011009_instr.txt", mem);    
    end

    always @(*) begin
        instr = mem[ addr[WORD_SIZE-1:2] ];
    end
endmodule
