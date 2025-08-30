module WB_Unit (
    input  wire        reg_write_en,   // From EXE_Unit
    input  wire [31:0] exe_result,     // Data to write
    input  wire [4:0]  rd_addr,        // Destination register address
    input  wire from_mem,               // From MEM stage
    input wire [4:0] store_data_to,    // From MEM stage
    input wire [31:0] read_data,       // From MEM stage
    output reg         wb_done,        // Indicates write is done

    // Outputs to Register File
    output reg         rf_we,          // Write enable for Register File
    output reg [4:0]   rf_rd_addr,     // Register File destination address
    output reg [31:0]  rf_rd_data      // Data to write into Register File
);

always @(*) begin
    // Default values
    rf_we      = 1'b0;
    rf_rd_addr = 5'd0;
    rf_rd_data = 32'd0;
    wb_done    = 1'b0;

    // Conditional write-back from EXE_Unit or MEM stage
    if (reg_write_en) begin
        rf_we      = 1'b1;        // Enable write to register file
        rf_rd_addr = rd_addr;     // Write data to specified register address
        rf_rd_data = exe_result;  // ALU result to write back
        wb_done    = 1'b1;        // Write-back operation complete
    end
    else if (from_mem ) begin    // Write data from memory to register file
        rf_we      = 1'b1;        // Enable write to register file
        rf_rd_addr = store_data_to; // Destination address for memory write-back
        rf_rd_data = read_data;  // Data from memory to write back
        wb_done    = 1'b1;        // Write-back operation complete
    end
end

endmodule
