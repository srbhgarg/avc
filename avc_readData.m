function [adata, vdata, fs]=avc_readData(filename)
% filename: mp4 filename with path
%
% returns:
% adata: contains audio data (nnumber of samples x channels)
% vdata: contains video data (matlab videoreader struct)

% this function is only tested for mp4 video files. The function suppports
% all the different file formats that matlab supports

[adata, fs] = audioread(filename); %fs is sampling rate

vdata= VideoReader(filename);
end