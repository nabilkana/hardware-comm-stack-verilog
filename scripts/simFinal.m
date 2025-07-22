%% Set single SNR value to test
snr_db = 5;

%% Parameters
num_samples = 5000;
sps = 8;
span = 6;
rolloff = 0.35;
tblen = 35;
trellis = poly2trellis(7, [171 133]);

%% Sensor + Huffman Encoding
sensor_data = 25 + 2*randn(1,num_samples);
sensor_data = min(max(sensor_data, 20), 30);
quantized_data = round((sensor_data - 20)*25.5);
symbols = 0:255;
counts = histcounts(quantized_data, 0:256);
probs = counts / length(quantized_data);
valid_idx = probs > 0;
valid_symbols = symbols(valid_idx);
valid_probs = probs(valid_idx);
[dict, ~] = huffmandict(valid_symbols, valid_probs);
dict_symbols = cell2mat(dict(:,1));
bitstream = [];
for i = 1:length(quantized_data)
    idx = find(dict_symbols == quantized_data(i), 1);
    bitstream = [bitstream dict{idx,2}];
end

%% ECC encode
coded_bits = convenc(bitstream, trellis);

%% Manchester encode
manchester = zeros(1, 2*length(coded_bits));
for i = 1:length(coded_bits)
    if coded_bits(i) == 0
        manchester(2*i-1:2*i) = [1 0];
    else
        manchester(2*i-1:2*i) = [0 1];
    end
end
preamble = repmat([1 1 0 0], 1, 4);
tx_bits = [preamble manchester];
if mod(length(tx_bits), 2), tx_bits(end+1) = 0; end

%% QPSK modulation
gray_map = [0 0; 0 1; 1 1; 1 0];
constellation = [1+1j -1+1j -1-1j 1-1j]/sqrt(2);
bit_pairs = reshape(tx_bits, 2, []).';
modulated_signal = zeros(1, size(bit_pairs,1));
for k = 1:size(bit_pairs,1)
    [~, idx] = ismember(bit_pairs(k,:), gray_map, 'rows');
    modulated_signal(k) = constellation(idx);
end

%% Pulse shaping + AWGN
rrc = rcosdesign(rolloff, span, sps);
upsampled = upsample(modulated_signal, sps);
tx_signal = conv(upsampled, rrc, 'full');







rx_signal = awgn(tx_signal, snr_db, 'measured');
rx_filtered = conv(rx_signal, rrc, 'full');


L = length(rrc);
delay = L - 1;  % Filter delay

% Remove filter delay to align signal
aligned_signal = rx_filtered(delay+1:end);

% Now plot the eye diagram on the aligned signal
% Use 2*sps samples per eye (2 symbols per eye)
num_symbols_to_plot = 100;  % Plot 10 symbols
num_samples = 2 * sps * num_symbols_to_plot;

eyediagram(aligned_signal(1:num_samples), 2*sps);
title('Eye Diagram After Matched Filtering (Aligned)');
xlabel('Sample Number');
ylabel('Amplitude');
grid on;



%% Symbol sampling
delay = length(rrc) - 1;
start_idx = delay + 1;
end_idx = start_idx + sps * (size(bit_pairs,1) - 1);
if end_idx > length(rx_filtered)
    end_idx = length(rx_filtered);
end
downsampled = rx_filtered(start_idx:sps:end_idx);

%% QPSK demodulation
demod_bits = zeros(length(downsampled), 2);
for k = 1:length(downsampled)
    [~, idx] = min(abs(downsampled(k) - constellation));
    demod_bits(k,:) = gray_map(idx,:);
end
demod_stream = reshape(demod_bits.', 1, []);

%% Strip preamble and compute raw BER
payload_start = length(preamble)+1;
payload_end = min(length(tx_bits), length(demod_stream));
raw_payload = tx_bits(payload_start:payload_end);
rx_payload  = demod_stream(payload_start:payload_end);
ber_raw = sum(raw_payload ~= rx_payload) / length(raw_payload);
fprintf("\nSNR = %d dB ---\n", snr_db);
fprintf(" Raw BER (pre-Viterbi): %.6f (%d bit errors)\n", ber_raw, sum(raw_payload ~= rx_payload));

%% Manchester decode
if mod(length(rx_payload), 2), rx_payload(end) = []; end
pairs = reshape(rx_payload, 2, []);
huffman_bits = zeros(1, size(pairs,2));
nan_idx = [];
for i = 1:size(pairs,2)
    p = pairs(:,i).';
    if isequal(p, [1 0])
        huffman_bits(i) = 0;
    elseif isequal(p, [0 1])
        huffman_bits(i) = 1;
    else
        nan_idx(end+1) = i;
        huffman_bits(i) = 0; % replace invalid pair with 0
    end
end
if ~isempty(nan_idx)
    fprintf("️  Manchester decode: %d invalid pairs replaced with 0\n", length(nan_idx));
end

%% Viterbi decode
decoded_bits = vitdec(huffman_bits, trellis, tblen, 'trunc', 'hard');

%% ECC BER
len = min(length(bitstream), length(decoded_bits));
ber_viterbi = sum(bitstream(1:len) ~= decoded_bits(1:len)) / len;
fprintf(" BER after Viterbi: %.6f (%d bit errors)\n", ber_viterbi, sum(bitstream(1:len) ~= decoded_bits(1:len)));
%% Huffman decode → SER
decoded_symbols = huffmandeco(decoded_bits, dict);
minlen = min(length(decoded_symbols), length(quantized_data));
ser = sum(decoded_symbols(1:minlen) ~= quantized_data(1:minlen)) / minlen;
fprintf(" Symbol Error Rate (SER): %.6f\n", ser);

%% bandwidth 
T = 1;  % (You can set this according to your system)
effective_bit_rate = encoded_bits_length / T;  % bits per second after source coding

% Calculate symbol rate based on bits per symbol
symbol_rate = effective_bit_rate / bits_per_symbol;

% Calculate bandwidth based on roll-off factor
bandwidth = symbol_rate * (1 + rolloff);

% Display results
fprintf('Effective bit rate after source coding: %.2f bps\n', effective_bit_rate);
fprintf('Symbol rate: %.2f symbols/sec\n', symbol_rate);
fprintf('Estimated bandwidth required: %.2f Hz\n', bandwidth);