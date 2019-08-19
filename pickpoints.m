function pt = pickpoints(hor, vert)
% pick a point from a contour to track and compute features on

pt=round(size(hor,1)/2);

ht= hist(vert(:,1),length(vert(:,1)));
[~,b]= max(ht);
idxlist = find(vert(:,1)>= (vert(b,1)-5) & vert(:,1)<= (vert(b,1)+5));
pt = idxlist(round(length(idxlist)/2));

end
