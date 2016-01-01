function bv_splitWsPerFreq(cfg, resultsName)

freqLabels  = ft_getopt(cfg, 'freqLabels',{'delta', 'theta', 'alpha1', 'alpha2', 'beta', 'gamma'});
freqRanges  = ft_getopt(cfg, 'freqRanges',{[1 3], [3 6], [6 9], [9 12], [12 25], [25 45]});

if length(freqLabels) ~= length(freqRanges)
    error('freqRange and freqLabels not equal')
end
if nargin < 2
    error('No input for (path to) results file')
end
if nargin < 1
    error('No configuration file added')
end

try 
    [PATHS.RESULTS, filename, ~] = fileparts(resultsName);
    fprintf('loading %s ... ', filename)
    load(resultsName)
    fprintf('done! \n')
catch
    error('%s not found', resultsName)
end

if isempty(PATHS.RESULTS)
    PATHS.RESULTS = pwd;
end

origWs = Ws;
origDims = dims;

for iFreq = 1:length(freqRanges)
    cLabel = freqLabels{iFreq};
    cRange = freqRanges{iFreq};
    
    freqband = cLabel;
    
    startIndx = find(freq == cRange(1));
    endIndx = find(freq == cRange(2));
    
    Ws = squeeze(mean(origWs(:,:,startIndx:endIndx,:,:),3));
    
    dims = strsplit(origDims, '-');
    dims(3) = [];
    Wsdims = strjoin(dims, '-');
    
    output = [filename '_' cLabel '.mat'];
    
    fprintf('saving Ws for frequency %s ... ', cLabel)
    save([PATHS.RESULTS filesep output], 'Ws' ,'chans', 'Wsdims', 'freqband', 'subjects')
    fprintf('done! \n')
end

    