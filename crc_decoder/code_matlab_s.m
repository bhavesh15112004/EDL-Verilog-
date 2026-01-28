% ================================
% CRC-8 Register Simulation
% Polynomial: X8 + X7 + X6 + X4 + X2 + 1
% Input format: column bits in input.txt (one bit per line)
% ================================

clc; clear;

% ---- Load input bits from file ----
data = dlmread('long_input.txt'); % reads column numbers like 1,0,1,...

% Ensure data is 0/1 numeric
data = data(:)';  % Make into row vector if needed

% ---- CRC polynomial taps (excluding X^8) ----
% polynomial: x^8 + x^7 + x^6 + x^4 + x^2 + 1
taps = [7 6 4 2 0];

% ---- Initialize 8-bit register ----
reg = zeros(1,8);

fprintf('Initial Register: %s\n', num2str(reg));

% ---- Process each input bit ----
for i = 1:200
    
    in_bit = data(i);
    
    % Feedback: MSB XOR input
    fb = xor(in_bit, reg(1));
    
    % Shift register left
    reg(1:7) = reg(2:8);
    reg(8) = 0;
    
    % Apply feedback on tap positions
    for t = taps
        reg(8-t) = xor(reg(8-t), fb);
    end
    
    % Print register value
    fprintf('After bit %d (%d): %s\n', i, in_bit, reverse(num2str(reg)));
end
