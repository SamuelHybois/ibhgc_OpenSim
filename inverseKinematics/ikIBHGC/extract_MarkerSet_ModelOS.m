function [marqueursModele,idx] = extract_MarkerSet_ModelOS(modeleOsim)

nMarkers = size(modeleOsim.Model.MarkerSet.objects.Marker,2);
marqueursModele{nMarkers,1}=0;

for i_marker = 1:nMarkers
    marqueursModele{i_marker} = modeleOsim.Model.MarkerSet.objects.Marker(i_marker).ATTRIBUTE.name;
end

[marqueursModele,idx] = sort(marqueursModele);

end