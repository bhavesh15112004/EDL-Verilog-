% ============================================
% CRC-8 Frame Builder for 72-bit blocks
% Polynomial: x^8 + x^7 + x^6 + x^4 + x^2 + 1
% Input:  long_input.txt (column bits)
% Output: column_output.txt (column bits)
% ============================================

clc; clear;

% ----- Load input bits -----

data = dlmread('long_input.txt');   % column bits (0/1)
data = data(:)';                    % convert to row

% Check blocks
N = length(data);
num_blocks = floor(N/72);

%disp(num_blocks*N);

fprintf("Total bits = %d | Blocks = %d\n", N, num_blocks);

% CRC polynomial taps (excluding x^8)
taps = [7 6 4 2 0];

% Accumulate full output as characters
final_str = "";

% =====================================
% Process each 72-bit block
% =====================================
for blk = 1:num_blocks
    
    % Extract 72 bits
    start_idx = (blk-1)*72 + 1;
    end_idx = start_idx + 71;
    block = data(start_idx:end_idx);

    % ==== Compute CRC-8 ====
    reg = zeros(1,8); % init 8-bit register
    
    for i = 1:72
        in_bit = block(i);
        fb = xor(in_bit, reg(1));
        reg(1:7) = reg(2:8);
        reg(8) = 0;
        for t = taps
            reg(8-t) = xor(reg(8-t), fb);
        end
    end
    
    crc_bits = reg; % MSB -> LSB

    % Convert to strings
    block_str = sprintf('%d', block);
    crc_str   = sprintf('%d', crc_bits);

    % Add to final buffer
    final_str = final_str + block_str + crc_str;
end


% Save final output in COLUMN FORMAT
% =====================================
bits = char(final_str) - '0'; % convert to numeric 0/1
disp(length(bits));
fid = fopen('column_output.txt', 'w');
for k = 1:length(bits)
    fprintf(fid, '%d\n', bits(k));
end
fclose(fid);

fprintf("Done! Saved formatted output to column_output.txt\n");
