module ALU (
    input  wire [7:0] Src_A,
    input  wire [7:0] Src_B,
    input  wire [2:0] ALU_Control,
    output reg  [7:0] ALU_Result,
    output wire       Zero
);

    localparam ALU_ADD = 3'b000;
    localparam ALU_SUB = 3'b001;
    localparam ALU_AND = 3'b010;
    localparam ALU_OR  = 3'b011;
    localparam ALU_XOR = 3'b100;
    localparam ALU_NOT = 3'b101;
    localparam ALU_SHL = 3'b110;
    localparam ALU_SHR = 3'b111;

    always @(*) begin
        case (ALU_Control)
            ALU_ADD: ALU_Result = Src_A + Src_B;
            ALU_SUB: ALU_Result = Src_A - Src_B;
            ALU_AND: ALU_Result = Src_A & Src_B;
            ALU_OR:  ALU_Result = Src_A | Src_B;
            ALU_XOR: ALU_Result = Src_A ^ Src_B;
            ALU_NOT: ALU_Result = ~Src_A;
            ALU_SHL: ALU_Result = Src_A << 1;
            ALU_SHR: ALU_Result = Src_A >> 1;
            default: ALU_Result = 8'b00000000;
        endcase
    end

    assign Zero = (ALU_Result == 8'b00000000);

endmodule
