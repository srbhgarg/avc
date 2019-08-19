filename = sprintf('workspace_rf_classify_sigimp_%03d_tree_tone%d_seed%d', ntree, tone,seed)



if(tone==1)
%tone 1
Y1= Y==1;
idx1 = find(Y1==0);
idx2 = find(Y1==1);

qval1 = mafdr(pval11,'BHFDR', true);
idx_all =  [1:33]; %performance using all features
idx_qval1 = find(qval1<0.05)'; %performance using significant features
% 0.00000001
[a,b] = sort(imp,'descend'); 
idx_imp = b(1:length(idx_qval1)); %performance using feature importance
subj=unique(side);
sse=0;

s_all=[];
s_q=[];
s_imp=[];
sig_imp1=[];
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
        trainindices = setxor([idx1(idx11);idx2], [testindices1; testindices2]);
        
        %all features
        trainX = X(trainindices,idx_all);
        trainY = Y1(trainindices);
        trainG = g(trainindices);
        
        testX = X(testindices,idx_all);
        testY = Y1(testindices);
        mn = mean(trainX);
        sd = std(trainX);
        interaction=[trainG];
        interaction=[];
        trainX = (trainX - mn) ./sd;
        testX = (testX -mn) ./sd;
        
        testG = g(testindices);
        
        B = TreeBagger(ntree,([trainX interaction]),trainY,'OOBPrediction','On',...
            'OOBPredictorImportance','on','MinLeafSize',20,'Method','classification');
        interaction = [testG];
        interaction=[];
        [Yfit,scores] = predict(B,[testX interaction]);
        Yfit =  str2double(Yfit);
        
        [scores score_names ns_per_class Scores ]= get_class_scores(  testY, 0:1, Yfit, Yfit, 0.5 );
        s_all = [s_all; scores];
       %significant features
        trainX = X(trainindices,idx_qval1);
        trainY = Y1(trainindices);
        testX = X(testindices,idx_qval1);
        testY = Y1(testindices);

        interaction=[trainG];
        interaction=[];
        B = TreeBagger(ntree,([trainX interaction]),trainY,'OOBPrediction','On',...
            'OOBPredictorImportance','on','MinLeafSize',20,'Method','classification');
        sig_imp1 = [sig_imp1; B.OOBPermutedPredictorDeltaError];
      
        interaction = [testG];
        interaction=[];
        [Yfit,scores] = predict(B,[testX interaction]);
        Yfit =  str2double(Yfit);
        
        [scores score_names ns_per_class Scores ]= get_class_scores(  testY, 0:1, Yfit, Yfit, 0.5);
        s_q = [s_q; scores];
        %important features
        trainX = X(trainindices,idx_imp);
        trainY = Y1(trainindices);
        testX = X(testindices,idx_imp);
        testY = Y1(testindices);
        
        interaction=[trainG];
        interaction=[];
        B = TreeBagger(ntree,([trainX interaction]),trainY,'OOBPrediction','On',...
            'OOBPredictorImportance','on','MinLeafSize',20,'Method','classification');
        interaction = [testG];
        interaction=[];
        [Yfit,scores] = predict(B,[testX interaction]);
        Yfit =  str2double(Yfit);
        
        [scores score_names ns_per_class Scores ]= get_class_scores( testY, 0:1, Yfit, Yfit, 0.5 );
        s_imp = [s_imp; scores];
     end
end

elseif(tone==2)
%tone 2
Y1= Y==2;
idx1 = find(Y1==0);
idx2 = find(Y1==1);

qval2 = mafdr(pval21,'BHFDR', true);
idx_all =  [1:33]; %performance using all features
idx_qval2 = find(qval2<0.05)'; %performance using significant features
% 0.0000001
[a,b] = sort(imp2,'descend'); 
idx_imp = b(1:length(idx_qval2)); %performance using feature importance
subj=unique(side);

s_all2=[];
s_q2=[];
s_imp2=[];
sig_imp2=[];
for i=1:20 %for each subject LOO
    i
    rng(seed); % For reproducibility
     for it=1:50 % repeat sampling this many times, N
              
        idx11 = 1+round(rand(size(idx2,1),1)*(size(idx1,1)-1));

        %find equal samples in the test set of each class
        testindices1 = find ( (Y==2) & (side==subj(i))' );
        testindices2 = find ( (Y~=2) & (side==subj(i))' );
        testindices = [testindices1; testindices2(randi(length(testindices2), length(testindices1),1))
];
        %remove LOO subject from training data
        trainindices = setxor([idx1(idx11);idx2], [testindices1; testindices2]);
        
        %all features
        trainX = X(trainindices,idx_all);
        trainY = Y1(trainindices);
        
        testX = X(testindices,idx_all);
        testY = Y1(testindices);
        mn = mean(trainX);
        sd = std(trainX);
        
        trainX = (trainX - mn) ./sd;
        testX = (testX -mn) ./sd;
          trainG = g(trainindices);
        testG = g(testindices);
        interaction=[trainG];
        interaction=[];
        B = TreeBagger(ntree,([trainX interaction]),trainY,'OOBPrediction','On',...
            'OOBPredictorImportance','on','MinLeafSize',20,'Method','classification');
        interaction = [testG];
        interaction=[];
        [Yfit,scores] = predict(B,[testX interaction]);
        Yfit =  str2double(Yfit);
        
        [scores score_names ns_per_class Scores ]= get_class_scores(  testY, 0:1, Yfit, Yfit, 0.5 );
        s_all2 = [s_all2; scores];
       %significant features
        trainX = X(trainindices,idx_qval2);
        trainY = Y1(trainindices);
        testX = X(testindices,idx_qval2);
        testY = Y1(testindices);
        
         interaction=[trainG];
         interaction=[];
        
        B = TreeBagger(ntree,([trainX interaction]),trainY,'OOBPrediction','On',...
            'OOBPredictorImportance','on','MinLeafSize',20,'Method','classification');
        sig_imp2 = [sig_imp2; B.OOBPermutedPredictorDeltaError];
  
        interaction = [testG];
        interaction=[];
        [Yfit,scores] = predict(B,[testX interaction]);
        Yfit =  str2double(Yfit);
        
        [scores score_names ns_per_class Scores ]= get_class_scores(  testY, 0:1, Yfit, Yfit, 0.5);
        s_q2 = [s_q2; scores];
            %important features
        trainX = X(trainindices,idx_imp);
        trainY = Y1(trainindices);
        testX = X(testindices,idx_imp);
        testY = Y1(testindices);
        
         interaction=[trainG];
        interaction=[];
        B = TreeBagger(ntree,([trainX interaction]),trainY,'OOBPrediction','On',...
            'OOBPredictorImportance','on','MinLeafSize',20,'Method','classification');
        interaction = [testG];
        interaction=[];
        [Yfit,scores] = predict(B,[testX interaction]);
        Yfit =  str2double(Yfit);
        
        [scores score_names ns_per_class Scores ]= get_class_scores( testY, 0:1, Yfit, Yfit, 0.5 );
        s_imp2 = [s_imp2; scores];
     end
end


elseif(tone==3)
%tone 3
Y1= Y==3;
idx1 = find(Y1==0);
idx2 = find(Y1==1);

qval3 = mafdr(pval31,'BHFDR', true);
idx_all =  [1:33]; %performance using all features
idx_qval3 = find(qval3<0.05)'; %performance using significant features
 %0.00000001
[a,b] = sort(imp3,'descend'); 
idx_imp = b(1:length(idx_qval3)); %performance using feature importance
subj=unique(side);


s_all3=[];
s_q3=[];
s_imp3=[];
sig_imp3=[];
for i=1:20 %for each subject LOO
    i
    rng(seed); % For reproducibility
     for it=1:50 % repeat sampling this many times, N
              
        idx11 = 1+round(rand(size(idx2,1),1)*(size(idx1,1)-1));

        %find equal samples in the test set of each class
        testindices1 = find ( (Y==3) & (side==subj(i))' );
        testindices2 = find ( (Y~=3) & (side==subj(i))' );
        testindices = [testindices1; testindices2(randi(length(testindices2), length(testindices1),1))
];
        %remove LOO subject from training data
        trainindices = setxor([idx1(idx11);idx2], [testindices1; testindices2]);
        
        %all features
        trainX = X(trainindices,idx_all);
        trainY = Y1(trainindices);
        
        testX = X(testindices,idx_all);
        testY = Y1(testindices);
        mn = mean(trainX);
        sd = std(trainX);
        
        trainX = (trainX - mn) ./sd;
        testX = (testX -mn) ./sd;
            trainG = g(trainindices);
        testG = g(testindices);
        interaction=[trainG];
        interaction=[];
        B = TreeBagger(ntree,([trainX interaction]),trainY,'OOBPrediction','On',...
            'OOBPredictorImportance','on','MinLeafSize',20,'Method','classification');
         interaction=[testG];
         interaction=[];
        [Yfit,scores] = predict(B,[testX interaction]);
        Yfit =  str2double(Yfit);
        
        [scores score_names ns_per_class Scores ]= get_class_scores(  testY, 0:1, Yfit, Yfit, 0.5 );
        s_all3 = [s_all3; scores];
       %significant features
        trainX = X(trainindices,idx_qval3);
        trainY = Y1(trainindices);
        testX = X(testindices,idx_qval3);
        testY = Y1(testindices);
        
         interaction=[trainG];
        interaction=[];
        B = TreeBagger(ntree,([trainX interaction]),trainY,'OOBPrediction','On',...
            'OOBPredictorImportance','on','MinLeafSize',20,'Method','classification');
        sig_imp3 = [sig_imp3; B.OOBPermutedPredictorDeltaError];
        interaction=[testG];
        interaction=[];
        [Yfit,scores] = predict(B,[testX interaction]);
        Yfit =  str2double(Yfit);
        
        [scores score_names ns_per_class Scores ]= get_class_scores(  testY, 0:1, Yfit, Yfit, 0.5);
        s_q3 = [s_q3; scores];
            %important features
        trainX = X(trainindices,idx_imp);
        trainY = Y1(trainindices);
        testX = X(testindices,idx_imp);
        testY = Y1(testindices);
        
        interaction=[trainG];
        interaction=[];
        B = TreeBagger(ntree,([trainX interaction]),trainY,'OOBPrediction','On',...
            'OOBPredictorImportance','on','MinLeafSize',20,'Method','classification');
        interaction=[testG];
        interaction=[];
        [Yfit,scores] = predict(B,[testX interaction]);
        Yfit =  str2double(Yfit);
        
        [scores score_names ns_per_class Scores ]= get_class_scores( testY, 0:1, Yfit, Yfit, 0.5 );
        s_imp3 = [s_imp3; scores];
     end
end


elseif(tone==4)
%tone 4
Y1= Y==4;
idx1 = find(Y1==0);
idx2 = find(Y1==1);

qval4 = mafdr(pval41,'BHFDR', true);
idx_all =  [1:33]; %performance using all features
idx_qval4 = find(qval4<0.05)'; %performance using significant features
% 0.00000001
[a,b] = sort(imp4,'descend'); 
idx_imp = b(1:length(idx_qval4)); %performance using feature importance
subj=unique(side);

s_all4=[];
s_q4=[];
s_imp4=[];
sig_imp4=[];
for i=1:20 %for each subject LOO
    i
    rng(seed); % For reproducibility
     for it=1:50 % repeat sampling this many times, N
              
        idx11 = 1+round(rand(size(idx2,1),1)*(size(idx1,1)-1));

        %find equal samples in the test set of each class
        testindices1 = find ( (Y==4) & (side==subj(i))' );
        testindices2 = find ( (Y~=4) & (side==subj(i))' );
        testindices = [testindices1; testindices2(randi(length(testindices2), length(testindices1),1))
];
        %remove LOO subject from training data
        trainindices = setxor([idx1(idx11);idx2], [testindices1; testindices2]);
        
        %all features
        trainX = X(trainindices,idx_all);
        trainY = Y1(trainindices);
        
        testX = X(testindices,idx_all);
        testY = Y1(testindices);
        mn = mean(trainX);
        sd = std(trainX);

        trainX = (trainX - mn) ./sd;
        testX = (testX -mn) ./sd;
        
        trainG = g(trainindices);
        testG = g(testindices);
        interaction=[trainG];
        interaction=[];
        B = TreeBagger(ntree,([trainX interaction]),trainY,'OOBPrediction','On',...
            'OOBPredictorImportance','on','MinLeafSize',20,'Method','classification');
        interaction=[testG];
        interaction=[];
        [Yfit,scores] = predict(B,[testX interaction]);
        Yfit =  str2double(Yfit);
        
        [scores score_names ns_per_class Scores ]= get_class_scores(  testY, 0:1, Yfit, Yfit, 0.5 );
        s_all4 = [s_all4; scores];
       %significant features
        trainX = X(trainindices,idx_qval4);
        trainY = Y1(trainindices);
        testX = X(testindices,idx_qval4);
        testY = Y1(testindices);
        
        interaction=[trainG];
        interaction=[];
        B = TreeBagger(ntree,([trainX interaction]),trainY,'OOBPrediction','On',...
            'OOBPredictorImportance','on','MinLeafSize',20,'Method','classification');
        sig_imp4 = [sig_imp4; B.OOBPermutedPredictorDeltaError];
        interaction=[testG];
        interaction=[];
        [Yfit,scores] = predict(B,[testX interaction]);
        Yfit =  str2double(Yfit);
        
        [scores score_names ns_per_class Scores ]= get_class_scores(  testY, 0:1, Yfit, Yfit, 0.5);
        s_q4 = [s_q4; scores];
            %important features
        trainX = X(trainindices,idx_imp);
        trainY = Y1(trainindices);
        testX = X(testindices,idx_imp);
        testY = Y1(testindices);
        
        interaction=[trainG];
        interaction=[];
        B = TreeBagger(ntree,([trainX interaction]),trainY,'OOBPrediction','On',...
            'OOBPredictorImportance','on','MinLeafSize',20,'Method','classification');
        interaction=[testG];
        interaction=[];
        [Yfit,scores] = predict(B,[testX interaction]);
        Yfit =  str2double(Yfit);
        
        [scores score_names ns_per_class Scores ]= get_class_scores( testY, 0:1, Yfit, Yfit, 0.5 );
        s_imp4 = [s_imp4; scores];
     end
     
end
end


%%accuracy plots
figure;
hold on
acc_diff = [mean(s_all(:,1)),mean(s_q(:,1)),mean(s_imp(:,1));
    mean(s_all2(:,1)),mean(s_q2(:,1)),mean(s_imp2(:,1));
    mean(s_all3(:,1)),mean(s_q3(:,1)),mean(s_imp3(:,1));
    mean(s_all4(:,1)),mean(s_q4(:,1)),mean(s_imp4(:,1))];
b=bar(acc_diff,'grouped');
xticks(1:4)
xticklabels( {'Tone 1', 'Tone 2', 'Tone 3', 'Tone 4'});
acc_diff_std = [std(s_all(:,1)),std(s_q(:,1)),std(s_imp(:,1));
    std(s_all2(:,1)),std(s_q2(:,1)),std(s_imp2(:,1));
    std(s_all3(:,1)),std(s_q3(:,1)),std(s_imp3(:,1));
    std(s_all4(:,1)),std(s_q4(:,1)),std(s_imp4(:,1))];
for k1 = 2%;size(b,2)                    % Loop: Plots Error Bars
    off=0.5;
    errorbar(1:4, acc_diff(:,k1), acc_diff_std(:,k1), '.') % plotting errors
end
legend('All features','Paul method','Brieman method')


% %plot the bar graph
% fig = figure;%('units','normalized','outerposition',[0 0 1 1]);
% 
% C = nan(3, 4, 3);
% C(1, 1, :) = [.9 .3 .3];
% C(2, 1, :) = [.6 .1 .1];
% C(3, 1, :) = [.3 .1 .1];
% C(1, 2, :) = [.3 .9 .3];
% C(2, 2, :) = [.1 .6 .1];
% C(3, 2, :) = [.1 .9 .1];
% C(1, 3, :) = [.3 .3 .9];
% C(2, 3, :) = [.1 .1 .6];
% C(3, 3, :) = [.1 .1 .9];
% C(1, 4, :) = [0.9 0.9 0.9];
% C(2, 4, :) = [0.5 0.5 0.5];
% C(3, 4, :) = [0.2 0.2 0.2];
% tcolor =C;
% % title(gca, strrep(feat_names{f,:},'_',' '));
% type = 1;
% for tone=1:4
% subplot(1,4,tone);
% hold on;
%     Xt =[1:3];
%     if(tone==1)
%         Yt = [mean(s_all(:,type)), mean(s_q(:,type)), mean(s_imp(:,type))];
%  ylabel('Classification accuracy');   
%     elseif(tone==2)
%         Yt = [mean(s_all2(:,type)), mean(s_q2(:,type)), mean(s_imp2(:,type))];
%     elseif(tone==3)
%         Yt = [mean(s_all3(:,type)), mean(s_q3(:,type)), mean(s_imp3(:,type))];
%     else
%         Yt = [mean(s_all4(:,type)), mean(s_q4(:,type)), mean(s_imp4(:,type))];
%     end
%     b=superbar(Xt,Yt,'BarFaceColor',tcolor(:,tone,:));
%     
%     errorbar(Xt,Yt,[std(s_all4(:,1)), std(s_q4(:,1)), std(s_imp4(:,1))],'.')
%     %    supererr(X,Y,[],YE)
%     title(['Tone ',num2str(tone)]);
%     set(gca, 'XTick', [1:3]);
% xticklabels({'All','q-val','imp'})
%     %adding p values
% %     [h,p] = ttest2(tempfeat(cindices), tempfeat(pindices));
% %     if(p<0.05)
% %         plot(2*tone-0.5,max(mxfeat(f),0),'p','MarkerSize',10,'MarkerFaceColor','k','MarkerEdgeColor','k');
% %     end
% end

    

save(filename)
