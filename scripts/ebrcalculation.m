origFile = 'OriginalBitst.txt';  
fid = fopen(origFile, 'r');
origBits = fscanf(fid, '%d');
fclose(fid);

decodedFile = 'decoded_outputburst20db.txt'; 
fid = fopen(decodedFile, 'r');
decodedBits = fscanf(fid, '%d');
fclose(fid);

if length(origBits) ~= length(decodedBits)
    error('Bit sequences lengths do not match! Check files.');
end

errors = sum(origBits ~= decodedBits);

% Calculate EBR
ebr = errors / length(origBits);

fprintf('Total bits: %d\n', length(origBits));
fprintf('Number of errors: %d\n', errors);
fprintf('EBR (Error Bit Rate)  with burst error at 20db : %.6f\n', ebr);