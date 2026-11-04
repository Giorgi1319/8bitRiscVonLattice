module Extend (
    input  wire [15:0] Instr,
    input  wire [1:0]  ImmSrc,
    output reg  [7:0]  ImmExt
);

    always @(*) begin
        case (ImmSrc)
            2'b00:   ImmExt = {{2{Instr[5]}},  Instr[5:0]};
            2'b01:   ImmExt = {{2{Instr[11]}}, Instr[11:9], Instr[2:0]};
            2'b10:   ImmExt = Instr[7:0];
            default: ImmExt = 8'b00000000;
        endcase
    end

endmodule
