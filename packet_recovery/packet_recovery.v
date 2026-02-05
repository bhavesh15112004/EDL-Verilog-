module packet_recovery #(
    parameter integer SYNC_LEN   = 8,          // Sync word length (bits)
    parameter [SYNC_LEN-1:0] SYNC_WORD = 8'h47,// Sync pattern
    parameter integer CRC_SIZE   = 8,          // CRC length
    parameter integer PKT_BITS   = 1504,         // Total packet length
    parameter integer SYNC_START = 1496          // Sync start bit index
)(
    input  wire clk,
    input  wire rst,
    input  wire bit_in,
    input  wire valid_in,

    output wire valid_out,
    output reg  crc_valid,
    output reg  bit_out
);

    // ------------------------------------------------------------
    // Local parameters
    // ------------------------------------------------------------
    localparam integer CNT_W = $clog2(PKT_BITS);
    localparam integer SYNC_W = $clog2(SYNC_LEN);

    // ------------------------------------------------------------
    // Registers
    // ------------------------------------------------------------
    reg [CRC_SIZE-1:0] crc_reg;
    reg [CNT_W-1:0]    cycle_cnt;
    reg [SYNC_W-1:0]   sync_cnt;

    // ------------------------------------------------------------
    // CRC feedback logic (example polynomial)
    // ------------------------------------------------------------
    wire bit_in_w0 = crc_reg[0] ^ bit_in;

    wire tap1 = crc_reg[1] ^ bit_in_w0;
    wire tap2 = crc_reg[2] ^ bit_in_w0;
    wire tap4 = crc_reg[4] ^ bit_in_w0;
    wire tap6 = crc_reg[6] ^ bit_in_w0;

    assign valid_out = valid_in;

    // ------------------------------------------------------------
    // Sequential logic
    // ------------------------------------------------------------
    always @(posedge clk) begin
        if (rst) begin
            crc_reg   <= '0;
            bit_out   <= 1'b0;
            crc_valid <= 1'b0;
            cycle_cnt <= '0;
            sync_cnt  <= SYNC_LEN - 1;
        end
        else if (valid_in) begin

            // ---------------- CRC Update ----------------
            crc_reg[7] <= bit_in_w0;
            crc_reg[6] <= crc_reg[7];
            crc_reg[5] <= tap6;
            crc_reg[4] <= crc_reg[5];
            crc_reg[3] <= tap4;
            crc_reg[2] <= crc_reg[3];
            crc_reg[1] <= tap2;
            crc_reg[0] <= tap1;

            // ---------------- Packet Handling ----------------
            if (cycle_cnt >= SYNC_START && cycle_cnt < PKT_BITS) begin
                // Sync word replacement
                bit_out <= SYNC_WORD[sync_cnt];
                sync_cnt <= sync_cnt - 1;

                if (cycle_cnt == PKT_BITS - 1) begin
                    cycle_cnt <= '0;
                    sync_cnt  <= SYNC_LEN - 1;
                    crc_valid <= 1'b1;
                end
                else begin
                    cycle_cnt <= cycle_cnt + 1'b1;
                    crc_valid <= 1'b0;
                end
            end
            else begin
                // Normal payload bits
                bit_out   <= bit_in;
                crc_valid <= 1'b0;

                if (cycle_cnt < PKT_BITS - 1)
                    cycle_cnt <= cycle_cnt + 1'b1;
            end
        end
    end

endmodule
