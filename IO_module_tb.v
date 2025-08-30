
`timescale 1ns / 1ps

module IO_Module_tb;

    // Inputs
    reg clk;
    reg rst;
    reg [5:0] control_signal;
    reg [31:0] in_data;

    // Outputs
    wire RF_from_IO;
    wire [31:0] out_data;
    wire io_we;
    wire [31:0] io_rd_data;

    // Instantiate the DUT
    IO_Module uut (
        .clk(clk),
        .rst(rst),
        .control_signal(control_signal),
        .in_data(in_data),
        .RF_from_IO(RF_from_IO),
        .out_data(out_data),
        .io_we(io_we),
        .io_rd_data(io_rd_data)
    );

    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk; // 10 ns clock period

    initial begin
        $display("Starting IO_Module Testbench...");
        
        // Reset
        rst = 1;
        control_signal = 6'b000000;
        in_data = 32'd0;
        #10;

        rst = 0;

        // -------------------------------
        // Test 1: IN Instruction
        // -------------------------------
        in_data = 32'hAABBCCDD;
        control_signal = 6'b111110;  // IN instruction
        #10;

        $display("IN: io_we = %b, io_rd_data = %h", io_we, io_rd_data);

        // -------------------------------
        // Test 2: OUT Instruction
        // -------------------------------
        control_signal = 6'b111101;  // OUT instruction
        #10;

        $display("OUT: RF_from_IO = %b, io_we = %b, out_data = %h", RF_from_IO, io_we, out_data);

        // -------------------------------
        // Test 3: Invalid Control Signal
        // -------------------------------
        control_signal = 6'b000011;  // Invalid operation
        #10;

        $display("Invalid: io_we = %b, RF_from_IO = %b, out_data = %h", io_we, RF_from_IO, out_data);

        // -------------------------------
        // Test 4: Apply Reset Again
        // -------------------------------
        rst = 1;
        #10;
        rst = 0;
        #10;

        $display("After Reset: io_we = %b, io_rd_data = %h, RF_from_IO = %b", io_we, io_rd_data, RF_from_IO);

        $display("Testbench Completed.");
        $finish;
    end

endmodule

