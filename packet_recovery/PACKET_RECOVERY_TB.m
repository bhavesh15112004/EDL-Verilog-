% -------------------------------------------------------------------------
% Packet Recovery Verification (Final Version)
% -------------------------------------------------------------------------
clear; clc;

% --- Parameters ---
SYNC_LEN   = 8;
SYNC_WORD  = hex2dec('47'); % 0x47
PKT_BITS   = (188*8);
SYNC_START = (187*8);

% --- File I/O ---
try
    input_data = load('input.txt'); 
catch
    error('Error: input.txt not found.');
end

num_bits = length(input_data);
output_bits = zeros(num_bits, 1);

% --- Registers (Initial State) ---
crc_reg   = uint8(0);      
cycle_cnt = 0;             
sync_cnt  = SYNC_LEN - 1; 

fprintf('Processing %d bits...\n', num_bits);
fprintf('----------------------------------------------------------------------\n');
fprintf('DEBUG: Printing Register State for critical transitions only...\n');
fprintf('Format: [Bit Index] | In | Cycle | SyncCnt | CRC_Reg (Hex) | Out | Valid\n');
fprintf('----------------------------------------------------------------------\n');

for i = 1:num_bits
    bit_in = input_data(i);
    
    % --- 1. Combinational Logic (Next CRC Calculation) ---
    bit_in_w0 = bitxor(bitget(crc_reg, 1), bit_in);
    
    tap1 = bitxor(bitget(crc_reg, 2), bit_in_w0);
    tap2 = bitxor(bitget(crc_reg, 3), bit_in_w0);
    tap4 = bitxor(bitget(crc_reg, 5), bit_in_w0);
    tap6 = bitxor(bitget(crc_reg, 7), bit_in_w0);
    
    next_crc_reg = uint8(0);
    next_crc_reg = bitset(next_crc_reg, 8, bit_in_w0);          
    next_crc_reg = bitset(next_crc_reg, 7, bitget(crc_reg, 8)); 
    next_crc_reg = bitset(next_crc_reg, 6, tap6);               
    next_crc_reg = bitset(next_crc_reg, 5, bitget(crc_reg, 6)); 
    next_crc_reg = bitset(next_crc_reg, 4, tap4);               
    next_crc_reg = bitset(next_crc_reg, 3, bitget(crc_reg, 4)); 
    next_crc_reg = bitset(next_crc_reg, 2, tap2);               
    next_crc_reg = bitset(next_crc_reg, 1, tap1);               

    % --- 2. Packet Handling Logic ---
    current_bit_out = 0;
    current_crc_valid = 0;
    
    % Check if we are in the Sync Word Replacement Zone (72-79)
    if (cycle_cnt >= SYNC_START && cycle_cnt < PKT_BITS)
        % Replace output with Sync Word (0x47)
        current_bit_out = bitget(SYNC_WORD, sync_cnt + 1);
        sync_cnt = sync_cnt - 1; 
        
        % End of Packet Logic
        if (cycle_cnt == PKT_BITS - 1)
            cycle_cnt = 0;
            sync_cnt  = SYNC_LEN - 1;
            current_crc_valid = 1; % Valid High at end
        else
            cycle_cnt = cycle_cnt + 1;
            current_crc_valid = 0;
        end
    else
        % Normal Payload
        current_bit_out = bit_in;
        current_crc_valid = 0;
        if (cycle_cnt < PKT_BITS - 1)
            cycle_cnt = cycle_cnt + 1;
        end
    end

    % --- 3. CONSOLE PRINTING (Selective) ---
    % Print only the first 5 bits AND the transition bits (70 to 82)
    % so you can see the sync replacement happening without spamming the log.
    if (i <= 5 || (i >= 70 && i <= 82))
        fprintf('[%4d]      |  %d |  %2d   |    %d    |      %02X       |  %d  |   %d\n', ...
            i, bit_in, cycle_cnt, sync_cnt+1, crc_reg, current_bit_out, current_crc_valid);
    end

    % --- 4. Update State ---
    crc_reg = next_crc_reg; 
    output_bits(i) = current_bit_out;
end

% --- Write Output File (Just the data) ---
fid = fopen('output.txt', 'w');
fprintf(fid, '%d\n', output_bits);
fclose(fid);

fprintf('----------------------------------------------------------------------\n');
fprintf('Success! All %d bits processed.\n', num_bits);
fprintf('Clean output saved to "output.txt".\n');


