`timescale 1ns / 1ps

module BB_Descrambler_tb;

    parameter TEST_LENGTH = 200000; 

    reg clk;
    reg rst;
    reg bit_stream_in;
    reg valid_in;
    reg [15:0] K_BCH;
    wire valid_out;
    wire bit_stream_out;
    
    reg stimulus_mem [0:TEST_LENGTH-1];
    reg expected_mem [0:TEST_LENGTH-1];
    
    BB_Descrambler dut (
        .clk(clk),
        .rst(rst),
        .bit_stream_in(bit_stream_in),
        .valid_in(valid_in),
        .K_BCH(K_BCH),
        .valid_out(valid_out),
        .bit_stream_out(bit_stream_out)
    );

    always #5 clk = ~clk;
    
    integer i = 0; 
    integer error_count = 0;
    
    initial begin
        $readmemb("input.txt", stimulus_mem);
        $readmemb("output.txt", expected_mem);
        
        clk = 0;
        rst = 1;
        //bit_stream_in = 0; 
        valid_in = 0;
        K_BCH = 16'd200;
        
        $display("--- Starting Long Sequence Test ---");
        
        #15
        rst = 0;
        valid_in = 1;

    end
    
    always @(posedge clk) begin
        
        //if(valid_in==1)begin
            bit_stream_in <= stimulus_mem[i];
            
            // --- PRINT MONITOR (Your original format) ---
            $display("Time=%0t i=%d in=%b out=%b reg=%b cnt=%d w0=%b w1=%b sum_w0_w1=%b", 
                      $time, i,bit_stream_in, bit_stream_out, dut.register, 
                      dut.bit_counter, dut.w0, dut.w1, dut.sum_w0_w1);

             //Automated Comparison
            if (i > 0) begin
              if (bit_stream_out !== expected_mem[i-1]) begin
                   $display(">>> ERROR at bit %d: RTL=%b, MATLAB=%b <<<", 
                             i-1, bit_stream_out, expected_mem[i-1]);
                    error_count = error_count + 1;
                end
             end

             
            
         //   $display("bit_out=%b, mem=%b",bit_stream_out, expected_mem[i-1]);

            i <= i + 1;
            
            $display("i=%d",i);
            if (i == TEST_LENGTH) begin
                #10;
                $display("--- Test Completed ---");
                $display("Total Checked: %d, Total Errors: %d", TEST_LENGTH, error_count);
                if (error_count == 0) $display("SUCCESS: RTL matches MATLAB perfectly!");
                $finish;
            end

            


    end
    

endmodule

