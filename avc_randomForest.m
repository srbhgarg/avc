function [pval11, qval, idx_qval]= avc_randomForest( labels, features, ntree)
% this is the implementation of the paul's method of random forest to find
% the significant features that are needed for classification.
%
% ntree: number of tress. recommend 500 value
% labels: binary labels containing 0 or 1 value
% features: feature matrix of size # subj x # of features

if nargin < 3
   ntree =500;
   
end
seed=1;
Y1= labels;
idx1 = find(Y1==0);
idx2 = find(Y1==1);
X=features;
pval11 =[];
rng(seed);
for f=1:size(features,2) % for each feature
    
    yhat1=[];
    yhat2=[];
    yt=[];
    for i=1:50 % repeat sampling this many times
        
        % 	    save( sprintf('workspace_rf_classify_sigimp_500_tree_tone%d_seed%d___itn%d-f%d_check.mat',tone,seed, i, f), 'i', 'f' )
        
        idx11 = 1+round(rand(size(idx2,1),1)*(size(idx1,1)-1));
        %  find samples related to label 1
        Y11 = Y1([idx1(idx11);idx2],:);
        X11 = X([idx1(idx11);idx2],:);
        B = TreeBagger(ntree,zscore(X11),Y11,'OOBPrediction','On',...
            'OOBPredictorImportance','on','MinLeafSize',20,'Method','classification');
        ind = B.OOBIndices;
        
        for etree=1:ntree % for each tree
            pImp = B.Trees{etree}.predictorImportance;
            % find the trees where importance is non zero
            if( pImp(f)~=0)
                %   get OOB samples of each tree
                testind = B.OOBIndices(:,etree);
                ytrue = Y11(testind);
                yt=[yt;ytrue];
                %                 do prediction on each tree using orig data
                yind = predict(B.Trees{etree}, X11(testind,:));
                yind = cell2mat(yind);
                yhat1=[yhat1;yind];
                
                %                 randomly permute
                Xperm = X11(testind,:);
                n = size(Xperm,1);
                shuffle = randsample(n,n);
                Xtemp = Xperm(shuffle,:);
                %                 replace the shuffled feature column only
                Xperm(:,f)  = Xtemp(:,f);
                yind2 = predict(B.Trees{etree}, Xperm);
                yind2 = cell2mat(yind2);
                yhat2=[yhat2; yind2];
                
            end
        end
        
    end

    [h,p] = testcholdout(yhat1, yhat2, num2str(yt),'Test','asymptotic','CostTest', 'chisquare');
    
    pval11 =[pval11; p]
end

% do multiple comparisons to find the significant features after correction
qval = mafdr(pval11,'BHFDR', true);
idx_qval = find(qval<0.05)';

end