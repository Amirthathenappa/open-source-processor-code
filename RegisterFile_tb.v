//`timescale 1ns / 1ps
//module RegisterFile_tb;

//    // Inputs
//    reg clk;
//    reg we;
//    reg RF_trigger;
//    reg RF_from_IO;
//    reg io_we;
//    reg [4:0] rs1_addr;
//    reg [4:0] rs2_addr;
//    reg [4:0] rd_addr;
//    reg [31:0] rd_data;
//    reg [31:0] data_io;

//    // Outputs
//    wire [31:0] rs1_data;
//    wire [31:0] rs2_data;

//    // Instantiate the RegisterFile
//    RegisterFile uut (
//        .clk(clk),
//        .we(we),
//        .RF_trigger(RF_trigger),
//        .RF_from_IO(RF_from_IO),
//        .io_we(io_we),
//        .rs1_addr(rs1_addr),
//        .rs2_addr(rs2_addr),
//        .rd_addr(rd_addr),
//        .rd_data(rd_data),
//        .data_io(data_io),
//        .rs1_data(rs1_data),
//        .rs2_data(rs2_data)
//    );

//    // Clock generation
//    always #5 clk = ~clk;

//    initial begin
//        $display("Starting RegisterFile test...");
//        $dumpfile("regfile_tb.vcd");  // For waveform
//        $dumpvars(0, RegisterFile_tb);

//        // Init
//        clk = 0;
//        we = 0;
//        RF_trigger = 0;
//        RF_from_IO = 0;
//        io_we = 0;
//        rs1_addr = 0;
//        rs2_addr = 0;
//        rd_addr = 0;
//        rd_data = 0;
//        data_io = 0;

//        // Wait a few cycles
//        #10;

//        // Write 0xAA to reg1
//        we = 1;
//        rd_addr = 5'd1;
//        rd_data = 32'h000000AA;
        
//        #10;
//        we = 0;

//        // Write 0xBB to reg2
//        we = 1;
//        rd_addr = 5'd2;
//        rd_data = 32'h000000BB;
        
//        #10;
//        we = 0;

//        // Read from reg1 and reg2 using RF_trigger
//        rs1_addr = 5'd1;
//        rs2_addr = 5'd2;
//        RF_trigger = 1;
//        #10;
//        RF_trigger = 0;
//        $display("Read reg1: %h, reg2: %h (Expected: AA, BB)", rs1_data, rs2_data);

//        // Write to reg31 via IO
//        data_io = 32'hADDDDDDA;
//        io_we = 1;
//        #10;
//        io_we = 0;

//        // Read reg31 using RF_from_IO
//        RF_from_IO = 1;
//        #10;
//        RF_from_IO = 0;
//        $display("Read reg31 via IO: %h (Expected: ADDDDDDA)", rs1_data);

//        $display("Test finished.");
//        $finish;
//    end

//endmodule

`timescale 1ns / 1ps

module RegisterFile_tb;

    // Inputs
    reg        we;
    reg        RF_trigger;
    reg        RF_from_IO;
    reg        io_we;
    reg  [4:0] rs1_addr;
    reg  [4:0] rs2_addr;
    reg  [4:0] rd_addr;
    reg  [31:0] rd_data;
    reg  [31:0] data_io;

    // Outputs
    wire [31:0] rs1_data;
    wire [31:0] rs2_data;

    // Instantiate the Unit Under Test (UUT)
    RegisterFile uut (
        .we(we),
        .RF_trigger(RF_trigger),
        .RF_from_IO(RF_from_IO),
        .io_we(io_we),
        .rs1_addr(rs1_addr),
        .rs2_addr(rs2_addr),
        .rd_addr(rd_addr),
        .rd_data(rd_data),
        .data_io(data_io),
        .rs1_data(rs1_data),
        .rs2_data(rs2_data)
    );

    initial begin
        $display("Starting RegisterFile Testbench");
        we = 0; RF_trigger = 0; RF_from_IO = 0; io_we = 0;
        rs1_addr = 0; rs2_addr = 0; rd_addr = 0;
        rd_data = 0; data_io = 0;

        // Step 1: Write to registers using write-back
        rd_addr = 5'd1;
        rd_data = 32'hAAAA_BBBB;
        we = 1; #5; we = 0;

        rd_addr = 5'd2;
        rd_data = 32'h1234_5678;
        we = 1; #5; we = 0;

        // Step 2: Read from registers using RF_trigger
        rs1_addr = 5'd1;
        rs2_addr = 5'd2;
        RF_trigger = 1; #5; RF_trigger = 0;
        $display("Read Test: rs1_data = %h (expected AAAABBBB), rs2_data = %h (expected 12345678)", rs1_data, rs2_data);

        // Step 3: Write to register 31 using IO
        data_io = 32'hA1B2_C3D4;
        io_we = 1; #5; io_we = 0;

        // Step 4: Read from register 31 using RF_from_IO
        RF_from_IO = 1; #5; RF_from_IO = 0;
        $display("IO Read Test: rs1_data = %h (expected A1B2_C3D4)", rs1_data);

        // Step 5: Try simultaneous trigger conditions (should prioritize RF_trigger)
        rs1_addr = 5'd1;
        rs2_addr = 5'd2;
        RF_trigger = 1;
        RF_from_IO = 1;
        io_we = 1;
        data_io = 32'h1111_1111;
        #5;
        $display("Priority Test: rs1_data = %h (expected AAAABBBB), rs2_data = %h (expected 12345678)", rs1_data, rs2_data);
        RF_trigger = 0; RF_from_IO = 0; io_we = 0;

        // Step 6: Write to register 0 and read back 
        rd_addr = 5'd0;
        rd_data = 32'hCAFEBABE;
        we = 1; #5; we = 0;
        rs1_addr = 5'd0; RF_trigger = 1; #5;
        $display("Write reg0: rs1_data = %h (expectED CAFEBABE )", rs1_data);

        $display("RegisterFile Testbench Completed");
        $finish;
    end

endmodule


