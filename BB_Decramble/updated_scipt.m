% =========================================================================
%           DVB-S2 Scrambler (File I/O + Kbch Reset)
% =========================================================================

% --- PARAMETERS ---
display_limit = 50;      % Number of lines to print to console (for checking)
Kbch = 200;               % Length of one BBFRAME (Change this to your actual size)
input_filename = 'input.txt';
output_filename = 'output.txt';

% --- 1. Load Data ---
try
    data_in = load(input_filename);
    
    % Validation: Ensure it is a column vector
    if size(data_in, 2) > 1
        data_in = data_in(:); 
    end
    
    % Validation: Ensure bits are binary
    if any(data_in ~= 0 & data_in ~= 1)
        error('File contains values other than 0 or 1.');
    end
catch
    error(['Could not find or read ' input_filename]);
end

total_bits = length(data_in);
fprintf('Loaded %d bits.\n', total_bits);
fprintf('Parameters: Kbch = %d, Writing output to "%s"\n\n', Kbch, output_filename);

% --- 2. Initialize ---
% Standard Initial Sequence: 100101010000000
initial_state = [1 0 0 1 0 1 0 1 0 0 0 0 0 0 0]; 
regs = initial_state; 
scrambled_output = zeros(total_bits, 1);

% --- 3. Processing Loop ---
disp('-------------------------------------------------------------------------');
fprintf('%-6s | %-6s | %-35s | %-6s\n', 'Step', 'Input', 'Register State (r1...r15)', 'Output');
disp('-------------------------------------------------------------------------');

for i = 1:total_bits
    
    % A. Capture current State (for printing)
    if i <= display_limit
        current_regs_str = sprintf('%d', regs);
    end
    
    % B. Calculate Feedback (Polynomial: 1 + X^14 + X^15)
    r14 = regs(14);
    r15 = regs(15);
    prbs_bit = xor(r14, r15); 
    
    % C. Calculate Output
    input_bit = data_in(i);
    output_bit = xor(input_bit, prbs_bit);
    scrambled_output(i) = output_bit;
    
    % D. Print to Console (Controlled by display_limit)
    if i <= display_limit
        fprintf('%-6d | %-6d | %-35s | %-6d\n', i, input_bit, current_regs_str, output_bit);
    end
    
    % E. Update Registers (Shift Right)
    regs = [prbs_bit, regs(1:14)];
    
    % F. Reset Logic (End of Frame)
    if mod(i, Kbch) == 0
        regs = initial_state;
        if i < display_limit
            fprintf('--- End of BBFRAME (bit %d). Registers Reset. ---\n', i);
        end
    end
end

if total_bits > display_limit
    fprintf('... (Output truncated in console. All bits processed internally)\n');
end

% --- 4. Save to Output File ---
try
    % writematrix saves the vector as a column of numbers
    writematrix(scrambled_output, output_filename);
    fprintf('\nSuccess! All %d scrambled bits saved to %s.\n', total_bits, output_filename);
catch
    % Fallback for older MATLAB versions
    fid = fopen(output_filename, 'w');
    fprintf(fid, '%d\n', scrambled_output);
    fclose(fid);
    fprintf('\nSuccess! All %d scrambled bits saved to %s (using fallback).\n', total_bits, output_filename);
end

