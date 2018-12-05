function wi = recuperationPoidsMarqueurs(structurePROT,MarkerSet)

nMarkers = size(MarkerSet,1) ;

for i_marker = 1:nMarkers
    
    nom_marker = MarkerSet{i_marker} ;
    poids_tmp = structurePROT.POIDS.(nom_marker) ;
    wi{i_marker,1}=nom_marker;
    wi{i_marker,2}=str2num(poids_tmp{1,2});
    
end

end