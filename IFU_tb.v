
`timescale 1ns / 1ps

module IFU_tb;

    // Inputs
    reg rst;
    reg [31:0] PC;
    reg [5:0] control_signal;

    // Outputs
    wire [31:0] IM_DATA_BUS;
    wire fetch_complete;

    // Instantiate the Unit Under Test (UUT)
    IFU uut (
        .rst(rst),
        .PC(PC),
        .control_signal(control_signal),
        .IM_DATA_BUS(IM_DATA_BUS),
        .fetch_complete(fetch_complete)
    );

    // Clockless test stimulus
    initial begin
        $display("Starting IFU test...");

        // Step 1: Apply Reset
        rst = 1;
        control_signal = 6'b000000;
        PC = 0;
        #10;

        // Step 2: Release Reset
        rst = 0;
        #10;

        // Step 3: Read Instructions from Address 0 to 3
        repeat (4) begin
            $display("PC = %0d => INSTR = %b, Fetch Done = %b", PC, IM_DATA_BUS, fetch_complete);
            #10;
            PC = PC + 1;
        end

        // Step 4: Apply Stall
        control_signal = 6'b001001;
        #10;
        $display("Stall Applied => INSTR = %b, Fetch Done = %b", IM_DATA_BUS, fetch_complete);

        // Step 5: Remove Stall and Read Again
        control_signal = 6'b000000;
        #10;
        $display("Stall Removed => PC = %0d, INSTR = %b, Fetch Done = %b", PC, IM_DATA_BUS, fetch_complete);

        $display("IFU test completed.");
        $finish;
    end

endmodule


