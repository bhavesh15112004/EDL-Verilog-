module crc_decoder #(
    parameter SYNC_WORD = 8'h47,
    parameter SYNC_LEN  = 8,
    parameter CRC_SIZE  = 8
)(
    input  wire        clk,
    input  wire        rst,
    input  wire        bit_in,
    input  wire        valid_in,
    output wire        valid_out,
    output reg         crc_valid,
    output reg         bit_out
);

    // Internal CRC register
    reg [CRC_SIZE-1:0] crc_reg;

    // Sync extraction registers
    reg [$clog2(SYNC_LEN)-1:0] sync_cnt;
    reg [7:0] sync_word = SYNC_WORD;

    // Cycle counter (0 to 79)
    integer cycle_cnt;

    // Feedback taps
    wire bit_in_w0;
    wire tap1, tap2, tap4, tap6;

    assign valid_out = valid_in;

    assign bit_in_w0 = crc_reg[0] ^ bit_in;
    assign tap1      = crc_reg[1] ^ bit_in_w0;
    assign tap2      = crc_reg[2] ^ bit_in_w0;
    assign tap4      = crc_reg[4] ^ bit_in_w0;
    assign tap6      = crc_reg[6] ^ bit_in_w0;

    always @(posedge clk) begin
        if (rst) begin
            crc_reg   <= 0;
            bit_out   <= 0;
            crc_valid <= 0;
            cycle_cnt <= 0;
            sync_cnt  <= SYNC_LEN - 1;
        end
        else if (valid_in) begin
            
            // CRC update
            crc_reg[7] <= bit_in_w0;
            crc_reg[6] <= crc_reg[7];
            crc_reg[5] <= tap6;
            crc_reg[4] <= crc_reg[5];
            crc_reg[3] <= tap4;
            crc_reg[2] <= crc_reg[3];
            crc_reg[1] <= tap2;
            crc_reg[0] <= tap1;

            // Sync word extraction (bit 72 to 79)
            if (cycle_cnt >= 72 && cycle_cnt < 80) begin
                bit_out <= sync_word[sync_cnt];
                sync_cnt <= sync_cnt - 1;

                if (cycle_cnt == 79) begin
                    sync_cnt  <= SYNC_LEN - 1;
                    crc_valid <= 1;
                    cycle_cnt <= 0;   // <<< RESET cycle counter HERE
                end
                else begin
                    cycle_cnt <= cycle_cnt + 1;
                    crc_valid <= 0;
                end
            end
            else begin
                bit_out <= bit_in;
                crc_valid <= 0;

                // Increment cycle counter during normal CRC period
                if (cycle_cnt < 79)
                    cycle_cnt <= cycle_cnt + 1;
            end
        end
    end

endmodule