function [I, indices, nsize] = detectNose(I,thresholds)
if nargin < 2
    thresholds =1:10:150;
end

for i=thresholds
     nosedetector =  vision.CascadeObjectDetector('Nose', 'MergeThreshold',i);
     bbox = step(nosedetector, I);
     if(size(bbox,1)==1)
         break;
     end
end
 
% IFaces = insertObjectAnnotation(I, 'rectangle', bbox, 'Nose');
% figure, imshow(IFaces), title('Nose');
nsize = [bbox(1,1:2); bbox(1,1:2)+bbox(1,3:4)];

img = I(bbox(2):bbox(2)+bbox(4),bbox(1):bbox(1)+bbox(3),:);

 mask = zeros(size(img,1),size(img,2));
 mask(5:end-5,5:end-5)=1;
bw = activecontour(rgb2gray(img),mask,500,'edge','SmoothFactor',2);
 
%  img(:,:,1)= bw*255;
%  imshow(rgb2gray(img)); 
 indices=[];
 for j=bbox(1):bbox(1)+bbox(3)
    flag =false;
    for i=bbox(2)+bbox(4):-1:bbox(2)
        if(bw(i+1-bbox(2),j-bbox(1)+1) > 0 && flag==false)
          indices= [indices; i, j];
          flag =true;
        end
    end
 end

for j=1:length(indices)
    if(~isnan(indices(j,1)))
        I(indices(j,1),indices(j,2),:) = 255;
    end
end

 
end