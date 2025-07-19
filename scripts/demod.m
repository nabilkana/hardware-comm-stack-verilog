filename = 'qamt16sym_output.txt'; 
SNR_dB = 5;  

% --- READ DATA ---
fid = fopen(filename,'r');
if fid == -1
    error('Cannot open input file.');
end

time = [];
I_raw = [];
Q_raw = [];

while true
    line = fgetl(fid);
    if ~ischar(line)
        break; % EOF
    end
    if isempty(line)
        continue;
    end
    
    tokens = regexp(line, '(\d+), I =\s*(-?\d+), Q =\s*(-?\d+)', 'tokens');
    if ~isempty(tokens)
        time(end+1) = str2double(tokens{1}{1});
        I_raw(end+1) = str2double(tokens{1}{2});
        Q_raw(end+1) = str2double(tokens{1}{3});
    end
end
fclose(fid);

% --- NORMALIZE ---
I_norm = I_raw / 3;
Q_norm = Q_raw / 3;
rxSymbols = I_norm + 1i*Q_norm;

% --- ADDOISE 
rxSymbols_noisy = awgn(rxSymbols, SNR_dB, 'measured');

I_rx = real(rxSymbols_noisy) * 3;
Q_rx = imag(rxSymbols_noisy) * 3;

decode_axis = @(v) ...
    (v < -2) * 0 + ...         % bits '00' -> decimal 0
    (v >= -2 & v < 0) * 1 + ... % bits '01' -> decimal 1
    (v >= 0 & v < 2) * 3 + ...  % bits '11' -> decimal 3
    (v >= 2) * 2;               % bits '10' -> decimal 2

I_dec = decode_axis(I_rx);
Q_dec = decode_axis(Q_rx);

lut = [0 0; 0 1; 1 0; 1 1];

I_bits = lut(I_dec + 1, :); 
Q_bits = lut(Q_dec + 1, :);

bitsOut = [I_bits Q_bits];  

outFilename = 'demodulated_matched_bits5db.txt';
fid_out = fopen(outFilename, 'w');
for k = 1:size(bitsOut,1)
    fprintf(fid_out, '%d%d%d%d\n', bitsOut(k,1), bitsOut(k,2), bitsOut(k,3), bitsOut(k,4));
end
fclose(fid_out);

disp(['Processed ', num2str(length(I_raw)), ' symbols.']);
disp(['Demodulated bits saved to ', outFilename]);
