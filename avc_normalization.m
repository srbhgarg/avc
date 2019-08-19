function feat = avc_normalization(feat, choice)

nose = mean(feat.norm.nose);
eyes = mean(feat.norm.eyes);
        
horFactor = sqrt( (feat.norm.eyes(1,1)-feat.norm.eyes(2,1)).^2 + (feat.norm.eyes(1,2)-feat.norm.eyes(2,2)).^2  );
            
        
vertFactor = sqrt( (eyes(1,1)-nose(1,1)).^2 + (eyes(1,2)-nose(1,2)).^2  );
if(choice == 2)
    %get the middle nose contour point
    idx = round(size(feat.head.valid,1)/2);
    nose =  [feat.head.x(idx,1) feat.head.y(idx,1)];
    vertFactor = sqrt( (eyes(1,1)-nose(1,1)).^2 + (eyes(1,2)-nose(1,2)).^2  );
end     
    
headFactor = feat.norm.head(3);

feat.norm.horFactor = horFactor;
feat.norm.vertFactor = vertFactor;
feat.norm.headFactor = headFactor;
     
     
feat.lips.normx = feat.lips.x ./feat.norm.horFactor;
feat.lips.normy = feat.lips.y ./feat.norm.vertFactor;
     
feat.leye.normx = feat.leye.x ./feat.norm.horFactor;
feat.leye.normy = feat.leye.y ./feat.norm.vertFactor;
     
feat.reye.normx = feat.reye.x ./feat.norm.horFactor;
feat.reye.normy = feat.reye.y ./feat.norm.vertFactor;
     
feat.head.normx = feat.head.x ./feat.norm.horFactor;
feat.head.normy = feat.head.y ./feat.norm.vertFactor;
 
end