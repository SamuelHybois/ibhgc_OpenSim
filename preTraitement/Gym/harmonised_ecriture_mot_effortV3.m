function st_efforts=harmonised_ecriture_mot_effortV3_YP(data_c3d, nom_fichier,chemin_c3d,M_pass_Vicon_OS, repertoire_sortie, temps_crop_inf, temps_crop_sup,st_protocole)
%% Les efforts exterieur dépendent du mouvement réalisé


if contains(nom_fichier,'Planche')
    EFFORTS_EXT='EFFORTS_EXT_PLANCHE';
elseif contains(nom_fichier,'Yg')
    EFFORTS_EXT='EFFORTS_EXT_YG';
elseif contains(nom_fichier,'ATR')
    EFFORTS_EXT='EFFORTS_EXT_ATR';
elseif contains(nom_fichier,'Sissone')
    EFFORTS_EXT='EFFORTS_EXT_SISSONE';
elseif contains(nom_fichier,'Souplesse_A_')
    EFFORTS_EXT='EFFORTS_EXT_SOUPLESSE_AVANT';
elseif contains(nom_fichier,'Souplesse_AR')
    EFFORTS_EXT='EFFORTS_EXT_SOUPLESSE_ARRIERE';
else
    EFFORTS_EXT='EFFORTS_EXT';
end

st_efforts=struct;
En_tete='time';

numeros_plateformes=st_protocole.(EFFORTS_EXT).num_plat;
noms_efforts=st_protocole.(EFFORTS_EXT).nom;
for i_effort=1:length(noms_efforts)
    cur_nom_effort=noms_efforts{i_effort};
    cur_nom_force=st_protocole.(EFFORTS_EXT).force{i_effort};
    cur_nom_moment=st_protocole.(EFFORTS_EXT).moment{i_effort};
    cur_nom_point=st_protocole.(EFFORTS_EXT).point{i_effort};
    cur_nom_applied_body=st_protocole.(EFFORTS_EXT).applied_body{i_effort};
    cur_expression_body=st_protocole.(EFFORTS_EXT).expression_body{i_effort};

    st_efforts.(cur_nom_effort).force=cur_nom_force;
    st_efforts.(cur_nom_effort).moment=cur_nom_moment;
    st_efforts.(cur_nom_effort).point=cur_nom_point;
    st_efforts.(cur_nom_effort).body_applied=cur_nom_applied_body;
    st_efforts.(cur_nom_effort).expression_body=cur_expression_body;

    En_tete=[En_tete ['\t', [cur_nom_force 'x']]];
    En_tete=[En_tete ['\t', [cur_nom_force 'y']]];
    En_tete=[En_tete ['\t', [cur_nom_force 'z']]];
    En_tete=[En_tete ['\t', [cur_nom_point 'x']]];
    En_tete=[En_tete ['\t', [cur_nom_point 'y']]];
    En_tete=[En_tete ['\t', [cur_nom_point 'z']]];
    En_tete=[En_tete ['\t', [cur_nom_moment 'x']]];
    En_tete=[En_tete ['\t', [cur_nom_moment 'y']]];
    En_tete=[En_tete ['\t', [cur_nom_moment 'z']]];
end 

%% écriture des fichiers des efforts pour une utilisation d'OpenSim.
% les données d'entrée viennent d'une matrice (initialement le découpage de
% cycle d'analyse du mouvement).
Wrench=StructureWrenchTest(chemin_c3d,M_pass_Vicon_OS,numeros_plateformes);


temps=data_c3d.fp_data.Time;
tmp_temps=abs(temps-temps_crop_inf);
crop_inf=find(tmp_temps==min(tmp_temps));
tmp_temps=abs(temps-temps_crop_sup);
crop_sup=find(tmp_temps==min(tmp_temps));

donnees=temps(crop_inf:crop_sup);

for i_plateformes=1:length(numeros_plateformes)
    cur_num=numeros_plateformes{i_plateformes};
    cur_F=Wrench.(['PFF',num2str(cur_num)])(crop_inf:crop_sup,1:3);
    cur_M=Wrench.(['PFF',num2str(cur_num)])(crop_inf:crop_sup,4:6)*(1/1000);
    cur_P=0*cur_F;
    donnees=[donnees cur_F];
    donnees=[donnees cur_P/1000];%Passage de mm à m pour Opensim
    donnees=[donnees cur_M];
    
end

%% REMPLACER LES NAN DANS DONNEES PAR DES ZEROS POUR L'ID
tmp=size(donnees);
for i=1:tmp(1)*tmp(2)
    if isnan(donnees(i))
        donnees(i)=0;
    end
end


%% écriture de l'en-tête
% mkdir(fullfile(repertoire_sortie, strcat(nom_fichier,'.mot')));
cd(repertoire_sortie) %On se place dans le répertoire de sortie pour enregistrer au bon endroit

nb_row=length(temps(crop_inf:crop_sup));

if contains(nom_fichier,' ') % Changement du nom du c3d s'il contient un espace, on le remplace par un '_'.
    ind_espace=strfind(nom_fichier,' ');
    nom_fichier(ind_espace)='_';
end

nom_fichier_avec_ext=[nom_fichier '.mot'];
fid=fopen(nom_fichier_avec_ext,'w');
fprintf(fid, nom_fichier_avec_ext);
fprintf(fid, '\nversion=1\n');
fprintf(fid, strcat(['nRows=', num2str(nb_row),'\n']));
fprintf(fid, strcat(['nColumns=',num2str(size(donnees,2)),'\n']));
fprintf(fid, '%s\n','inDegrees=yes');
fprintf(fid, '%s\n','endheader');
fprintf(fid, strcat([En_tete,'\n']));
formatSpec = repmat('%f\t ',[1,size(donnees,2)]);
fprintf(fid, [formatSpec '\n'], donnees');
fclose(fid);

end