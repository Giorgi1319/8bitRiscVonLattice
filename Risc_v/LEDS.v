module LEDS (
    input  wire [63:0] Regs,
    output wire [7:0]  LED_out
);

    assign LED_out[0] = 1'b0;   

    genvar g;
    generate
        for (g = 1; g < 8; g = g + 1) begin : match
            assign LED_out[g] = (Regs[g*8 +: 8] == g);
        end
    endgenerate

endmodule