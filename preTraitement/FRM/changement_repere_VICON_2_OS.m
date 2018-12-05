function [st_VICON,st_marqueurs_cine] = changement_repere_VICON_2_OS(st_VICON,st_marqueurs_cine,Marqueurs,M_pass_VICON_OS)
%%%% Changement de système d'axe pour éviter gimbal lock
% M_pass_VICON_OS : matrice de passage 3x3 entre le répère salle de Vicon
% et le repère ground d'OpenSim, en particulier pour s'assurer que la
% verticale est associée à la même coordonnée
% e.g : M_pass_VICON_OS = [[1 0 0]',[0 0 1]',[0 -1 0]'] ;

if ~exist('M_pass_VICON_OS','var'), 
    M_pass_VICON_OS = [[1 0 0]',[0 0 1]',[0 -1 0]'] ;
end

if strcmp(st_VICON.Info.unit,'mm')==1, change=1/1000; st_VICON.Info.unit='m';
elseif strcmp(st_VICON.Info.unit,'m')==1, change=1; 
else change=1; disp('unité des données Vicon sont ni mm ni m')
end


for i_marqueur = 1:size(Marqueurs,1)
    Data_R0= st_marqueurs_cine.(Marqueurs{i_marqueur});
    Data_R1= M_pass_VICON_OS' * Data_R0'; %changement de repere
    st_marqueurs_cine.(Marqueurs{i_marqueur}) = change*Data_R1'; %conversion des mm en m 
end

end