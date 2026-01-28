`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.01.2026 19:38:09
// Design Name: 
// Module Name: BB_Descrambler
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps

module BB_Descrambler (
    input clk,
    input rst,
    input bit_stream_in,
    input valid_in,
    input [15:0] K_BCH, // Kbch is an integer how are you passing it using one bit ??? 
    output valid_out,
    output bit_stream_out
);

    parameter INIT_STATE = 15'b100101010000000;
    
    reg [14:0] register;
    reg [15:0] bit_counter;
    wire w0, w1, sum_w0_w1;
    
    assign w0 = register[0];
    assign w1 = register[1];
    assign sum_w0_w1 = w0 ^ w1;
    assign bit_stream_out = bit_stream_in ^ sum_w0_w1;
    assign valid_out = valid_in;
    
    always @(posedge clk) begin
        if (rst) begin
            register <= INIT_STATE;
            bit_counter <= 16'd0;
            
        end
        else if (valid_in) begin
            if (bit_counter == K_BCH - 1) begin
                register <= INIT_STATE;
                bit_counter <= 16'd0;
                 
            end
            else begin
                register <= {sum_w0_w1, register[14:1]};
                bit_counter <= bit_counter + 1;
             
            end
        end
    end

endmodule














