module IFU (
    input  wire        rst,               // Reset
    input  wire [31:0] PC,                // Program Counter (0-based index)
    input  wire [5:0]  control_signal,    // Control signals from IDU
    output reg  [31:0] IM_DATA_BUS,       // Instruction Data Bus
    output reg         fetch_complete    // Fetch Complete Flag
    //output wire [31:0] IM_ADDRESS_BUS     // Address Bus to Instruction Memory
);

    // Instruction Memory: 1024 instructions
    reg [31:0] INSTR_MEM [0:1023];

    // Decode control signals
    wire stall = (control_signal == 6'b001001);
    wire flush = (control_signal == 6'b001000);

    integer i;

    // Output address bus (just PC as is)
    //assign IM_ADDRESS_BUS = PC;

    // Load instruction memory from file at start
  initial begin
    $readmemh("test_program.mem", INSTR_MEM);
    // Debug: Print first few instructions
    for (i = 0; i < 25; i = i + 1) begin
        $display("INSTR_MEM[%0d] = %h", i, INSTR_MEM[i]);
    end
end

    
    

    // Instruction fetch logic (combinational)
    always @(*) begin
        if (rst || flush || stall) begin
            IM_DATA_BUS    = 32'b0;
            fetch_complete = 0;
        end else begin
            IM_DATA_BUS    = INSTR_MEM[PC];  // PC directly indexes instruction (0-based)
            fetch_complete = 1;
        end
    end

endmodule
