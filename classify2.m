%

ntree =500;

if(tone==1)
    % find tone=1 class 1
    Y1= Y==1;
    idx1 = find(Y1==0);
    idx2 = find(Y1==1);

    pval11 =[];
    rng(seed);
    for f=1:33 % for each feature
        contTable=zeros(4,2);
        yhat1=[];
        yhat2=[];
        yt=[];
        for i=1:50 % repeat sampling this many times

	    save( sprintf('workspace_rf_classify_sigimp_500_tree_tone%d_seed%d___itn%d-f%d_check.mat',tone,seed, i, f), 'i', 'f' )

            idx11 = 1+round(rand(size(idx2,1),1)*(size(idx1,1)-1));
            %         find samples related to tone 1
            Y11 = Y1([idx1(idx11);idx2],:);
            X11 = X([idx1(idx11);idx2],:);
            B = TreeBagger(ntree,zscore(X11),Y11,'OOBPrediction','On',...
                'OOBPredictorImportance','on','MinLeafSize',20,'Method','classification');
            ind = B.OOBIndices;
            
            for etree=1:ntree %for each tree
                pImp = B.Trees{etree}.predictorImportance;
                %             find the trees where importance is non zero
                if( pImp(f)~=0)
                    %                 get OOB samples of each tree
                    testind = B.OOBIndices(:,etree);
                    ytrue = Y11(testind);
                    yt=[yt;ytrue];
                    %                 do prediction on each tree using orig data
                    yind = predict(B.Trees{etree}, X11(testind,:));
                    yind = cell2mat(yind);
                    yhat1=[yhat1;yind];
                    contTable(1,1) = contTable(1,1) + sum(ytrue == 1 & yind=='1');%TP
                    contTable(2,1) = contTable(2,1) + sum(ytrue == 0 & yind=='0');%TN
                    contTable(3,1) = contTable(3,1) + sum(ytrue == 0 & yind=='1');%FP
                    contTable(4,1) = contTable(4,1) + sum(ytrue == 1 & yind=='0');%FN
                    
                    %                 randomly permute
                    Xperm = X11(testind,:);
                    n = size(Xperm,1);
                    shuffle = randsample(n,n);
                    Xtemp = Xperm(shuffle,:);
                    %                 replace the shuffled feature column only
                    Xperm(:,f)  = Xtemp(:,f);
                    yind2 = predict(B.Trees{etree}, Xperm);
                    yind2 = cell2mat(yind2);
                    yhat2=[yhat2;yind2];
                    contTable(1,2) = contTable(1,2) + sum(ytrue == 1 & yind2=='1');
                    contTable(2,2) = contTable(2,2) + sum(ytrue == 0 & yind2=='0');
                    contTable(3,2) = contTable(3,2) + sum(ytrue == 0 & yind2=='1');
                    contTable(4,2) = contTable(4,2) + sum(ytrue == 1 & yind2=='0');
                    
                end
            end
            
        end
        %         chi2stat = sum((contTable(:,2)-contTable(:,1)).^2 ./ contTable(:,1));
        %         p = 1 - chi2cdf(chi2stat,1)
        %         [pval]=chi2Tests(contTable, 'Pe')
        % contTable
        f
        %         [table,chi2,p] = crosstab(y,yhat);
        [h,p] = testcholdout(yhat1, yhat2, num2str(yt),'Test','asymptotic','CostTest', 'chisquare')
        
        pval11 =[pval11;p]
    end
    
    
elseif(tone==2)
    % class 2
    Y1= Y==2;
    idx1 = find(Y1==0);
    idx2 = find(Y1==1);
    
    pval21 =[];
    rng(seed);
    for f=1:33 % for each feature
        contTable=zeros(4,2);
        yhat1=[];
        yhat2=[];
        yt=[];

	save( sprintf('workspace_rf_classify_sigimp_500_tree_tone%d_seed%d___itn%d-f%d_check.mat',tone,seed, 0, f), 'f' )

        for i=1:50 % repeat sampling this many times
            idx11 = 1+round(rand(size(idx2,1),1)*(size(idx1,1)-1));
            %         find samples related to tone 1
            Y11 = Y1([idx1(idx11);idx2],:);
            X11 = X([idx1(idx11);idx2],:);
            B = TreeBagger(ntree,zscore(X11),Y11,'OOBPrediction','On',...
                'OOBPredictorImportance','on','MinLeafSize',20,'Method','classification');
            ind = B.OOBIndices;
            
            for etree=1:ntree %for each tree
                pImp = B.Trees{etree}.predictorImportance;
                %             find the trees where importance is non zero
                if( pImp(f)~=0)
                    %                 get OOB samples of each tree
                    testind = B.OOBIndices(:,etree);
                    ytrue = Y11(testind);
                    yt=[yt;ytrue];
                    %                 do prediction on each tree using orig data
                    yind = predict(B.Trees{etree}, X11(testind,:));
                    yind = cell2mat(yind);
                    yhat1=[yhat1;yind];
                    contTable(1,1) = contTable(1,1) + sum(ytrue == 1 & yind=='1');%TP
                    contTable(2,1) = contTable(2,1) + sum(ytrue == 0 & yind=='0');%TN
                    contTable(3,1) = contTable(3,1) + sum(ytrue == 0 & yind=='1');%FP
                    contTable(4,1) = contTable(4,1) + sum(ytrue == 1 & yind=='0');%FN
                    
                    %                 randomly permute
                    Xperm = X11(testind,:);
                    n = size(Xperm,1);
                    shuffle = randsample(n,n);
                    Xtemp = Xperm(shuffle,:);
                    %                 replace the shuffled feature column only
                    Xperm(:,f)  = Xtemp(:,f);
                    yind2 = predict(B.Trees{etree}, Xperm);
                    yind2 = cell2mat(yind2);
                    yhat2=[yhat2;yind2];
                    contTable(1,2) = contTable(1,2) + sum(ytrue == 1 & yind2=='1');
                    contTable(2,2) = contTable(2,2) + sum(ytrue == 0 & yind2=='0');
                    contTable(3,2) = contTable(3,2) + sum(ytrue == 0 & yind2=='1');
                    contTable(4,2) = contTable(4,2) + sum(ytrue == 1 & yind2=='0');
                    
                end
            end
            
        end
        %         chi2stat = sum((contTable(:,2)-contTable(:,1)).^2 ./ contTable(:,1));
        %         p = 1 - chi2cdf(chi2stat,1)
        %         [pval]=chi2Tests(contTable, 'Pe')
        % contTable
        f
        %         [table,chi2,p] = crosstab(y,yhat);
        [h,p] = testcholdout(yhat1, yhat2, num2str(yt),'Test','asymptotic','CostTest', 'chisquare');
        
        pval21 =[pval21;p]
    end
    
elseif(tone==3)
    % class 3
    Y1= Y==3;
    idx1 = find(Y1==0);
    idx2 = find(Y1==1);
    
    pval31 =[];
    rng(seed);
    for f=1:33 % for each feature
        contTable=zeros(4,2);
        yhat1=[];
        yhat2=[];
        yt=[];
        for i=1:50 % repeat sampling this many times
            idx11 = 1+round(rand(size(idx2,1),1)*(size(idx1,1)-1));
            %         find samples related to tone 1
            Y11 = Y1([idx1(idx11);idx2],:);
            X11 = X([idx1(idx11);idx2],:);
            B = TreeBagger(ntree,zscore(X11),Y11,'OOBPrediction','On',...
                'OOBPredictorImportance','on','MinLeafSize',20,'Method','classification');
            ind = B.OOBIndices;
            
            for etree=1:ntree %for each tree
                pImp = B.Trees{etree}.predictorImportance;
                %             find the trees where importance is non zero
                if( pImp(f)~=0)
                    %                 get OOB samples of each tree
                    testind = B.OOBIndices(:,etree);
                    ytrue = Y11(testind);
                    yt=[yt;ytrue];
                    %                 do prediction on each tree using orig data
                    yind = predict(B.Trees{etree}, X11(testind,:));
                    yind = cell2mat(yind);
                    yhat1=[yhat1;yind];
                    contTable(1,1) = contTable(1,1) + sum(ytrue == 1 & yind=='1');%TP
                    contTable(2,1) = contTable(2,1) + sum(ytrue == 0 & yind=='0');%TN
                    contTable(3,1) = contTable(3,1) + sum(ytrue == 0 & yind=='1');%FP
                    contTable(4,1) = contTable(4,1) + sum(ytrue == 1 & yind=='0');%FN
                    
                    %                 randomly permute
                    Xperm = X11(testind,:);
                    n = size(Xperm,1);
                    shuffle = randsample(n,n);
                    Xtemp = Xperm(shuffle,:);
                    %                 replace the shuffled feature column only
                    Xperm(:,f)  = Xtemp(:,f);
                    yind2 = predict(B.Trees{etree}, Xperm);
                    yind2 = cell2mat(yind2);
                    yhat2=[yhat2;yind2];
                    contTable(1,2) = contTable(1,2) + sum(ytrue == 1 & yind2=='1');
                    contTable(2,2) = contTable(2,2) + sum(ytrue == 0 & yind2=='0');
                    contTable(3,2) = contTable(3,2) + sum(ytrue == 0 & yind2=='1');
                    contTable(4,2) = contTable(4,2) + sum(ytrue == 1 & yind2=='0');
                    
                end
            end
            
        end
        %         chi2stat = sum((contTable(:,2)-contTable(:,1)).^2 ./ contTable(:,1));
        %         p = 1 - chi2cdf(chi2stat,1)
        %         [pval]=chi2Tests(contTable, 'Pe')
        % contTable
        f
        %         [table,chi2,p] = crosstab(y,yhat);
        [h,p] = testcholdout(yhat1, yhat2, num2str(yt),'Test','asymptotic','CostTest', 'chisquare');
        
        pval31 =[pval31;p]
    end
    
elseif(tone==4)
    % class 4
    Y1= Y==4;
    idx1 = find(Y1==0);
    idx2 = find(Y1==1);
    
    pval41 =[];
    rng(seed);
    for f=1:33 % for each feature
        contTable=zeros(4,2);
        yhat1=[];
        yhat2=[];
        yt=[];
        for i=1:50 % repeat sampling this many times
            idx11 = 1+round(rand(size(idx2,1),1)*(size(idx1,1)-1));
            %         find samples related to tone 1
            Y11 = Y1([idx1(idx11);idx2],:);
            X11 = X([idx1(idx11);idx2],:);
            B = TreeBagger(ntree,zscore(X11),Y11,'OOBPrediction','On',...
                'OOBPredictorImportance','on','MinLeafSize',20,'Method','classification');
            ind = B.OOBIndices;
            
            for etree=1:ntree %for each tree
                pImp = B.Trees{etree}.predictorImportance;
                %             find the trees where importance is non zero
                if( pImp(f)~=0)
                    %                 get OOB samples of each tree
                    testind = B.OOBIndices(:,etree);
                    ytrue = Y11(testind);
                    yt=[yt;ytrue];
                    %                 do prediction on each tree using orig data
                    yind = predict(B.Trees{etree}, X11(testind,:));
                    yind = cell2mat(yind);
                    yhat1=[yhat1;yind];
                    contTable(1,1) = contTable(1,1) + sum(ytrue == 1 & yind=='1');%TP
                    contTable(2,1) = contTable(2,1) + sum(ytrue == 0 & yind=='0');%TN
                    contTable(3,1) = contTable(3,1) + sum(ytrue == 0 & yind=='1');%FP
                    contTable(4,1) = contTable(4,1) + sum(ytrue == 1 & yind=='0');%FN
                    
                    %                 randomly permute
                    Xperm = X11(testind,:);
                    n = size(Xperm,1);
                    shuffle = randsample(n,n);
                    Xtemp = Xperm(shuffle,:);
                    %                 replace the shuffled feature column only
                    Xperm(:,f)  = Xtemp(:,f);
                    yind2 = predict(B.Trees{etree}, Xperm);
                    yind2 = cell2mat(yind2);
                    yhat2=[yhat2;yind2];
                    contTable(1,2) = contTable(1,2) + sum(ytrue == 1 & yind2=='1');
                    contTable(2,2) = contTable(2,2) + sum(ytrue == 0 & yind2=='0');
                    contTable(3,2) = contTable(3,2) + sum(ytrue == 0 & yind2=='1');
                    contTable(4,2) = contTable(4,2) + sum(ytrue == 1 & yind2=='0');
                    
                end
            end
            
        end
        %         chi2stat = sum((contTable(:,2)-contTable(:,1)).^2 ./ contTable(:,1));
        %         p = 1 - chi2cdf(chi2stat,1)
        %         [pval]=chi2Tests(contTable, 'Pe')
        % contTable
        f
        %         [table,chi2,p] = crosstab(y,yhat);
        [h,p] = testcholdout(yhat1, yhat2, num2str(yt),'Test','asymptotic','CostTest', 'chisquare');
        
        pval41 =[pval41;p]

        % %%%%%%%%%%%%%%%%%%%%%%
	% 		can you pre-allocate memory please; this is hogging system <-- !!
        % %%%%%%%%%%%%%%%%%%%%%%
    end
end
