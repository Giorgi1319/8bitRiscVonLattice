module Control_Unit (
    input  wire [3:0] op,
    input  wire [2:0] Funct3,
    input  wire       Zero,
    output wire       PCSrc,
    output reg  [1:0] ResultSrc,
    output reg        MemWrite,
    output reg  [2:0] ALUControl,
    output reg        ALUSrc,
    output reg  [1:0] ImmSrc,
    output reg        RegWrite,
    output reg        JumpReg
);

    localparam OP_R    = 4'b0000;
    localparam OP_ADDI = 4'b0001;
    localparam OP_LW   = 4'b0010;
    localparam OP_SW   = 4'b0011;
    localparam OP_BEQ  = 4'b0100;
    localparam OP_JAL  = 4'b0101;
    localparam OP_JALR = 4'b0110;

    reg Branch, Jump;

    always @(*) begin

        RegWrite   = 1'b0;
        ImmSrc     = 2'b00;
        ALUSrc     = 1'b0;
        MemWrite   = 1'b0;
        ResultSrc  = 2'b00;
        Branch     = 1'b0;
        Jump       = 1'b0;
        ALUControl = 3'b000;
        JumpReg    = 1'b0;

        case (op)
            OP_R: begin
                RegWrite   = 1'b1;
                ALUControl = Funct3;
            end
            OP_ADDI: begin
                RegWrite = 1'b1;
                ALUSrc   = 1'b1;
            end
            OP_LW: begin
                RegWrite  = 1'b1;
                ALUSrc    = 1'b1;
                ResultSrc = 2'b01;
            end
            OP_SW: begin
                ImmSrc   = 2'b01;
                ALUSrc   = 1'b1;
                MemWrite = 1'b1;
            end
            OP_BEQ: begin
                ImmSrc     = 2'b01;
                Branch     = 1'b1;
                ALUControl = 3'b001;
            end
            OP_JAL: begin
                RegWrite  = 1'b1;
                ImmSrc    = 2'b10;
                ResultSrc = 2'b10;
                Jump      = 1'b1;
            end
            OP_JALR: begin
                RegWrite  = 1'b1;   
                ImmSrc    = 2'b00;  
                ALUSrc    = 1'b1;  
                ResultSrc = 2'b10; 
                Jump      = 1'b1;
                JumpReg   = 1'b1;
            end
            default: begin
            end
        endcase
    end

    assign PCSrc = (Branch & Zero) | Jump;

endmodule
