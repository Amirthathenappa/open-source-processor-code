module IF_ID (
    input  wire        clk, reset,
    input  wire [31:0] instr_in, pc_in,
    output reg  [31:0] instr_out, pc_out
);
    always @(posedge clk or posedge reset) begin
        if (reset) begin instr_out <= 0; pc_out <= 0; end
        else begin instr_out <= instr_in; pc_out <= pc_in; end
    end
endmodule
