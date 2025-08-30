`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10.05.2025 00:20:30
// Design Name: 
// Module Name: IF_ID_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module IF_ID_tb;

    // Testbench signals
    reg clk;                 // Clock signal
    reg reset;               // Reset signal
    reg [31:0] instr_in;     // Instruction input
    reg [31:0] pc_in;        // Program Counter input
    wire [31:0] instr_out;   // Instruction output
    wire [31:0] pc_out;      // Program Counter output

    // Instantiate the IF_ID module
    IF_ID uut (
        .clk(clk),
        .reset(reset),
        .instr_in(instr_in),
        .pc_in(pc_in),
        .instr_out(instr_out),
        .pc_out(pc_out)
    );

    // Clock generation
    always begin
        #5 clk = ~clk;  // Toggle clock every 5 time units
    end

    // Initialize signals and apply test cases
    initial begin
        // Initialize clock and inputs
        clk = 0;
        reset = 0;
        instr_in = 32'h00000000;   // Initial instruction value
        pc_in = 32'h00000000;      // Initial program counter value

        // Apply reset
        #10 reset = 1;            // Apply reset at time 10
        #10 reset = 0;            // Release reset at time 20
        
        // Apply test cases
        #10 instr_in = 32'h2008000A;  // Test instruction 1 (addi $t0, $zero, 10)
        pc_in = 32'h00000004;         // Set program counter
        #10 instr_in = 32'h20090014;  // Test instruction 2 (addi $t1, $zero, 20)
        pc_in = 32'h00000008;         // Set program counter
        
        #10 instr_in = 32'h01095020;  // Test instruction 3 (add $t2, $t0, $t1)
        pc_in = 32'h0000000C;         // Set program counter
        
        #10 instr_in = 32'h012A5822;  // Test instruction 4 (sub $t3, $t1, $t2)
        pc_in = 32'h00000010;         // Set program counter
        
        // Test with reset applied mid-simulation
        #10 reset = 1;            // Apply reset
        #10 reset = 0;            // Release reset
        
        // Apply more test values after reset
        #10 instr_in = 32'h014B6024;  // Test instruction 5 (and $t4, $t2, $t3)
        pc_in = 32'h00000014;         // Set program counter
        
        // End the simulation
        #20 $finish;
    end

    // Monitor signals for observation
    initial begin
        $monitor("Time = %0t | instr_in = %h | pc_in = %h | instr_out = %h | pc_out = %h",
                 $time, instr_in, pc_in, instr_out, pc_out);
    end

endmodule

