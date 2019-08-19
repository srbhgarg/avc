function [I, indices] = detectEyebrow(I,lbboxes)
 
% % ----------------
% for j=lbboxes(1):lbboxes(1)+lbboxes(3)
%      I(lbboxes(2):lbboxes(2)+5,j,:) = 255; 
% end 
% 
% %|
% %|
% for j=lbboxes(2):lbboxes(2)+lbboxes(4)
%      I(j, lbboxes(1):lbboxes(1)+5,:) = 255; 
% end 

reg = 115;
img = I(lbboxes(2)-reg:lbboxes(2)+lbboxes(4),lbboxes(1)-5:lbboxes(1)+lbboxes(3),:);
img1 = zeros(size(img));
% based on the color
for j=8:5+lbboxes(3)-8
    for i=8:reg+lbboxes(4)-8
        for k=1:3
        if(sum(img(i-7:i, j:j+7,k)) > sum(img(i:i+7, j:j+7,k)))
            img1(i,j,1) =img1(i,j,1)+ 0.2;
        end
        end
    end
end


% based on the edge
img = I(lbboxes(2)-reg:lbboxes(2)+lbboxes(4),lbboxes(1)-5:lbboxes(1)+lbboxes(3),:);
img = rgb2hsv(img);
im = edge(img(:,:,3),'canny'); 

img1(:,:,1) =img1(:,:,1)+ im*0.2;
% for i=1:5+lbboxes(3)
% for j=1:75+lbboxes(4)
%     if(im(j,i) > 0)
%         img1(j,i,3) = img1(i,j,3)+ 50;
%         break;
%     end
% end
% end


%based on shape/location
img = I(lbboxes(2)-reg:lbboxes(2)+lbboxes(4),lbboxes(1)-5:lbboxes(1)+lbboxes(3),:);
 mask = zeros(size(img,1),size(img,2));
 mask(2:end-4,2:end-4) = 1;
 bw = activecontour(rgb2gray(img),mask,400);
 
 for j=1:size(bw,2)
     for i=1:size(bw,1)     
         if(bw(i,j)>0)
             img1(i,j,1) = img1(i,j,1) + 0.25;
             
        img(i,j,1) = 0.25;
             break;
         end
     end
 end

 
 
cx= reg+lbboxes(4);
cy = (lbboxes(3)+5)/2;
N = sqrt(cx*cx+cy*cy);
for i=1:5+lbboxes(3)
for j=1:reg+lbboxes(4)
        val = sqrt((cx-j).^2 +(cy-i).^2);
        val = val/(4*N);
        img1(j,i,1) = img1(j,i,1)+ val;

end
end

indices = [];
for j=lbboxes(1):lbboxes(1)+lbboxes(3)
    [val ind] = max(img1(:,j-lbboxes(1)+5,1));
%     I(ind+lbboxes(2)-75,j,:) = 255; 
    indices= [indices; ind+lbboxes(2)-reg, j];
end

indices = detectOutliers(indices,false);
for j=1:length(indices)
    if(~isnan(indices(j,1)))
        I(indices(j,1),indices(j,2),:) = 255;
    end
end
