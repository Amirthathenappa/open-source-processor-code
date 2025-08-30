

module Program_Counter_tb;

    reg clk, reset, fetch_complete, is_function_return;
    reg [5:0] control_signal;
    reg [31:0] target_address;
    reg I0, I1, Timer_Interrupt, start;
    wire [31:0] IM_ADDRESS_BUS;

    Program_Counter PC (
        .clk(clk),
        .reset(reset),
        .control_signal(control_signal),
        .target_address(target_address),
        .fetch_complete(fetch_complete),
        .is_function_return(is_function_return),
        .I0(I0),
        .I1(I1),
        .Timer_Interrupt(Timer_Interrupt),
        .start(start),
        .IM_ADDRESS_BUS(IM_ADDRESS_BUS)
    );

    // Clock generation
    always #5 clk = ~clk;

    initial begin
        // Initial values
        clk = 0;
        reset = 1;
        fetch_complete = 0;
        is_function_return = 0;
        control_signal = 6'b000000;
        target_address = 32'h00000000;
        I0 = 0; I1 = 0; Timer_Interrupt = 0; start = 0;

        // Reset pulse
        #10 reset = 0;

        // Start execution
        #10 start = 1; #10 start = 0;

        // Normal instruction flow: increment by 4
        repeat (4) begin
            #10 fetch_complete = 1;
            #10 fetch_complete = 0;
        end

        // Jump instruction
        #10 control_signal = 6'b110011;
        target_address = 32'h000000A0;
        #10 control_signal = 6'b000000;

        // Another fetch
        #10 fetch_complete = 1;
        #10 fetch_complete = 0;

        // Function call
        #10 control_signal = 6'b000011;
        target_address = 32'h000000C0;
        #10 control_signal = 6'b000000;

        // Return
        #10 control_signal = 6'b000110;
        is_function_return = 1;
        #10 control_signal = 6'b000000;
        is_function_return = 0;

        // Interrupt
        #10 I0 = 1; #10 I0 = 0;

        // End simulation
        #50 $finish;
    end
endmodule
