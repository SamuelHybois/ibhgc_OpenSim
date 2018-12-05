% nom_prot='golfbeta2.prot';
% nom_c3d='bois_3_03.c3d';
% folder='G:\Cours_these\Recherche\OpenSim\donnees_MB\rep_acquisition';
function [ VICON, data ] = recuperation_c3d(c3dfile )

% [repprot nomprot ext] = fileparts(protfile) ;
% if isempty(repprot)==1,
%     repprot=repertoire;
% end

% disp('lecture c3d')
% Protocol = lire_fichier_prot( repprot, [nomprot, ext] );

VICON=[] ;
data = btk_loadc3d(c3dfile, 10);
VICON.Marqueurs=data.marker_data.Markers;
VICON.Time=data.marker_data.Time;
VICON.Info.frequence=data.marker_data.Info.frequency;
VICON.Info.NumFrames=data.marker_data.Info.NumFrames;
VICON.Info.unit=data.marker_data.Info.units.ALLMARKERS;

anim = 'off';
end
