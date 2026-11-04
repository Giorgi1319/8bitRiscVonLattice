// Top module for simulating the CPU in VS Code's HDL Studio (DigitalJS).
// HDL Studio turns the 1-bit input named clk into a running clock, reset
// into a toggle button, each 1-bit output into a lamp and the leds bus
// into a number display.

module HDLStudio_Top (
    input  wire       clk,
    input  wire       reset,
    output wire [7:0] leds,
    output wire       led1,
    output wire       led2,
    output wire       led3,
    output wire       led4,
    output wire       led5,
    output wire       led6,
    output wire       led7
);

    RISCV_Top cpu (
        .clk   (clk),
        .reset (reset),
        .leds  (leds)
    );

    assign {led7, led6, led5, led4, led3, led2, led1} = leds[7:1];

endmodule
