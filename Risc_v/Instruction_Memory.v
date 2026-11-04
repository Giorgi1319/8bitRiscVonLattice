module Instruction_Memory (
    input  wire [7:0]  Address,
    output wire [15:0] Instruction,
    input  wire [7:0]  DbgAddr,
    output wire [15:0] DbgData
);

    reg [15:0] memory [0:255];

    initial begin
        // relative to the simulation files folder (Icarus) and to this file's folder (Radiant)
        $readmemb("../program file/program.mem", memory);
    end

    assign Instruction = memory[Address];
    assign DbgData     = memory[DbgAddr];

endmodule

