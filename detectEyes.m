function [I, lindices, rindices, face_size, eye_dist eye_coords] = detectEyes(I, thresholds)

if nargin < 2
thresholds=1:10:150;
thresholds2=4:10:150;
a=0;
c=150;
end

for i=thresholds
     facedetector =  vision.CascadeObjectDetector('FrontalFaceLBP', 'MergeThreshold',i);
     bbox = step(facedetector, I);
     if(size(bbox,1)==1)
         break;
     end
end
face_size = bbox;

% [startx, endx, starty, endy ]
I1 = I(bbox(2):bbox(2)+bbox(4),bbox(1):bbox(1)+bbox(3),:);
 
%%
while(1)
%     [num2str(a),' ',num2str(c)]
     eyeDetector = vision.CascadeObjectDetector('EyePairBig', 'MergeThreshold',a);
     bboxes = step(eyeDetector, I1);
     idx = bboxes(:,2) < size(I1,1)/2 & bboxes(:,3)> 0.4*bbox(:,3);
     bboxes = bboxes(idx,:);
     %found the roi
     if(size(bboxes,1)==1)
         break;
     %too many rois,increase the threshold
     elseif(size(bboxes,1)>1)
         a=a+1;
     %zero roi, decrease threshold and go to prev iteration
     elseif(size(bboxes,1)==0)
         a=a-1;
         if(a<=0)
             break;
         end
     end
     
     eyeDetector = vision.CascadeObjectDetector('EyePairBig', 'MergeThreshold',c);
     bboxes = step(eyeDetector, I1);
     idx = bboxes(:,2) < size(I1,1)/2 & bboxes(:,3)> 0.4*bbox(:,3);
     bboxes = bboxes(idx,:);
     if(size(bboxes,1)==1)
         break;
     elseif(size(bboxes,1)==0)
         c = round((a+c)/2);
     elseif(size(bboxes,1)>1)
         a = round((a+c)/2);
     end
     if(a>=c)
         break;
     end
 end

if 0
   %% head bounding box
   clf;   imshow(I);  hold on; 
   plot( bbox(1)+bbox(3) , bbox(2)+bbox(4) ,'g+') 
   plot( bbox(1) , bbox(2)+bbox(4) ,'g+') 
   plot( bbox(1)+bbox(3) , bbox(2) ,'g+') 
   plot( bbox(1) , bbox(2) ,'g+') 
end

if(size(bboxes,1)==0)
    %could not find the eye-pairs, use default values using the face box
    eorigin = bbox(1,1:2) + [bbox(3)/6 bbox(4)/5];
    esize =  [4*bbox(3)/6 bbox(4)/6];
    bboxes = [bbox(3)/6 bbox(4)/5 esize];
else
    eorigin =  bbox(1,1:2)+bboxes(1,1:2);
    esize = bboxes(1,3:4);
end
IFaces = insertObjectAnnotation(I1, 'rectangle', bboxes, 'Eye Pairs');
% figure, imshow(IFaces), title('Detected eyes');

 for i=thresholds2
     leyeDetector = vision.CascadeObjectDetector('LeftEye', 'MergeThreshold',i);
     lbbox1 = step(leyeDetector, I);
     if(size(lbbox1,1)<=5)
         break;
     end
 end
  for i=thresholds2
     leyeDetector2 = vision.CascadeObjectDetector('LeftEyeCART', 'MergeThreshold',i);
     lbbox2 = step(leyeDetector2, I);
     if(size(lbbox2,1)<=5)
         break;
     end
  end
  

     
lbbox = [lbbox1;lbbox2];
% dist = sqrt(sum((lbbox(:,1:2) - (eorigin+esize)).^2,2)) + abs(lbbox(:,4)-esize(2));
dist = sqrt(sum( ((lbbox(:,1:2)+lbbox(:,3:4))-(eorigin+esize)).^2,2   )) + abs(lbbox(:,4)-esize(2));

[a,b] = min(dist);
lbboxes = lbbox(b,:);

IFaces = insertObjectAnnotation(I, 'rectangle', lbboxes, 'left eye');
% figure, clf; imshow(IFaces), title('Detected eyes');

img = I(lbboxes(2)-75:lbboxes(2)+lbboxes(4),lbboxes(1)-5:lbboxes(1)+lbboxes(3),:);
C1 = corner(rgb2gray(img),'MinimumEigenvalue','QualityLevel',0.01);

if 0
%%
clf; imshow(rgb2gray(img)); hold on; plot(C1(:,1), C1(:,2),'g+');
end
       
 for i=thresholds2
     
     noseDetector = vision.CascadeObjectDetector('RightEye', 'MergeThreshold',i);
     rbbox1 = step(noseDetector, I);

     if(size(rbbox1,1)==0 && i>10)
         i=i-10;
         noseDetector = vision.CascadeObjectDetector('RightEye', 'MergeThreshold',i);
         rbbox1 = step(noseDetector, I);
         break;
     end
     if(size(rbbox1,1)<=3)
         break;
     end
 end


  
for i=thresholds2
    noseDetector = vision.CascadeObjectDetector('RightEyeCART', 'MergeThreshold',i);
    rbbox2 = step(noseDetector, I);
    
    if(size(rbbox2,1)==0 && i>10)
        i=i-10;
        noseDetector = vision.CascadeObjectDetector('RightEyeCART', 'MergeThreshold',i);
        rbbox2 = step(noseDetector, I);
        break;
    end
    if(size(rbbox2,1)<=3)
        break;
    end
end
rbbox = [rbbox1;rbbox2];
dist = sqrt(sum((rbbox(:,1:2) - (eorigin)).^2,2));% + abs(rbbox(:,4)-esize(2));
[a,b] = min(dist);
rbboxes = rbbox(b,:);

%eye_dist = sqrt(sum( ((lbboxes(:,1:2)+lbboxes(:,3:4)/2)-(rbboxes(:,1:2)+rbboxes(:,3:4)/2) ).^2 ,2));
eye_dist = [(lbboxes(:,1:2)+lbboxes(:,3:4)/2);(rbboxes(:,1:2)+rbboxes(:,3:4)/2)];

   
IFaces = insertObjectAnnotation(I, 'rectangle', rbbox, 'Right eye');
% figure, clf; imshow(IFaces), title('Detected eyes');

% clf; imshow(IFaces2);
 
img = I(rbboxes(2)-75:rbboxes(2)+rbboxes(4),rbboxes(1)-5:rbboxes(1)+rbboxes(3),:);
 C2 = corner(rgb2gray(img),'MinimumEigenvalue','QualityLevel',0.01);

if 0 
%%
C2 = corner(rgb2gray(img),5);
clf; imshow(rgb2gray(img)); hold on; plot(C2(:,1), C2(:,2),'g+');
end
 
C11 = [lbboxes(1)-5, lbboxes(2)-75]+C1;
C12 = [rbboxes(1)-5, rbboxes(2)-75]+C2;
 
C = [C11; C12];
if 0
%%
clf;   imshow(I);  hold on; plot(C(:,1), C(:,2),'g+');
end
% figure;

%%


i = find( lbbox1(:,2) > mean(C(:,2))  );
lbbox1(i,:)=[];
i = find( rbbox1(:,2) > mean(C(:,2))  );
rbbox1(i,:)=[];

%%
py=max(lbbox1(:,2));
h=median( lbbox1(:,4) )/2;    
w=median( lbbox1(:,3) )/2;         
px = median( lbbox1(:,1) );   
lex=px + w; ley= py + h;
py=max(rbbox1(:,2));
h=median( rbbox1(:,4) )/2;    
w=median( rbbox1(:,3) )/2;         
px = median( rbbox1(:,1) );   
rex=px + w; rey= py + h;
    
if size(rbboxes,1)==1    
eye_coords.rex = rbboxes(1)+rbboxes(3)/2;
eye_coords.rey = rbboxes(2)+rbboxes(4)/2;
else
eye_coords.rex =rex;
eye_coords.rey =rey;
end
if size(lbboxes,1)==1
eye_coords.lex = lbboxes(1)+lbboxes(3)/2;
eye_coords.ley = lbboxes(2)+lbboxes(4)/2;
else
eye_coords.lex =lex;
eye_coords.ley =ley;
end

if 0
    %%
    Ieye = insertObjectAnnotation(I, 'rectangle', rbbox1, 'EyeROI');
    clf; imshow(Ieye), title('Detected eye');
    hold on;    
    plot( eye_coords.rex, eye_coords.rey, 'g+')
    %%
    Ieye = insertObjectAnnotation(I, 'rectangle', lbbox1, 'EyeROI');
    clf; imshow(Ieye), title('Detected eye');
    hold on;    
    plot( eye_coords.lex, eye_coords.ley, 'g+')
    
    %%
    ILeye = insertObjectAnnotation(I, 'rectangle', rbboxes, 'LEyeROI');
    clf; imshow(ILeye), title('Detected eye ROI');
    %%
    rLeye = insertObjectAnnotation(I, 'rectangle', lbboxes, 'REyeROI');
    clf; imshow(rLeye), title('Detected eye ROI');    
end

 
%%
[I, lindices] = detectEyebrow(I,lbboxes); 
[I, rindices] = detectEyebrow(I,rbboxes);
 
end