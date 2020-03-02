%%
% read raw LFP data from the parsed ch.dat binary file


%{
play ground
dat_fn = ...
'R:\tritsn01lab\tritsn01labspace\Haixin\Ephys\Data_Processed\HL120\ChR2LFP_DCS_1msPulseDark_2020-02-11_12-46-25_experiment1_recording1\Ch_data.dat'


data_raw

data_raw = reshape(data_raw, 128, length(data_raw)/128);
figure; hold on;
for ii = 33:96 %1:size(data_raw,1)
plot(data_raw(ii,1:300000)+ 500*(ii-1))
end

%}

%%
function [raw_data] = HL_Ephys_GetLFPfromChDATfile(dat_fn, nChanTot, ch_idx, sr, bit_volts, PC_params)
warning('This function does not take into account if the single channel data is larger than available memory')
%% define default parameters
if nargin < 4
bit_volts = 0.19499999284744263; % micro volt, 16 bit uint, also from structure.ob file
sr = 30000; % default setting of open ephys recording
elseif nargin < 5
    bit_volts = 0.19499999284744263; % micro volt
end

if exist(dat_fn, 'file') ~= 2
    error('Ch.dat file not found');
end


fid = fopen(dat_fn, 'r');  %file indentifier from selected .dat, use read only mode
% data_raw = fread(fid, 'int16');  %read from file identifier (fid), must specify 'int16'
% fclose(fid);
%% PC parameters 
if nargin < 6
    disp('Use default memory allocation 70% of Max memory')
    temp_mem = memory;
    PC_params.portion = 0.7;%temp_mem.MaxPossibleArrayBytes;
    buff = temp_mem.MaxPossibleArrayBytes / ((16 * nChanTot));
else    
    amtMemTot = PC_params.memory; %str2double(usrInput{2}); % Available computer memory in GB
    amtMemUsed = amtMemTot * PC_params.portion; %str2double(usrInput{3}); % MATLAB will use 1/4 of the total memory to store values
    buff = (amtMemUsed * 10^9) / (16 * nChanTot); % Convert memory to bits and bits to number of integers
end

%% data
raw_data = [];
disp('Reading ...')
temp = []; %Variable to temporarily store dat data while parsing

%The following while loop will go through the original data file and
%incremently store data into a temporary variable (temp). Then the temp
%variable will be parsed and the three types of data wil be written to
%their respective files.

%NOTE: feof is a function that asks if a file pointer is at the end of the
%file. The while loop will iterate as long as we haven't reached the end of
%the original data file
round_n = 1;
while(~feof(fid))
    disp(['Round #', num2str(round_n)]); round_n = round_n+1;
    temp = fread(fid,[nChanTot,buff],'int16'); %Store all "channel data" from a certain 
    %buffer size into a variable called temp

    % record the temp into raw_data 
    raw_data = cat(2, raw_data, temp(ch_idx, :));
    temp = [];
end

fclose(fid);

%%  and convert to uV
raw_data = raw_data.*bit_volts;
