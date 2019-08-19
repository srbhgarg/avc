function [features, dist] = avc_extractHeadFeatures(feat, donorm, debug)
        hdist=[];
        vdist=[];
        dst=[];
        velA=[];
        velH=[];
        velV=[];
        accA=[];
        accH=[];
        accV=[];
        
%%*************** HEAD *********************
        %find max good tracked points
        idx = find(feat.head.valid==max(feat.head.valid));
        
        if(donorm)
            hor= feat.head.normx(idx,:); %Normalized features
            vert= feat.head.normy(idx,:);
        else
            hor= feat.head.x(idx,:); %Normalized features
            vert= feat.head.y(idx,:);
        end
        timepts = size(hor,2);
        %pick a robust point from contour to calculate feature at
        pt = pickpoints(hor, vert);
        if(1)
            start=2;
            finish=timepts;
        else
            %detect start, finish based on the audio
            [start, finish] = avc_videosegment([direc, fname]);
        end
        
        for t=start:finish
            %HORIZONTAL DISTANCE relative to first frame
            hdist = [hdist; hor(pt,t)-hor(pt,1)];
            %VERTICAL DISTANCE
            vdist = [vdist; vert(pt,t)-vert(pt,1)];
            dst  =[dst;  sqrt( ( hor(pt,t)-hor(pt,1) ).^2 + ( vert(pt,t)-vert(pt,1) ).^2 ) ];
            if (length(dst)>=2)
                velA = [velA; dst(end)-dst(end-1)];
                velH = [velH; hdist(end)-hdist(end-1)];
                velV = [velV; vdist(end)-vdist(end-1)];
            end
        end
        
        for t = 2:length(velA)
            accA = [accA; velA(t)-velA(t-1)];
            accH = [accH; velH(t)-velH(t-1)];
            accV = [accV; velV(t)-velV(t-1)];
        end
        dist.vdist = vdist;
        dist.hdist = hdist;
        dist.dst = dst;
        dist.velA = velA;
        dist.velH = velH;
        dist.velV = velV;
        
        dist.accA = accA;
        dist.accH = accH;
        dist.accV = accV;
        [mnvd mndidx]=min(-vdist); 
        [mxvd mxdidx]= max((-vdist));
        [mxv mxvidx] = max((velV));
        [mnv mnvidx] = min(velV);
        %extract mean min max and total
        features = [max((velV)) min((velV)) max(abs(accV)) mxvidx/length(velV) mnvidx/length(velV) mxdidx/length(vdist) mndidx/length(vdist) max(vdist)-min(vdist) mean(abs(vdist)) min(-vdist) max((-vdist)) sum(abs(vdist))];
        if(debug)
            figure;
            
            subplot(3,1,1);
            plot( vdist);
            ylabel('Distance');
            title('Head Measurements');
            subplot(3,1,2);
            plot([0; velV]);
            ylabel('Velocity');
            subplot(3,1,3);
            plot([0; 0; accV])
            ylabel('Acceleration');
            xlabel('Time');
        end
        
end