
module RISCV_Top (
    input  wire clk,
    input  wire reset,
    output wire [7:0] leds
);

    wire [7:0]  PC, PCNext, PCPlus1, PCTarget;
    wire [15:0] Instr;
    wire [7:0]  ImmExt, SrcA, SrcB, WriteData, ALUResult, ReadData, Result;
    wire        Zero, PCSrc, MemWrite, ALUSrc, RegWrite, JumpReg;
    wire [63:0] AllRegs;
    wire [1:0]  ResultSrc, ImmSrc;
    wire [2:0]  ALUControl;
    wire [7:0]  DbgAddr, DbgData;


    reg [7:0] pc_reg;
    always @(posedge clk or posedge reset) begin
        if (reset) pc_reg <= 8'b00000000;
        else       pc_reg <= PCNext;
    end
    assign PC = pc_reg;


    assign PCPlus1  = PC + 8'd1;
    assign PCNext   = PCSrc ? PCTarget : PCPlus1;
    assign PCTarget = JumpReg ? ALUResult : (PC + ImmExt);



    LEDS led_blk (
        .Regs (AllRegs),
        .LED_out (leds)
    );

    Instruction_Memory imem (
        .Address     (PC),
        .Instruction (Instr),
        .DbgAddr     (DbgAddr),
        .DbgData     (DbgData)
    );

    Control_Unit cu (
        .op         (Instr[15:12]),
        .Funct3     (Instr[2:0]),
        .Zero       (Zero),
        .PCSrc      (PCSrc),
        .ResultSrc  (ResultSrc),
        .MemWrite   (MemWrite),
        .ALUControl (ALUControl),
        .ALUSrc     (ALUSrc),
        .ImmSrc     (ImmSrc),
        .RegWrite   (RegWrite),
        .JumpReg    (JumpReg)
    );

    Register_File rf (
        .clk   (clk),
        .reset (reset),
        .A1  (Instr[8:6]),
        .A2  (Instr[5:3]),
        .A3  (Instr[11:9]),
        .WD3 (Result),
        .WE3 (RegWrite),
        .RD1 (SrcA),
        .RD2 (WriteData),
        .AllRegs (AllRegs)
    );

    Extend ext (
        .Instr  (Instr),
        .ImmSrc (ImmSrc),
        .ImmExt (ImmExt)
    );

    assign SrcB = ALUSrc ? ImmExt : WriteData;

    ALU alu (
        .Src_A       (SrcA),
        .Src_B       (SrcB),
        .ALU_Control (ALUControl),
        .ALU_Result  (ALUResult),
        .Zero        (Zero)
    );

    Data_Memory dmem (
        .clk (clk),
        .A   (ALUResult),
        .WD  (WriteData),
        .WE  (MemWrite),
        .RD  (ReadData)
    );


    assign Result = (ResultSrc == 2'b00) ? ALUResult :
                    (ResultSrc == 2'b01) ? ReadData  :
                                           PCPlus1;

endmodule


