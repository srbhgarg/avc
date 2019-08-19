function [lipsfeat, lipsdist] = avc_extractLipsFeatures(feat, donorm)

hdist=[];
vdist=[];
dst=[];
velA=[];
velH=[];
velV=[];
accA=[];
accH=[];
accV=[];

%find max good tracked points
idx = find(feat.lips.valid==max(feat.lips.valid));

if(donorm)
    pthead = pickpoints(feat.head.normx, feat.head.normy);
  
    hor= feat.lips.normx(:,:) - feat.head.normx(pthead,:); %Normalized features
    vert= feat.lips.normy(:,:) - feat.head.normy(pthead,:);
else
    hor= feat.lips.x(:,:); %raw features
    vert= feat.lips.y(:,:);
end
timepts = size(hor,2);
%TODO: pick a robust point from contour to calculate feature at
cpt=round(size(hor,1)/2)+25;
[mx, id1] = max(hor(1:cpt,1));
[mn,id2] = min(hor(1:cpt,1));
pt1 = round((id1-id2)/2);
pt2 = pt1 + id1 - id2;

if(1)
    start=2;
    finish=timepts;
else
    %TODO
    [start, finish] = detectVoicedForVideo([direc, fname]);
    %             %detect start, finish based on the audio
    %             start = round(startpt/audio.rate*video.rate) -10;
    %             finish = round(endpt/audio.rate*video.rate) +10;
end
for t=start:finish
    dst  =[dst;  sqrt( ( hor(pt1,t)-hor(pt2,t) ).^2 + ( vert(pt1,t)-vert(pt2,t) ).^2 ) ];
    if (length(dst)>=2)
        velA = [velA; dst(end)-dst(end-1)];
    end
end

for t = 2:length(velA)
    accA = [accA; velA(t)-velA(t-1)];
end

lipsdist.lipsdst = dst;
lipsdist.lipsvelA = velA;
lipsdist.lipsaccA = accA;

[mnvd mndidx]=min(dst);
[mxvd mxdidx]= max((dst));
[mxv mxvidx] = max((velA));
 [mnv mnvidx] = min(velA);
lipsfeat = [max(dst)-min(dst) mxvidx/length(velA) mnvidx/length(velA) mxdidx/length(dst) mndidx/length(dst) mean(dst) min(dst) max(dst) sum(abs(dst)) max((velA)) min((velA)) max(abs(accA))];

 figure; 
        
        subplot(3,1,1);
        plot( dst);
        ylabel('Distance');
        title('Lips Measurements');
        subplot(3,1,2);
        plot([0; velA]);
        ylabel('Velocity');
        subplot(3,1,3);
        plot([0; 0; accA])
        ylabel('Acceleration');
        xlabel('Time');

