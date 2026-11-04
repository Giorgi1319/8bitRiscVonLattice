module Register_File (
    input  wire       clk,
    input  wire       reset,
    input  wire [2:0] A1,
    input  wire [2:0] A2,
    input  wire [2:0] A3,
    input  wire [7:0] WD3,
    input  wire       WE3,
    output wire [7:0] RD1,
    output wire [7:0] RD2,
    output wire [63:0] AllRegs
);


    reg [7:0] registers [0:7];

    integer i;
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            for (i = 0; i < 8; i = i + 1)
                registers[i] <= 8'b00000000;
        end else if (WE3 && A3 != 3'b000) begin
            registers[A3] <= WD3;
        end
    end

    assign RD1 = (A1 == 3'b000) ? 8'b00000000 : registers[A1];
    assign RD2 = (A2 == 3'b000) ? 8'b00000000 : registers[A2];

    genvar g;
    generate
        for (g = 0; g < 8; g = g + 1) begin : flat
            assign AllRegs[g*8 +: 8] = registers[g];
        end
    endgenerate

endmodule
