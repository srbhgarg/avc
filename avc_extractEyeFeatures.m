function [eyefeat, dist] = avc_extractEyeFeatures(feat, donorm)


%% LEFT EYE
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
idx = find(feat.leye.valid==max(feat.leye.valid));

if(donorm)
    hor= feat.leye.normx(idx,:); %Normalized features
    vert= feat.leye.normy(idx,:);
else
    hor= feat.leye.x(idx,:); %Normalized features
    vert= feat.leye.y(idx,:);
end
timepts = size(hor,2);
%TODO: pick a robust point from contour to calculate feature at
% pt=round(size(hor,1)/2);
pt = pickpoints(hor, vert);
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
dist.vledist = vdist;
dist.hledist = hdist;
dist.ledst = dst;
dist.levelA = velA;
dist.levelH = velH;
dist.levelV = velV;

dist.leaccA = accA;
dist.leaccH = accH;
dist.leaccV = accV;

[mnvd mndidx]=min(-vdist);
[mxvd mxdidx]= max((-vdist));
[mxv mxvidx] = max((velV));
[mnv mnvidx] = min(velV);
%extract mean min max and total
lfeatures = [ max((velV)) min((velV)) max(abs(accV))  mxvidx/length(velV) mnvidx/length(velV) mxdidx/length(vdist) mndidx/length(vdist) max(vdist)-min(vdist) mean(abs(vdist)) min(-vdist) max((-vdist)) sum(abs(vdist))];

        figure; 
        
        subplot(3,1,1);
        plot( vdist);
        ylabel('Distance');
        title('Eyebrow Measurements');
        subplot(3,1,2);
        plot([0; velV]);
        ylabel('Velocity');
        subplot(3,1,3);
        plot([0; 0; accV])
        ylabel('Acceleration');
        xlabel('Time');
        
% eyefeat = [rfeatures lfeatures];
eyefeat = [ lfeatures];
end