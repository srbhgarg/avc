function [I, indices]= detectLips(I, thresholds, reg)

if nargin < 2
thresholds=4:10:150;
reg=40;
se = strel('sphere',7);
end

%%
for i=thresholds
     noseDetector = vision.CascadeObjectDetector('Nose', 'MergeThreshold',i);
     nbbox = step(noseDetector, I);
%      imagesc(I); drawnow;
     if(size(nbbox,1)==1)
         break;
     end
end
%% 
%  IFaces3 = insertObjectAnnotation(I, 'rectangle', nbbox, 'Nose');   
%  hold on, imshow(IFaces3);
 
 for i=thresholds
     mouthDetector = vision.CascadeObjectDetector('Mouth', 'MergeThreshold',i);
     mbbox = step(mouthDetector, I);
     idx = nbbox(:,2) < mbbox(:,2);
     mbbox = mbbox(idx,:);
     if(size(mbbox,1)==1)
         break;
     end
 end
%  IFaces3 = insertObjectAnnotation(I, 'rectangle', mbbox(2,:), 'Mouth');   
%  hold on, imshow(IFaces3);
if(size(mbbox,1)>1)
    diff = mbbox(:,2) - (nbbox(1,2) +nbbox(1,4));  
    mbbox =  mbbox(diff>0,:);
    [v, id] = min(diff);
    mbbox = mbbox(id,:);
end
 

%To detect the outline of lips in Frontal face

 img = I(mbbox(2)-reg:mbbox(2)+mbbox(4),mbbox(1):mbbox(1)+mbbox(3),:);
 hsv=rgb2hsv(img);
%  ind = hsv(:,:,1) > 0.85;
%  h2 = hsv(:,:,2);
%  mx = max(h2(ind));
%  hsv(:,:,1) = h2 > .4*mx;
%  %biggest connected component

% imshow(imbinarize(squeeze(hsv(:,:,1))));
a = imbinarize(squeeze(hsv(:,:,1)));
b = imbinarize(squeeze(hsv(:,:,2)));
%percentage pixels that are on
a1 = sum(a(:))/(size(hsv,1)*size(hsv,2));
b1 = sum(b(:))/(size(hsv,1)*size(hsv,2));
if(a1 > 0.14 && a1 < 0.48)
    lip=a;
elseif(b1 > 0.14 && b1 < 0.48)
    lip=b;
elseif(a1<0.1)
    lip=b;
elseif(b1<0.1)
    lip=a;
else
    lip = a&b;
end

lip = a|b;

% lip = imbinarize(squeeze(hsv(:,:,2))) & imbinarize(squeeze(hsv(:,:,1)));

big = bwareafilt(lip,1);
mask = imdilate(bwconvhull(big),se);
bw = activecontour(rgb2gray(img),mask,500,'edge','SmoothFactor',2);


%  img(:,:,1)= bw*255;
 img(:,:,1)= mask*255;
 
%  imshow(rgb2gray(img)); 
 
 
indices = [];
for j=mbbox(1):mbbox(1)+mbbox(3)
    [val ind] = max(img(:,j-mbbox(1)+1,1));
%     I(ind+lbboxes(2)-75,j,:) = 255; 
    indices= [indices; ind+mbbox(2)-reg, j];
end

for j=mbbox(1):mbbox(1)+mbbox(3)
    flag =false;
    for i=mbbox(2)+mbbox(4):-1:mbbox(2)-reg
        if(bw(i+1-mbbox(2)+reg,j-mbbox(1)+1) > 0 && flag==false)
          indices= [indices; i, j];
          flag =true;
        end
    end
end


idx = indices(:,1) < (mbbox(2)-reg+3);
indices(idx,:)=[];

for j=1:length(indices)
    if(~isnan(indices(j,1)))
        I(indices(j,1),indices(j,2),:) = 255;
    end
end

%  
%  se = strel('sphere',3);
%  bw = imerode(big,se);
%  a = find(sum(big),1,'first');
%  b = find(sum(big),1,'last');
%  c = find(sum(big'),1,'first');
%  d = find(sum(big'),1,'last');
%   C = corner(rgb2gray(img),'MinimumEigenvalue','QualityLevel',0.1);
%  minc = min(C);
%  maxc = max(C);
%  
%  minc(1) = min(minc(1),a);
%  minc(2) = min(minc(2),c);
%  maxc(1) = max(maxc(1),b);
%  maxc(2) = max(maxc(2),d);
%  
%  mask = zeros(size(img,1),size(img,2));
%  mask(minc(2):maxc(2),minc(1):maxc(1)) = 1;
%  bw = activecontour(rgb2gray(img),mask,500,'edge','SmoothFactor',2);
% 
%  img(:,:,1)= mask*100; 
%  imshow(img); 
 
%  img = I(mbbox(2)-10:mbbox(2)+mbbox(4)+10,mbbox(1)-10:mbbox(1)+mbbox(3)+10,:);
%   se = strel('sphere',3);
%  bw = imdilate(bw,se);
%  
%  
%  imshow(edge(hsv(:,:,1),'canny'))
%  C = corner(rgb2gray(img),'MinimumEigenvalue','QualityLevel',0.1);
%  imshow(rgb2gray(img)); hold on; plot(C(:,1), C(:,2),'b');


end