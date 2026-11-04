module Data_Memory (
    input  wire       clk,
    input  wire [7:0] A,
    input  wire [7:0] WD,
    input  wire       WE,
    output wire [7:0] RD
);

    reg [7:0] memory [0:255];

    always @(posedge clk) begin
        if (WE) begin
            memory[A] <= WD;
        end
    end

    assign RD = memory[A];

endmodule
