% Fonction cinématique directe hors OpenSim
function [dataReconstruite,Struct_MH] = cinematiqueDirecte(modeleOsim,struct_Bodies, struct_Joints,coordGeneralisee_t,MarkerSet,indexMarqueursModele)
% NB : les translations doivent être en m et les rotations en radians (la
% fonction ci-dessous les convertit en degrés quand nécessaire)

% Fonction récursive
Struct_MH = {};
Name_Body = 'ground';
Struct_MH = parcoursModeleCinematiqueDirecte(coordGeneralisee_t,struct_Bodies,struct_Joints,Name_Body,Struct_MH);
%

% Réxpression de proche en proche jusqu'à ce que tous les bodies soient
% exprimés dans R_Ground

List_bodies = fieldnames(Struct_MH);
for i_body = 1:size(List_bodies,1)
    
    flag = 0;
    while flag~=1
        
        Parent = Struct_MH.(List_bodies{i_body}).where;
        if strcmp(Parent,'ground')~=1
            MH1 = Struct_MH.(List_bodies{i_body}).MH;
            MH0 = Struct_MH.(Parent).MH;
            where = Struct_MH.(Parent).where;
            
            MH = MH0* MH1;
            
            Struct_MH.(List_bodies{i_body}).MH = MH;
            Struct_MH.(List_bodies{i_body}).where = where;
        else
            flag=1;
        end
    end
end % end while

%% Calcul de la position des marqueurs reconstruits

Markers = modeleOsim.Model.MarkerSet.objects.Marker ;
dataReconstruite.noms = MarkerSet;
nMarkers=size(MarkerSet,1);
dataReconstruite.matrix(nMarkers,3)=0;
i=0;

for i_marker=indexMarqueursModele'
    i=i+1;
    body = Markers(i_marker).body ;
    coord_Rbody = Markers(i_marker).location ;
    coord_R0 = Struct_MH.(body).MH(:,:) * [coord_Rbody,1]';
    dataReconstruite.matrix(i,:) = coord_R0(1:3);
end

end