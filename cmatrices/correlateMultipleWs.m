function [R, P] = correlateMultipleWs(Ws1, Ws2)

if nargin < 2
    error('Please add in two sets of correlations matrices')
end

if sum(size(Ws1) == size(Ws2)) ~= length(size(Ws1))
    error('size Ws1 (%s) does not equal size Ws2 (%s)', num2str(size(Ws1)), num2str(size(Ws2)))
end

for iW = 1:size(Ws1,3);
    currW1 = Ws1(:,:,iW);
    currW2 = Ws2(:,:,iW);
    
    rmChanIndx = find(sum(isnan(currW1),2) == size(currW1,1));

    if ~isempty(rmChanIndx)
        currW1(rmChanIndx,:) = [];
        currW1(:,rmChanIndx) = [];
        currW2(rmChanIndx,:) = [];
        currW2(:,rmChanIndx) = [];
    end

    [currR, currP] = correlateMatrices(currW1, currW2);
    R(iW) = currR(2);
    P(iW) = currP(2);
end

