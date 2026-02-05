`timescale 1ns/1ps

module packet_recovery_tb;

    parameter TEST_LENGTH = 200000;
    parameter CLK_PERIOD  = 10;

    reg         clk;
    reg         rst;
    reg         bit_in;
    reg         valid_in;
    wire        valid_out;
    wire        crc_valid;
    wire        bit_out;

    reg stimulus_mem [0:TEST_LENGTH-1];
    reg out_mem      [0:TEST_LENGTH-1];

    integer idx;
    integer i;
    integer error_count;

    reg expected_d;

    packet_recovery dut (
        .clk       (clk),
        .rst       (rst),
        .bit_in    (bit_in),
        .valid_in  (valid_in),
        .valid_out (valid_out),
        .crc_valid (crc_valid),
        .bit_out   (bit_out)
    );

    always #(CLK_PERIOD/2) clk = ~clk;

    initial begin
        clk         = 0;
        rst         = 1;
        valid_in    = 0;
        bit_in      = 0;
        idx         = 0;
        i           = 0;
        error_count = 0;

        $readmemb("input.txt", stimulus_mem);
        $readmemb("output.txt", out_mem);

        #(2*CLK_PERIOD);
        rst = 0;
        valid_in = 1;

        fork
            feed_stimulus;
            monitor;
        join

        $finish;
    end

    task feed_stimulus;
        begin
            for (idx = 0; idx < TEST_LENGTH; idx = idx + 1) begin
                bit_in = stimulus_mem[idx];
                #(CLK_PERIOD);
            end
            valid_in = 0;
        end
    endtask
task monitor;
    begin
        while (i < TEST_LENGTH) begin
            @(posedge clk);
            if (valid_out) begin
                if (i > 0) begin
                    expected_d = out_mem[i-1];
                    if (bit_out !== expected_d)
                        error_count = error_count + 1;
                    $display("%b %b", bit_out, expected_d);
                end
                i = i + 1;
            end
        end
        $display("ERROR_COUNT=%0d", error_count);
    end
endtask


endmodule
