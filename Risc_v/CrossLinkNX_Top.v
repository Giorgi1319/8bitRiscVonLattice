// Board top for the Lattice CrossLink-NX Evaluation Board (LIFCL-40-EVN).
// The board's push buttons read 0 when pressed and its LEDs light when
// driven 0, so both are inverted here and RISCV_Top stays active-high.

module CrossLinkNX_Top (
    input  wire       clk,     // 12 MHz board oscillator
    input  wire       rst_n,   // push button SW2, 0 when pressed
    output wire [7:0] led_n    // user LEDs, lit when driven 0
);

    wire [7:0] leds;

    RISCV_Top cpu (
        .clk   (clk),
        .reset (~rst_n),
        .leds  (leds)
    );


    assign led_n = ~leds;

endmodule