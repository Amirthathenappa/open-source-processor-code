module Processor (
    input wire        clk,                   // Clock signal
    input wire        reset,                 // Reset signal
    input wire [31:0] in_data,              // Input data (from peripherals)
    input wire start,
    output wire [31:0] IM_ADDRESS_BUS_main, // Address Bus to Memory
    output wire [31:0] IM_DATA_BUS_main,    // Instruction Data Bus
    output wire [31:0] PC,                  // Program Counter Output
    output wire [31:0] wb_data_out_main,    // Output from MEM unit (to WB)
    output wire [3:0] flag_main,            // Flags output from EXE
    output wire [31:0] io_out               // Output to/from IO Module
);

    // Internal wires and registers
    wire [31:0] IM_ADDRESS_BUS;   // Address Bus to Memory
    wire [31:0] IM_DATA_BUS;      // Instruction Data Bus

    wire fetch_complete;          // From IFU
    wire [31:0] pc_out, instr_out;// From IF_ID

    wire [31:0] rs1_data, rs2_data;  // From IDU
    wire [5:0] control_signal_PC, control_signal_EXE, control_signal_MEM, control_signal_INT, control_signal_IO, control_signal_IFU; // From IDU
    wire [31:0] target_address;     // From IDU
    wire [4:0] rd, rs1, rs2;       // From IDU
    wire [31:0] imm;               // From IDU
    wire [31:0] mem_address;       // From IDU
    wire [4:0] store_reg_loc;      // From IDU 
    wire mem_write_en, mem_read_en; // From IDU
    wire ret_from_fun;             // From IDU 
    wire I0, I1, Timer_Interrupt;  // From IDU to PC
    wire RF_Trigger_from_IDU;      // RF Trigger from IDU
    wire [31:0] write_data;
    wire [31:0] rs1_data_fromRF, rs2_data_fromRF; // From RF

    wire [31:0] id_ex_rs1_data;    // From ID_EX
    wire [31:0] id_ex_rs2_data;    // From ID_EX
    wire [31:0] id_ex_imm;         // From ID_EX
    wire [4:0]  id_ex_rd;          // From ID_EX
    wire [5:0]  id_ex_control;     // From ID_EX

    wire [31:0] result;            // From EXE
    wire [4:0] rd_addr;            // From EXE
    wire reg_write;                // From EXE

    wire [31:0] mem_data_out;      // From EXE given out to MEM
    wire [4:0] mem_rd_addr;        // From EXE to MEM (will be passed to WB)

    wire to_wb;                    // From Data Memory
    wire [31:0] wb_data_out;       // From Data Memory 

    wire reg_write_wb;             // From MEM_WB
    wire [4:0] rf_rd_addr;         // From MEM_WB
    wire [31:0] rf_rd_data;        // From MEM_WB

    wire wb_done;                  // From WB
    wire rf_we;                    // From WB

    wire RF_from_IO;               // From IO
    wire io_we;                    // From IO

    wire [31:0] io_rd_data;        // Data to RF from IO
    wire io_out_data;              // From IO

    wire [31:0] data_in;           // Final data input (either from MEM or EXE)
    wire [4:0] final_rd_addr;      // Final destination register address

    wire [31:0] destination_reg_address; // To MEM for destination address
    
    wire [31:0] rs1_addr;//to RF 
    wire [31:0] rs2_addr;//to RF
    
    wire [31:0] rs1_add;//from ID_EX 
    wire [31:0] rs2_add;//from ID_EX
    
     wire [31:0] rs1_addre;//from ID_EX 
    wire [31:0] rs2_addre;//from ID_EX
    
     wire [31:0] rs1_address;//from ID_EX 
    wire [31:0] rs2_address;//from ID_EX
    
    //new
    reg [4:0] rs1_reg;
    reg [4:0] rs2_reg;

  
    // Program Counter Module
    Program_Counter PC_Module (
        .clk(clk),
        .reset(reset),
        .control_signal(control_signal_PC),
        .target_address(target_address),
        .fetch_complete(fetch_complete),//from IFU 
        .is_function_return(ret_from_fun),//from IDU
        .I0(I0),
        .I1(I1),
        .Timer_Interrupt(Timer_Interrupt),
        .start(start),
        
        //output
        .IM_ADDRESS_BUS(IM_ADDRESS_BUS)
    );

    // Instruction Fetch Unit (IFU)
    IFU IFU_Module (
        .rst(reset),
        .PC(IM_ADDRESS_BUS),//from PC
        .control_signal(control_signal_IFU),
        
        //output
        .IM_DATA_BUS(IM_DATA_BUS),
        .fetch_complete(fetch_complete)//to PC
        //.IM_ADDRESS_BUS(IM_ADDRESS_BUS)
    );

    // Pipeline Register (IF_ID)
    IF_ID IF_ID_Register (
        .clk(clk),
        .reset(reset),
        .instr_in(IM_DATA_BUS),//from IF
        .pc_in(IM_ADDRESS_BUS),//from PC
        .instr_out(instr_out),//to IDU 
        .pc_out(pc_out)//to IDU
    );

    // Instruction Decode Unit (IDU)
    IDU IDU_Module (
        .instruction(instr_out),//from IF_IDU
        .PC(pc_out),//From IF_ID
        .rs1_data_in(rs1_data_fromRF),//from RF
        .rs2_data_in(rs2_data_fromRF),//from RF
        
        //output
        .control_signal_EXE(control_signal_EXE),
        .control_signal_PC(control_signal_PC),
        .control_signal_MEM(control_signal_MEM),
        .control_signal_INT(control_signal_INT),
        .control_signal_IO(control_signal_IO),
        .control_signal_IFU(control_signal_IFU),
        .target_address(target_address),
        .rd(rd),
        .rs1(rs1),
        .rs2(rs2),
        .imm(imm),
        .loc(mem_address),
        .write_data(write_data),
        .store_reg_loc(store_reg_loc),
        .mem_write_en(mem_write_en),
        .mem_read_en(mem_read_en),
        .ret_from_fun(ret_from_fun),//to PC
        .I0(I0),
        .I1(I1),
        .Timer_int(Timer_Interrupt),
        .RF_trigger(RF_Trigger_from_IDU),
        .rs1_data(rs1_data),
        .rs2_data(rs2_data)
    );
    
//    always @(posedge clk or posedge reset) begin

//        rs1_reg <= rs1;  // from IDU output
//        rs2_reg <= rs2;
    
//      end


    // Register File
    RegisterFile regfile (
        .clk(clk),
        .we(rf_we),
        .RF_trigger(RF_Trigger_from_IDU),
        .RF_from_IO(RF_from_IO),
        .io_we(io_we),
        .rs1_addr(rs1),
        .rs2_addr(rs2),
        .rd_addr(rf_rd_addr),
        .rd_data(rf_rd_data),
        .data_io(io_rd_data),
        
        //output
        .rs1_data(rs1_data_fromRF),
        .rs2_data(rs2_data_fromRF)
    );

    // Pipeline Register (ID_EXE)
    ID_EX ID_EXE_Register (
        .clk(clk),
        .reset(reset),
        .rs1(rs1),
        .rs2(rs2),
//        .rs1_in(rs1_data),
//        .rs2_in(rs2_data),
        .rs1_in(rs1_data_fromRF),
        .rs2_in(rs2_data_fromRF),
        .imm_in(imm),
        .rd_in(rd),
        .ctrl_ex_in(control_signal_EXE),
        .rs1_out(id_ex_rs1_data),
        .rs2_out(id_ex_rs2_data),
        .imm_out(id_ex_imm),
        .rs1_add(rs1_add),
        .rs2_add(rs2_add),
        .rd_out(id_ex_rd),
        .ctrl_ex_out(id_ex_control)
    );

    // Execution Unit (ALU)
    EXE_Unit EXE_Module (
        .control_signal_exe(id_ex_control),
        .rs1_data(id_ex_rs1_data),
        .rs2_data(id_ex_rs2_data),
        .imm(id_ex_imm),
        .rd_addr(id_ex_rd),
        .result(result),
        .result_rd_addr(rd_addr),
        .flags(flag_main),  // Corrected flag signal
        .reg_write(reg_write)
    );

    // EX/MEM Pipeline Register
    EX_MEM ex_mem_reg (
        .clk(clk),
        .reset(reset),
        .res_in(result),
        .rd_in(rd_addr),
        .rs1_addre(rs1_add),
        .rs2_addre(rs2_add),
        .reg_wr_in(reg_write),
        .res_out(mem_data_out),
        .rd_out(mem_rd_addr),
        .rs1_address(rs1_address),
        .rs2_address(rs2_address),
        .reg_wr_out(reg_write_mem)
    );

    // Data Memory
    DataMemory mem_unit (
        .clk(clk),
        .mem_read(mem_read_en),
        .mem_write(mem_write_en),
        .write_data(write_data),
        .address(mem_address),
        .store_data_to(store_reg_loc),
        .control_signal_MEM(control_signal_MEM),
        .destination_reg_address(destination_reg_address),
        .to_wb(to_wb),
        .read_data(wb_data_out)
    );

    assign data_in = to_wb ? wb_data_out : mem_data_out;
    assign final_rd_addr = to_wb ? destination_reg_address : mem_rd_addr;

    // MEM/WB Pipeline Register
    MEM_WB mem_wb_reg (
        .clk(clk),
        .reset(reset),
        .data_in(mem_data_out),
        .rs1_in(rs1_address),
        .rs2_in(rs2_address),
        .rd_in(final_rd_addr),
        .reg_wr_in(reg_write_mem),
        .data_out(rf_rd_data),
        .rd_out(rf_rd_addr),
        .rs1_out(rs1_addr),
        .rs2_out(rs2_addr),
        .reg_wr_out(reg_write_wb)
    );

    // Write Back Unit
    WB_Unit wb_unit (
        .reg_write_en(reg_write_wb),
        .exe_result(rf_rd_data),
        .rd_addr(rf_rd_addr),
        .from_mem(to_wb),
        .read_data(wb_data_out),
        .wb_done(wb_done),
        .rf_we(rf_we)
    );

    // IO Module
    IO_Module io (
        .clk(clk),
        .rst(reset),
        .control_signal(control_signal_IO),
        .in_data(in_data),
        .RF_from_IO(RF_from_IO),
        .out_data(io_out),
        .io_we(io_we),
        .io_rd_data(io_rd_data)
    );
    assign PC = pc_out;
    assign  wb_data_out_main =  wb_data_out;
    assign IM_ADDRESS_BUS_main = IM_ADDRESS_BUS;
    assign IM_DATA_BUS_main= IM_DATA_BUS;
   // assign flag_main = flag;  


endmodule
