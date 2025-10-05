`define WORD_SIZE 32

module regfile(
    input                     clk,
    input                     wr,
    input                     rst,
    input  [4:0]              addr1,
    input  [4:0]              addr2,
    input  [4:0]              addr3,
    input  [`WORD_SIZE-1:0]   data3,
    output [`WORD_SIZE-1:0]   data1,
    output [`WORD_SIZE-1:0]   data2
);

    // 32 × 32-bit register file
    reg [`WORD_SIZE-1:0] register [0:31];
    integer i;

    // Read ports (combinational)
    assign data1 = register[addr1];
    assign data2 = register[addr2];

    // Write port & synchronous reset
    always @(posedge clk) begin
        if (rst) begin
            // clear all 32 registers on reset
            for (i = 0; i < 32; i = i + 1)
                register[i] <= {`WORD_SIZE{1'b0}};
        end
        else if (wr) begin
            register[addr3] <= data3;
        end
    end

endmodule

//iverilog -o regfile regfile.v