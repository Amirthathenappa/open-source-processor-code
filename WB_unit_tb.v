
`timescale 1ns / 1ps

module WB_Unit_tb;

    // Inputs
    reg        reg_write_en;
    reg [31:0] exe_result;
    reg [4:0]  rd_addr;
    reg        from_mem;
    reg [4:0]  store_data_to;
    reg [31:0] read_data;

    // Outputs
    wire       wb_done;
    wire       rf_we;
    wire [4:0] rf_rd_addr;
    wire [31:0] rf_rd_data;

    // Instantiate the DUT (Device Under Test)
    WB_Unit uut (
        .reg_write_en(reg_write_en),
        .exe_result(exe_result),
        .rd_addr(rd_addr),
        .from_mem(from_mem),
        .store_data_to(store_data_to),
        .read_data(read_data),
        .wb_done(wb_done),
        .rf_we(rf_we),
        .rf_rd_addr(rf_rd_addr),
        .rf_rd_data(rf_rd_data)
    );

    initial begin
        $display("Starting WB_Unit Testbench...");
        // -------------------------------------------
        // Test 1: Write-back from EXE stage
        // -------------------------------------------
        reg_write_en    = 1;
        exe_result      = 32'h12345678;
        rd_addr         = 5'd10;
        from_mem        = 0;
        store_data_to   = 5'd0;
        read_data       = 32'd0;
        #10;

        $display("EXE Stage: rf_we = %b, addr = %d, data = %h, wb_done = %b",
                  rf_we, rf_rd_addr, rf_rd_data, wb_done);

        // -------------------------------------------
        // Test 2: Write-back from MEM stage
        // -------------------------------------------
        reg_write_en    = 0;
        from_mem        = 1;
        store_data_to   = 5'd12;
        read_data       = 32'hCAFEBABE;
        #10;

        $display("MEM Stage: rf_we = %b, addr = %d, data = %h, wb_done = %b",
                  rf_we, rf_rd_addr, rf_rd_data, wb_done);

        // -------------------------------------------
        // Test 3: No write-back
        // -------------------------------------------
        reg_write_en    = 0;
        from_mem        = 0;
        exe_result      = 32'h0;
        rd_addr         = 5'd0;
        store_data_to   = 5'd0;
        read_data       = 32'd0;
        #10;

        $display("No Write-back: rf_we = %b, addr = %d, data = %h, wb_done = %b",
                  rf_we, rf_rd_addr, rf_rd_data, wb_done);

        $display("Testbench Completed.");
        $finish;
    end

endmodule

