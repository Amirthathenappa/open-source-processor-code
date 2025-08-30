module IO_Module(
    input wire clk,
    input wire rst,
    input wire [5:0] control_signal,
    input wire [31:0] in_data,          // Data for IN instruction
    output reg RF_from_IO,              // Control signal for accessing R[31]
    output reg [31:0] out_data,         // Data to be sent to output (for OUT instruction)
    output reg io_we,                  // Write enable for writing to R[31]
    output reg [31:0] io_rd_data       // Data to be written to R[31] (for IN instruction)
);

always @(posedge clk or posedge rst) begin
    if (rst) begin
        out_data <= 32'd0;
        io_we <= 1'b0;
        io_rd_data <= 32'd0;
        RF_from_IO <= 1'b0;  // Ensure RF_from_IO is reset properly
    end
    else begin
        case (control_signal)
            6'b111101: begin  // OUT instruction
                RF_from_IO <= 1'b1;   // Indicate access to R[31]
                io_we <= 1'b0;         // No write to R[31]
                out_data <= 32'd0;     // Set out_data to 0 (or R[31] if desired)
            end
            6'b111110: begin  // IN instruction
                io_we <= 1'b1;         // Write enable for R[31]
                io_rd_data <= in_data; // Data to write to R[31]
            end
            default: begin
                io_we <= 1'b0;         // No operation
                RF_from_IO <= 1'b0;    // Clear RF_from_IO when no valid operation
                out_data <= 32'd0;     // Optionally clear out_data on invalid operation
            end
        endcase
    end
end

endmodule
