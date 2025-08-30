

`timescale 1ns / 1ps

module test_bench;

    // Inputs
    reg clk;
    reg reset;
    reg [31:0] in_data;
    reg start;

    // Outputs
    wire [31:0] IM_ADDRESS_BUS_main;
    wire [31:0] IM_DATA_BUS_main;
    wire [31:0] PC;
    wire [31:0] wb_data_out_main;
    wire [3:0]  flag_main;
    wire [31:0] io_out;

    // Instantiate the Processor
    Processor uut (
        .clk(clk),
        .reset(reset),
        .in_data(in_data),
        .start(start),
        .IM_ADDRESS_BUS_main(IM_ADDRESS_BUS_main),
        .IM_DATA_BUS_main(IM_DATA_BUS_main),
        .PC(PC),
        .wb_data_out_main(wb_data_out_main),
        .flag_main(flag_main),
        .io_out(io_out)
    );

    // Generate clock: 10 ns period
    always #5 clk = ~clk;

    initial begin
        // Initial setup
        clk = 0;
        reset = 1;
        start = 0;
        in_data = 32'h00000000;

        // Hold reset
        #20;
        reset = 0;
        #10;

        // Start processor
        //start = 1;
       // #10;
        //start = 0;

        // Let it run for a short time
        #120;

        // Finish simulation
        $finish;
    end

    // Monitor one instruction execution
    initial begin
        $monitor("Time=%0t | PC=%h | wb_data_out_main=%h | flag_main=%b | io_out=%h | IM_ADDRESS_BUS = %b | IM_DATA_BUS =%h",
                 $time, PC, wb_data_out_main, flag_main, io_out ,IM_ADDRESS_BUS_main,IM_DATA_BUS_main);
    end

endmodule



