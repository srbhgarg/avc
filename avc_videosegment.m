function [first, last] = avc_videosegment(file, vrate)
% segment video based on the audio data and adds a buffer of 10 frames on
% either end.
% file: file containing audio data
% vrate: video frame rate
%
%returns:
% first: # of first frame
% last: # of last frame

%new sampling rate for audio data
Fs= 16000;

%read audio file
[wav, oFs] = audioread(file);

%downmixing
mtlb = mean(wav,2);

%resampling to 16khz
data = resample(mtlb,Fs,oFs);


% differentiate voiced and unvoiced signal
%get envelope
Eor = avc_ShortTimeEnergy(data, 0.05*Fs, 1);
E = medfilt1(Eor, 5); E = medfilt1(E, 5);
E = [zeros((0.05*Fs)/2,1); E; zeros((0.05*Fs)/2,1)];


     %find clusters in Eor to detect clicks/cough and hmm sounds
    ccount =1;
    flag = false;
    for l =1:length(E)
        if(E(l)>0.05)
            E(l)=ccount;
            flag = true;
        end
        if(flag==true && E(l) <= 0.05)
            ccount = ccount+1;
            flag = false;
        end
    end
    
    %max(Eor) gives the cluster count or ccount-1 and sum(Eor==1) gives the width of
    %cluster 1
    % Now try to check if clusters are similar (35%) in width if not ..remove the
    % smaller one
    
    %find the biggest cluster
    maxwidth = 0;
    for l =1:ccount-1
        if(maxwidth < sum(E==l))
            maxwidth = sum(E==l);
        end
    end
    %if cluster is less than 35% of the max ..remove it
    for l =1:ccount-1
        if(sum(E==l) < 0.35*maxwidth)
            E(E==l) = 0;
        end
    end
    
    sig = data(1:end);
    sig(E <= 0.05) = 0;
    sig(1:5000,1) =0;
    sig(end-5000:end)=0;
    
 
 startpt = find(sig,1);
 endpt = find(sig,1,'last');
 
 %first and last frame number
 first = round(startpt/Fs*vrate) -10;
 last = round(endpt/Fs*vrate) +10;