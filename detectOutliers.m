function indices =  detectOutliers(indices, draw)

if draw
    plot(indices(:,1),'b')
end
mn = mean(indices(:,1));
sd = 1*std(indices(:,1));
idx = indices(:,1) > (mn +sd) | indices(:,1) < (mn -sd);
indices(idx,1) = nan;
if draw
    hold on;
    plot(indices(:,1),'r');
end

end