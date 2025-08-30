module Program_Counter (
    input  wire        clk,
    input  wire        reset,
    input  wire [5:0]  control_signal,
    input  wire [31:0] target_address,
    input  wire        fetch_complete,
    input  wire        is_function_return,
    input  wire        I0,  // Non-maskable interrupt
    input  wire        I1,  // Maskable interrupt
    input  wire        Timer_Interrupt,
    input  wire        start,
    output reg  [31:0] IM_ADDRESS_BUS
);

    // Function and ISR Stacks
    reg [31:0] FUNC_Stack [0:7];
    reg [2:0]  FUNC_SP;
    reg [31:0] ISR_Stack  [0:7];
    reg [2:0]  ISR_SP;

    // Interrupt vectors
    localparam [31:0] V0 = 32'h00000080;
    localparam [31:0] V1 = 32'h00000100;
    localparam [31:0] VT = 32'h00000180;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            IM_ADDRESS_BUS <= 32'd0;
            FUNC_SP <= 3'd0;
            ISR_SP <= 3'd0;
        end
        else if (start) begin
            IM_ADDRESS_BUS <= 32'd0;
        end
        else if (I0) begin
            if (ISR_SP <= 6) begin
                ISR_Stack[ISR_SP] <= IM_ADDRESS_BUS + 1;
                ISR_SP <= ISR_SP + 1;
            end
            IM_ADDRESS_BUS <= V0;
        end
        else if (I1) begin
            if (ISR_SP <= 6) begin
                ISR_Stack[ISR_SP] <= IM_ADDRESS_BUS + 1;
                ISR_SP <= ISR_SP + 1;
            end
            IM_ADDRESS_BUS <= V1;
        end
        else if (Timer_Interrupt) begin
            if (ISR_SP <= 6) begin
                ISR_Stack[ISR_SP] <= IM_ADDRESS_BUS + 1;
                ISR_SP <= ISR_SP + 1;
            end
            IM_ADDRESS_BUS <= VT;
        end
        else begin
            case (control_signal)
                6'b110011: IM_ADDRESS_BUS <= target_address;                        // JUMP
                6'b001100: IM_ADDRESS_BUS <= IM_ADDRESS_BUS + target_address;      // BRANCH
                6'b000011: begin                                                   // FUNCTION CALL
                    if (FUNC_SP <= 6) begin
                        FUNC_Stack[FUNC_SP] <= IM_ADDRESS_BUS + 1;
                        FUNC_SP <= FUNC_SP + 1;
                    end
                    IM_ADDRESS_BUS <= target_address;
                end
                6'b110011: begin                                                   // RETURN
//                    if (is_function_return && FUNC_SP > 0) begin
//                        FUNC_SP <= FUNC_SP - 1;
//                        IM_ADDRESS_BUS <= FUNC_Stack[FUNC_SP - 1];
//                    end
                   // else
                     if (!is_function_return && ISR_SP > 0) begin
                        ISR_SP <= ISR_SP - 1;
                        IM_ADDRESS_BUS <= ISR_Stack[ISR_SP - 1];
                    end
                end
                6'b001000: IM_ADDRESS_BUS <= 32'd0;                                // FLUSH
                6'b111111: IM_ADDRESS_BUS <= IM_ADDRESS_BUS;                       // NOP or STALL
                6'b111110: IM_ADDRESS_BUS <= IM_ADDRESS_BUS;                       //HALT
                default: if (fetch_complete)
                             IM_ADDRESS_BUS <= IM_ADDRESS_BUS + 1;                 // Normal increment
            endcase
        end

       // $display("Time=%0t | PC=%h | Ctrl=%b | Fetch=%b | I0=%b I1=%b Timer=%b", $time, IM_ADDRESS_BUS, control_signal, fetch_complete, I0, I1, Timer_Interrupt);
    end
endmodule


