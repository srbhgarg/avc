function avc_paul(features, labels, pval11)

%%
load("../workspace_rf_classify2.mat");

style=output(:,2);
stidx=find(style=='c'|style=='p');
labels=style(stidx);
features=features(stidx,:);
slab=labels=='c';
[pval11, qval, idx_qval]= avc_randomForest( slab, features, 500)
%%


Y1= labels;
idx1 = find(Y1==0);
idx2 = find(Y1==1);

qval1 = mafdr(pval11,'BHFDR', true);
idx_qval1 = find(qval1<0.05)'; %performance using significant features
% 0.00000001
[a,b] = sort(imp,'descend'); 
subj=unique(side);

s_q=[];
for i=1:20 %for each subject LOO
    i
    rng(seed); % For reproducibility
     for it=1:50 % repeat sampling this many times, N
              
        idx11 = 1+round(rand(size(idx2,1),1)*(size(idx1,1)-1));

        %find equal samples in the test set of each class
        testindices1 = find ( (Y==1) & (side==subj(i))' );
        testindices2 = find ( (Y~=1) & (side==subj(i))' );
        testindices = [testindices1; testindices2(randi(length(testindices2), length(testindices1),1))
];
        %remove LOO subject from training data
        trainindices = setxor([idx1(idx11); idx2], [testindices1; testindices2]);
        
        %significant features
        trainX = X(trainindices,idx_qval1);
        trainY = Y1(trainindices);
        testX = X(testindices,idx_qval1);
        testY = Y1(testindices);


        interaction=[];
        B = TreeBagger(ntree,([trainX interaction]),trainY,'OOBPrediction','On',...
            'OOBPredictorImportance','on','MinLeafSize',20,'Method','classification');
        sig_imp1 = [sig_imp1; B.OOBPermutedPredictorDeltaError];
      
        [Yfit,scores] = predict(B,[testX interaction]);
        Yfit =  str2double(Yfit);
        
        [scores score_names ns_per_class Scores ]= get_class_scores(  testY, 0:1, Yfit, Yfit, 0.5);
        s_q = [s_q; scores];
     end
end