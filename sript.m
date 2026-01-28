% --- DATA GENERATOR ---
num_bits = 200000; % Total bits to test
file_path = 'long_input.txt';

% 1. Generate a random binary sequence
input_data = randi([0, 1], 1, num_bits);

% 2. Save the raw input bits for Verilog
fid_in = fopen(file_path, 'w');
if fid_in == -1
    error('Could not open file at path. Check permissions or folder existance.');
end
fprintf(fid_in, '%d\n', input_data);
fclose(fid_in);

disp(['SUCCESS: Generated ', num2str(num_bits), ' bits in long_input.txt']);
