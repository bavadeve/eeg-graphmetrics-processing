resultStr = {'wpli_debiased_delta.mat',...
    'wpli_debiased_theta.mat', ...
    'wpli_debiased_alpha1.mat', ...
    'wpli_debiased_alpha2.mat', ...
    'wpli_debiased_beta.mat', ...
    'wpli_debiased_gamma.mat', };

method = 'randomizeWeightedNetworks';

for i = 1:length(resultStr)
    disp(resultStr{i})
    fprintf('\t loading ... ')
    load(resultStr{i})
    fprintf('done! \n')
    
    switch method
        case 'cleanSessions'
            fprintf('\t cleaning data over sessions \n')
            Ws = bv_cleanWsOverSessions(Ws);
            fprintf('\t saving newly cleaned Ws to %s', resultStr{i})
            save(resultStr{i}, 'Ws', '-append')
            fprintf('done! \n')
            
        case 'conMatrixCor'
            fprintf('\t calculating correlation between connectivity matrices \n')
            indivCorrs(i,:) = bv_corrSesConnectivity(Ws);
            results.conMatrices = indivCorrs(i,:);
            fprintf('\t adding variable to %s', resultStr{i})
            save(resultStr{i}, 'results', '-append')
            fprintf('done! \n')
            
        case 'corrCorrMatrix'
            fprintf('\t creating correlation between all connectivity matrices matrix')
            
            WsNeat = zeros([size(Ws,1) size(Ws,2) size(Ws,3)*size(Ws,4)]);
            
            WsNeat(:,:,1:2:end) = Ws(:,:,:,1);
            WsNeat(:,:,2:2:end) = Ws(:,:,:,2);
            
            results.corrCorrMatrix = createCorrCorrMatrix(WsNeat);
            fprintf('\t adding variable to %s', resultStr{i})
            save(resultStr{i}, 'results', '-append')
            fprintf('done! \n')
            
        case 'corrGroupAvg'
            fprintf('\t correlating group averaged connectivity matrices \n')
            
            W1 = nanmean(Ws(:,:,:,1),3);
            W2 = nanmean(Ws(:,:,:,2),3);
            
            rGrpAvg(i) = correlateMatrices(W1, W2);
            
            results.rGrpAvg = rGrpAvg(i);
            
            fprintf('\t saving to %s ... ', resultStr{i})
            save(resultStr{i}, 'results', '-append')
            fprintf('done! \n')
            
        case 'randomizeWeightedNetworks'
            if exist('Wrandom', 'var')
                clear Wrandom
            end
            
            m = size(Ws,4);
            for j = 1:m
                fprintf('\t randomizing networks session %1.0f ... ', j)
                
                currWs = Ws(:,:,:,j);
                %         currWs_thr = double(currWs > 0.1);
                Wrandom(:,:,:,:,j) = bv_randomizeWeightedMatrices(currWs, 100);
            end
            
            fprintf('\t saving to %s ... ', resultStr{i})
            save(resultStr{i}, 'Wrandom', '-append')
            fprintf('done! \n')
            
        case 'randomizeBinaryNetworks'
            if exist('Brandom', 'var')
                clear Brandom
            end
            
            m = size(Ws,4);
            for j = 1:m
                fprintf('\t randomizing networks session %1.0f ... ', j)
                

                
                currWs = Ws(:,:,:,j);
                nans = isnan(currWs);
                currWs_thr = double(currWs > 0.15);
                BrandMat = bv_randomizeBinaryMatrices(currWs_thr, 100);
                BrandMat(nans) = NaN;
                Brandom(:,:,:,:,j) = BrandMat;
            end
            
            fprintf('\t saving to %s ... ', resultStr{i})
            save(resultStr{i}, 'Brandom', '-append')            
            fprintf('done! \n')
            
        otherwise
            error('Unknown method')
    end
end

switch method
    case 'corrGroupAvg'
%         disp(rGrpAvg)
    case 'conMatrixCor'
        N = size(indivCorrs,2);
        mIndivCorr = nanmean(indivCorrs,2);
        stdIndivCorr = nanstd(indivCorrs,[],2);
        seIndivCorr = 2*(stdIndivCorr/sqrt(N));
end
