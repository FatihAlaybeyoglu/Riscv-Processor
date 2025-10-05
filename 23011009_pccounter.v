module pc_counter(
    input  wire                   clk,
    input  wire                   rst,
    input  wire [31:0]  next_pc,   
    input  wire                   pc_src,    
    output reg  [31:0]  pc
);
    always @(posedge clk) begin
        if (rst)
            pc <= 0;
        else if (pc_src)
            pc <= next_pc;
        else
            pc <= pc + 4;
    end
endmodule