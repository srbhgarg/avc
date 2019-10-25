function features = avc_main()
% main file to run the pipeline
%
% assumes all the mp4 files in 'data' folder
%
% returns:
% features: return features computed on a video

%% change the folder to the corresponding data folder
data='data/';
if( (data(end) ~='/') || (data(end) ~='\'))
    if(ispc)
        data=[data '\'];
    elseif(isunix)
        data=[data '/'];
    else
        data=[data '/'];
    end
end


debug=true; % turn debugging off

% get the list of files that need to be processed
%could use ls or dir command to get the filelist
filelist= dir([data '*.mp4']);

features=[];
for f=4%1:size(filelist,1)
    feat=[];
    if(isstruct(filelist))
        filename = filelist(f).name;
    else
        filename = strtrim(filelist(f,:));
    end
    disp(['processing ', filename, ' ...']);
    
    % read the data
    [~, vdata, ~]=avc_readData([data filename]);
    
    %parse labels from filename
    labels = avc_readLabels(filename);
    
    %segment video only where audio is present
    [first, last] = avc_videosegment([data filename], vdata.FrameRate);
    
    %% DETECT  KEYPOINTS
%     for i=1:10
%         vidFrame = readFrame(vdata);
%     end
    
    %% detect lips
    if(hasFrame(vdata))
        %read the 3rd frame to be on safe side
            vidFrame = readFrame(vdata);
            vidFrame = readFrame(vdata);
            vidFrame = readFrame(vdata);
    end
    %%
    I = vidFrame;
    [I1, indices, mbbox] = detectLips(I);
    feat.lips.x = indices(:,2);
    feat.lips.y = indices(:,1);
    feat.lips.valid = ones(length(indices),1);

    if(debug)
        imshow(I1)
    end
    %% detect left eye
    [I1,lindices,rindices, fsize, edist, eyecoords] = detectEyes(I);                                               
    lindices = [lindices(~isnan(lindices(:,1)),1) lindices(~isnan(lindices(:,1)),2)];     
    rindices = [rindices(~isnan(rindices(:,1)),1) rindices(~isnan(rindices(:,1)),2)];     
    feat.leye.x = lindices(:,2);                                                       
    feat.leye.y = lindices(:,1);                                                       
    feat.leye.valid = ones(length(lindices),1); 
    feat.norm.head = fsize;   
    feat.norm.eyes = edist;     
    
    if(debug)
        imshow(I1);
    end
    %% detect head
    [I1, nindices, nsize, nbox] = detectNose(I);
    feat.head.x = nindices(:,2);
    feat.head.y = nindices(:,1);
    feat.head.valid = ones(length(nindices),1);
    feat.norm.nose = nsize;

    if(debug)
        imshow(I1)
    end
    %% TRACKING KEYPOINTS
    % track lips
    trackLips = vision.PointTracker('MaxBidirectionalError', 1);
    initialize(trackLips, [indices(:,2) indices(:,1)], I);
 
    %track left eye
    trackLeye = vision.PointTracker('MaxBidirectionalError', 1);                          
    initialize(trackLeye, [lindices(:,2) lindices(:,1)], I);                              

    %track head
    trackHead = vision.PointTracker('MaxBidirectionalError', 1);
    initialize(trackHead, [nindices(:,2) nindices(:,1)], I);

    while hasFrame(vdata)

        frame = readFrame(vdata);             % Read next image frame
        [lpoints, validity] = step(trackLips, frame);  % Track the points
        feat.lips.x = [feat.lips.x lpoints(:,1)];
        feat.lips.y = [feat.lips.y lpoints(:,2)];
        feat.lips.valid = feat.lips.valid + validity;
    
        [lpoints, validity] = step(trackLeye, frame);  % Track the points                 
        feat.leye.x = [feat.leye.x lpoints(:,1)];                                   
        feat.leye.y = [feat.leye.y lpoints(:,2)];                                   
        feat.leye.valid = feat.leye.valid + validity;                               
    
        [hpoints, validity] = step(trackHead, frame);  % Track the points
        feat.head.x = [feat.head.x hpoints(:,1)]; 
        feat.head.y = [feat.head.y hpoints(:,2)];
        feat.head.valid = feat.head.valid + validity;

    end
    
    
    %extract features
    donorm=1; %perform normalization    
    feat = normalization(feat,2);
    [headfeat, dist, hpt] = avc_extractHeadFeatures(feat, donorm, debug);
    [eyefeat, eyedist, ept] = avc_extractEyeFeatures(feat, donorm);
    [lipsfeat, lipsdist, lpt1, lpt2] = avc_extractLipsFeatures(feat, donorm);
    
    features = [features; headfeat eyefeat lipsfeat];


end
% end of filelist   
 feat_names={ 'max_abs_head_vert_velocity'
     'min_abs_head_vert_velocity'
    'max_abs_head_vert_acceleration'
    'time_max_head_vert_velocity'
    'time_min_head_vert_velocity'
     'time_max_head_vert_distance'
    'time_min_head_vert_distance'
    'max_vert_head_displacement'
    'avg_abs_vert_head_distance'
    'min_vert_head_distance'
    'max_vert_head_distance'
    'total_abs_vert_head_distance'
    
    'max_abs_left_eye_vert_velocity'
    'min_abs_left_eye_vert_velocity'
    'max_abs_left_eye_vert_acceleration'
    'time_max_left_eye_vert_velocity'
    'time_min_left_eye_vert_velocity'
    'time_max_left_eye_vert_distance'
    'time_min_left_eye_vert_distance'
    'max_vert_left_eye_displacement'
    'avg_abs_vert_left_eye_distance'
    'min_vert_left_eye_distance'
    'max_vert_left_eye_distance'
    'total_abs_vert_left_eye_distance'
    
    'max_vert_lips_displacement'
    'time_max_lips_velocity'
    'time_min_lips_velocity'
    'time_max_lips_distance'
    'time_min_lips_distance'
    'avg_lips_distance'
    'min_lips_distance'
    'max_lips_distance'
    'total_abs_lips_distance'
       'max_abs_lips_velocity'
       'min_abs_lips_velocity'
    'max_abs_lips_acceleration'
    };


% remove displacement related features
if(size(features,2))
    features = features(:,[1:7 9:12 13:19 21:24 26:36]);
end
if (size(feat_names,1)==36)
    fnames = feat_names([1:7 9:12 13:19 21:24 26:36]);
end
fNames = strrep(fnames,'_',' ');

end