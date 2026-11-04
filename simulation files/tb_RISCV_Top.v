module tb_RISCV_Top;

    reg        clk   = 1'b0;
    reg        reset = 1'b1;
    wire [7:0] leds;

    RISCV_Top dut (
        .clk   (clk),
        .reset (reset),
        .leds  (leds)
    );

    always #5 clk = ~clk;

    // register values as named wires so they show up in the waveform
    wire [7:0] x0 = dut.rf.registers[0];
    wire [7:0] x1 = dut.rf.registers[1];
    wire [7:0] x2 = dut.rf.registers[2];
    wire [7:0] x3 = dut.rf.registers[3];
    wire [7:0] x4 = dut.rf.registers[4];
    wire [7:0] x5 = dut.rf.registers[5];
    wire [7:0] x6 = dut.rf.registers[6];
    wire [7:0] x7 = dut.rf.registers[7];

    integer i;
    integer errors = 0;

    task check_reg;
        input [2:0] idx;
        input [7:0] expected;
        begin
            if (dut.rf.registers[idx] !== expected) begin
                $display("FAIL: x%0d = %0d, expected %0d", idx, dut.rf.registers[idx], expected);
                errors = errors + 1;
            end
        end
    endtask

    initial begin
        $dumpfile("cpu.vcd");
        $dumpvars(0, tb_RISCV_Top);
    end

    initial begin
        $monitor("t=%0t  PC=%0d  Instr=%h  leds=%b", $time, dut.PC, dut.Instr, leds);

        #12 reset = 1'b0;
        #200;

        $display("");
        for (i = 0; i < 8; i = i + 1)
            $display("x%0d = %0d", i, dut.rf.registers[i]);

        check_reg(1, 8'd0);
        check_reg(2, 8'd2);
        check_reg(3, 8'd3);
        check_reg(7, 8'd7);

        if (leds !== 8'b10001100) begin
            $display("FAIL: leds = %b, expected 10001100", leds);
            errors = errors + 1;
        end

        if (errors == 0) $display("\nPASS");
        else             $display("\n%0d check(s) FAILED", errors);

        $finish;
    end

endmodule
