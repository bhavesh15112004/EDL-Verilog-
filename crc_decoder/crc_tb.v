`timescale 1ns/1ps

module crc_decoder_tb;

    // === PARAMETERS ===
    parameter TEST_LENGTH = 20000;   // adjust based on your file length
    parameter CLK_PERIOD  = 10;    // 100MHz clock (10ns period)

    // === TB SIGNALS ===
    reg         clk;
    reg         rst;
    reg         bit_in;
    reg         valid_in;
    wire        valid_out;
    wire        crc_valid;
    wire        bit_out;

    // === STIMULUS MEMORY ===
    reg stimulus_mem [0:TEST_LENGTH-1];

    integer idx = 0;

    // === DUT INSTANCE ===
    crc_decoder dut (
        .clk       (clk),
        .rst       (rst),
        .bit_in    (bit_in),
        .valid_in  (valid_in),
        .valid_out (valid_out),
        .crc_valid (crc_valid),
        .bit_out   (bit_out)
    );

    // === CLOCK GENERATION ===
    always #(CLK_PERIOD/2) clk = ~clk;

    // === MAIN TB SEQUENCE ===
    initial begin
        $display("\n===== CRC DECODER TEST START =====\n");

        // Initialize signals
        clk      = 0;
        rst      = 1;
        valid_in = 0;
        bit_in   = 0;
      //  k_bch    = 8'd20;    // dummy value for now

        // Load stimulus file
        $readmemb("column_output.txt", stimulus_mem);
        $display("[TB] Loaded stimulus data from column_output.txt");

        // Apply Reset
        #(2*CLK_PERIOD);
        rst = 0;
        valid_in = 1;

        // Parallel execution
        fork
            feed_stimulus();
           // monitor_outputs();
        join

        $display("\n===== CRC DECODER TEST COMPLETE =====\n");
        $finish;
    end

    // === TASK: FEED INPUT STIMULUS ===
    task feed_stimulus;
        begin
            for(idx = 0; idx < TEST_LENGTH; idx = idx + 1) begin
                bit_in = stimulus_mem[idx];

                // Display what is being fed
                 $display("OUT  @%0t | IDX=%0d | IN=%b | OUT=%b | CRC_VALID=%b | REG=%b",
                        $time, idx, bit_in, bit_out, crc_valid, dut.crc_reg);

                #(CLK_PERIOD);
            end

            valid_in = 0;  // stop after feeding
             $finish;
             
        end
    endtask

    // === TASK: MONITOR OUTPUTS ===
   /* task monitor_outputs;
        begin
            forever begin
                @(posedge clk);

                if (valid_in) begin
                    $display("OUT  @%0t | IDX=%0d | IN=%b | OUT=%b | CRC_VALID=%b | REG=%b",
                        $time, idx, bit_in, bit_out, crc_valid, dut.crc_reg);
                end
            end
        end
    endtask
    */
    

endmodule