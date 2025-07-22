%% Parameters
num_samples = 5000;
sps = 8;
span = 6;
rolloff = 0.35;
snr_values = -5:1:12;
ber_raw = zeros(size(snr_values));
ser_vals = zeros(size(snr_values));

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

for snr_idx = 1:length(snr_values)
    snr_db = snr_values(snr_idx);

    %% Manchester encode
    manchester = zeros(1, 2*length(bitstream));
    for i = 1:length(bitstream)
        if bitstream(i) == 0
            manchester(2*i-1:2*i) = [1 0];
        else
            manchester(2*i-1:2*i) = [0 1];
        end
    end
    preamble = repmat([1 1 0 0], 1, 4);
    tx_bits = [preamble manchester];
    if mod(length(tx_bits), 2), tx_bits(end+1) = 0; end

    %% QPSK
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

    %% Symbol sampling
    delay = length(rrc) - 1;
    start_idx = delay + 1;
    end_idx = start_idx + sps * (size(bit_pairs,1) - 1);
    if end_idx > length(rx_filtered)
        end_idx = length(rx_filtered);
    end
    downsampled = rx_filtered(start_idx:sps:end_idx);

    %% Demodulate
    demod_bits = zeros(length(downsampled), 2);
    for k = 1:length(downsampled)
        [~, idx] = min(abs(downsampled(k) - constellation));
        demod_bits(k,:) = gray_map(idx,:);
    end
    demod_stream = reshape(demod_bits.', 1, []);

    %% Strip preamble and calculate raw BER
    payload_start = length(preamble)+1;
    payload_end = min(length(tx_bits), length(demod_stream));
    raw_payload = tx_bits(payload_start:payload_end);
    rx_payload  = demod_stream(payload_start:payload_end);
    ber_raw(snr_idx) = sum(raw_payload ~= rx_payload) / length(raw_payload);
    fprintf("\nSNR = %d dB ---\n", snr_db);
    fprintf("⚠  Raw BER: %.6f (%d bit errors)\n", ber_raw(snr_idx), sum(raw_payload ~= rx_payload));

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

    %% Huffman decode → SER
    decoded_symbols = huffmandeco(huffman_bits, dict);
    minlen = min(length(decoded_symbols), length(quantized_data));
    ser_vals(snr_idx) = sum(decoded_symbols(1:minlen) ~= quantized_data(1:minlen)) / minlen;
    fprintf(" Symbol Error Rate: %.6f\n", ser_vals(snr_idx));
end

%% Plot
figure;
plot(snr_values, ber_raw, '--o', 'DisplayName', 'Raw BER (No ECC)');
hold on;
plot(snr_values, ser_vals, '-^', 'DisplayName', 'Symbol Error Rate');
xlabel('SNR (dB)'); ylabel('Error Rate'); grid on;
legend;
title('Error Rates vs SNR (Manchester + Huffman + QPSK — No ECC)');