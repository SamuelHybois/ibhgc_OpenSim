function st_efforts=harmonised_ecriture_mot_effort_TdT(data_c3d, nom_fichier,chemin_c3d,M_pass_Vicon_OS, repertoire_sortie, temps_crop_inf, temps_crop_sup,st_protocole)

numeros_plateformes=st_protocole.EFFORTS_EXT.num_plat;
% numeros_plateformes{1}=3;
% numeros_plateformes{2}=4;
Wrench=StructureWrenchTest(chemin_c3d,M_pass_Vicon_OS,numeros_plateformes);
% écriture des fichiers des efforts pour une utilisation d'OpenSim.
% les données d'entrée viennent d'une matrice (initialement le découpage de
% cycle d'analyse du mouvement).

%% Pour le TdT, on a deux plateformes pour un seul effort, il faut les ajouter pour avoir un effort résultant sur le pied droit
Wrench_total=Wrench.PFF1+Wrench.PFF2;
noms_efforts=st_protocole.EFFORTS_EXT.nom;
st_efforts=struct;
En_tete='time';
temps=data_c3d.fp_data.Time;
tmp_temps=abs(temps-temps_crop_inf);
crop_inf=find(tmp_temps==min(tmp_temps));
tmp_temps=abs(temps-temps_crop_sup);
crop_sup=find(tmp_temps==min(tmp_temps));

donnees=temps(crop_inf:crop_sup);
for i_effort=1:length(noms_efforts)
    cur_nom_effort=noms_efforts{i_effort};
    cur_nom_force=st_protocole.EFFORTS_EXT.force{i_effort};
    cur_nom_moment=st_protocole.EFFORTS_EXT.moment{i_effort};
    cur_nom_point=st_protocole.EFFORTS_EXT.point{i_effort};
    cur_nom_applied_body=st_protocole.EFFORTS_EXT.applied_body{i_effort};
    cur_expression_body=st_protocole.EFFORTS_EXT.expression_body{i_effort};
    
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


cur_F=Wrench_total(crop_inf:crop_sup,1:3);
cur_M=Wrench_total(crop_inf:crop_sup,4:6);
cur_P=0*cur_F;
donnees=[donnees cur_F];
donnees=[donnees cur_P];
donnees=[donnees cur_M];

% création de l'en-tête :



% écriture de l'en-tête
% mkdir(fullfile(repertoire_sortie, strcat(nom_fichier,'.mot')));
% cd(repertoire_sortie)

nb_row=length(temps(crop_inf:crop_sup));

if ~isempty(strfind(nom_fichier,' ')) % Changement du nom du c3d s'il contient un espace, on le remplace par un '_'.
    ind_espace=strfind(nom_fichier,' ');
    nom_fichier(ind_espace)='_';
end

nom_fichier_avec_ext=[nom_fichier '.mot'];
fid=fopen(fullfile(repertoire_sortie, nom_fichier_avec_ext),'w');
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