function pt = pickpoints(hor, vert)
% pick a point from a contour to track and compute features on

pt=round(size(hor,1)/2);


[ht, cen]= hist(vert(:,1),length(vert(:,1)));
[~,b]= max(ht);
%find the points that are +- 5 away in the largest bin and then pick the
%middle
idxlist = find(vert(:,1)>= (cen(b)-5) & vert(:,1)<= (cen(b)+5));
pt = idxlist(round(length(idxlist)/2));

end
