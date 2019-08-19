function labels = avc_readLabels(fname)
% this function read labels from filename
% filenames for our project are named as 
% SUBJ_G_XX_TI.ME_VT_XX_S.mp4
% SUBJ: subjid
% G: gender M or F
% TI.ME: MM.SS
% V: vowel type 
% T: tone type
% S: style: either clear or plain
%
% returns:
% labels:  a cell of different labels that are in the filename
%   subjid, gender, vowel, tone and style


    a= strsplit(fname,'_');
    sid = str2num( fname(1:4) );
    gender=a{2};
    
    vowel = a{5};
    if(length(a)>6)
        temp = a{7};
    else
        temp='x';
    end
    
    try response_type = a{6}(2); catch; end
    
    tone = vowel(2);
    style = lower(temp(1));
    
    labels={sid; gender; vowel; tone; style };

end