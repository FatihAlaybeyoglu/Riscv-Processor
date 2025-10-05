
module data_mem #(
    parameter MEM_DEPTH = 1024    
)(
    input  wire                   clk,
    input  wire                   we,         // write enable
    input  wire [31:0]  addr,       // byte adresi
    input  wire [31:0]  write_data,
    output reg  [31:0]  read_data
);
    reg [31:0] mem [0:MEM_DEPTH-1];

    // write (synchronous)
    always @(posedge clk) begin
        if (we)
            mem[ addr[31:2] ] <= write_data;
    end

    // read (combinational)
    always @(*) begin
        read_data = mem[ addr[31:2] ];
    end
endmodule