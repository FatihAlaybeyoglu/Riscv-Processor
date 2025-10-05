`timescale 1ns/1ns
// riscv_core_tb.v
module riscv_core_tb;
    reg clk = 0;
    reg rst;
    integer cycle = 0;
    integer i,idx;
    integer cycle_count = 0;
    integer count_cycle_array[0:19]; // 20 elemanlı dizi
    reg [31:0] data_array_temp[0:39]; // 40 elemanlı geçici dizi
    initial begin
        // Initialize count_array
        for (i = 0; i < 20; i = i + 1) begin
            count_cycle_array[i] = 0;
        end
    end
    integer count_index = -1;
    // Instantiate core
    riscv_core uut(
        .clk(clk),
        .rst(rst)
    );

    // Clock: 10 ns period (100 MHz)
    always #5 clk = ~clk;

    // Cycle sayacı
    always @(posedge clk) begin
        if (rst)
            cycle <= 0;
        else
            cycle <= cycle + 1;
    end
    always @(posedge clk) begin
        if (uut.pc == 32'h00000010)begin
            count_index <= count_index + 1;
            count_cycle_array[count_index] <= cycle_count; 
            cycle_count <= 0;end
        else begin
            cycle_count <= cycle_count + 1;end
    end

    // Display header & monitor
    initial begin
    $monitor("cycle : %2d | pc-counter : %8h | s0 : %8h | s1 : %8h | s2 : %8h | s3 : %8h | s4 : %8h | s5 : %8h | s6 : %8h | t0 : %8h | t1 : %8h | t2 : %8h | t3 : %8h | t4 : %8h | t5 : %8h | t6 : %8h | a0 : %8h | addr : %8h | cycle_count : %d",
        cycle, uut.pc,
        uut.rf.register[8],
        uut.rf.register[9],  
        uut.rf.register[18], 
        uut.rf.register[19], 
        uut.rf.register[20], 
        uut.rf.register[21],
        uut.rf.register[22],
        uut.rf.register[5],
        uut.rf.register[6],  
        uut.rf.register[7],  
        uut.rf.register[28], 
        uut.rf.register[29], 
        uut.rf.register[30], 
        uut.rf.register[31], 
        uut.rf.register[10],
        uut.dmem.addr,
        cycle_count
    );
end

    initial begin
        // Reset pulse
        rst = 1; #20;
        rst = 0;
        uut.dmem.mem[0] = 32'h00000000; 
        uut.dmem.mem[1] = 32'h00000001;        
        uut.dmem.mem[2] = 32'h00000200; 
        uut.dmem.mem[3] = 32'h00400000; 
        uut.dmem.mem[4] = 32'h80000000; 
        uut.dmem.mem[5] = 32'h51C06460; 
        uut.dmem.mem[6] = 32'hDEC287D9; 
        uut.dmem.mem[7] = 32'h6C896594; 
        uut.dmem.mem[8] = 32'h99999999; 
        uut.dmem.mem[9] = 32'hFFFFFFFF; 
        uut.dmem.mem[10] = 32'h7FFFFFFF; 
        uut.dmem.mem[11] = 32'hFFFFFFFE; 
        uut.dmem.mem[12] = 32'hC7B52169; 
        uut.dmem.mem[13] = 32'h8CEFF731; 
        uut.dmem.mem[14] = 32'hA550921E; 
        uut.dmem.mem[15] = 32'h0DB01F33; 
        uut.dmem.mem[16] = 32'h24BB7B48; 
        uut.dmem.mem[17] = 32'h98513914; 
        uut.dmem.mem[18] = 32'hCD76ED30; 
        uut.dmem.mem[19] = 32'hC0000003; 
        repeat (4356) @(posedge clk);
        $display("---- Count Array Sonuclari ----");
        for (i = 20; i < 40; i = i + 1) begin
            $display("count[%0d] = %d", i - 20, uut.dmem.mem[i]);
        end
        $display("--------------------------------");
        $display("---- Cycle Sayilari ----");
        for (i = 0; i < 20; i = i + 1) begin
            $display("Cycle count[%0d] = %d", i, count_cycle_array[i]);
        end
        $display("--------------------------------");

        $display("Total cycles: %0d", cycle);
        $finish;
    end
    initial begin
    $dumpfile("23011009.vcd");
    $dumpvars(0, riscv_core_tb.clk);
    $dumpvars(0, riscv_core_tb.rst);
    $dumpvars(0, riscv_core_tb.cycle);
    $dumpvars(0, riscv_core_tb.cycle_count);
    $dumpvars(0, riscv_core_tb.count_index);
    $dumpvars(0, riscv_core_tb.uut.pc);
    $dumpvars(0, riscv_core_tb.uut.rf.register[5]);
    $dumpvars(0, riscv_core_tb.uut.rf.register[6]);
    $dumpvars(0, riscv_core_tb.uut.rf.register[7]);
    $dumpvars(0, riscv_core_tb.uut.rf.register[8]);
    $dumpvars(0, riscv_core_tb.uut.rf.register[9]);
    $dumpvars(0, riscv_core_tb.uut.rf.register[10]);
    $dumpvars(0, riscv_core_tb.uut.rf.register[18]);
    $dumpvars(0, riscv_core_tb.uut.rf.register[19]);
    $dumpvars(0, riscv_core_tb.uut.rf.register[20]);
    $dumpvars(0, riscv_core_tb.uut.rf.register[21]);
    $dumpvars(0, riscv_core_tb.uut.rf.register[22]);
    $dumpvars(0, riscv_core_tb.uut.rf.register[28]);
    $dumpvars(0, riscv_core_tb.uut.rf.register[29]);
    $dumpvars(0, riscv_core_tb.uut.rf.register[30]);
    $dumpvars(0, riscv_core_tb.uut.rf.register[31]);
    $dumpvars(0, riscv_core_tb.uut.dmem.addr);
    for (i = 0; i < 20; i = i + 1)begin
        $dumpvars(0, riscv_core_tb.count_cycle_array[i]);
    end
    for (idx = 0; idx < 40; idx = idx + 1) begin
        $dumpvars(0, riscv_core_tb.data_array_temp[idx]);
    end
end
always @(*) begin
    for (idx = 0; idx < 40; idx = idx + 1)
        data_array_temp[idx] = uut.dmem.mem[idx];
end
endmodule
// iverilog -o sim.vvp 23011009_pccounter.v 23011009_instructionmemory.v 23011009_regfile.v 23011009_controlunit.v 23011009_alu.v 23011009_datamemory.v 23011009_riscv_core.v testbench23011009_tb.v
// vvp sim.vvp
// gtkwave 23011009.vcd
