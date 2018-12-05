function st_efforts=ecriture_mot_gym(c3d_file, nom_fichier,M_pass_Vicon_OS, repertoire_sortie, temps_crop_inf, temps_crop_sup,st_protocole,cell_marqueurs)
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
    EFFORTS_EXT='EFFORTS_EXT'; %Si on ne reconnait pas le mouvement on calcule les efforts sur les mains et les pieds dans le doute
end

st_efforts=struct;
En_tete='time';


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

%% Détermination des efforts pour les appuis définis dans le Protocole

data_c3d=btk_loadc3d(c3d_file);
temps=data_c3d.fp_data.Time;
tmp_temps=abs(temps-temps_crop_inf);
crop_inf=find(tmp_temps==min(tmp_temps));
tmp_temps=abs(temps-temps_crop_sup);
crop_sup=find(tmp_temps==min(tmp_temps));

rapport_frequence_fp_vicon=data_c3d.fp_data.Info(1).frequency/data_c3d.marker_data.Info.frequency;
donnees=temps(crop_inf:rapport_frequence_fp_vicon:crop_sup);
crop_inf=ceil(crop_inf/rapport_frequence_fp_vicon);
crop_sup=ceil(crop_sup/rapport_frequence_fp_vicon);

% [pied_D,pied_G,main_D,main_G]=determination_appuis_pf_YP(c3d_file,M_pass_Vicon_OS,noms_efforts,rapport_frequence_fp_vicon,cell_marqueurs);
[pied_D,pied_G,main_D,main_G]=determination_appuis_pf_gym(c3d_file,M_pass_Vicon_OS,noms_efforts,rapport_frequence_fp_vicon,cell_marqueurs);
torseur_pied_D=pied_D.torseur;
torseur_pied_G=pied_G.torseur;
torseur_main_D=main_D.torseur;
torseur_main_G=main_G.torseur;
torseurs={};

%On rempli le torseur d'efforts des efforts présents lors du mouvement
for i_eff=1:length(noms_efforts)
    if contains(noms_efforts{i_eff},'foot') || contains(noms_efforts{i_eff},'pied')
        if contains(noms_efforts{i_eff},'right') || contains(noms_efforts{i_eff},'droit')
            torseurs{end+1}=torseur_pied_D;
        elseif contains(noms_efforts{i_eff},'left') || contains(noms_efforts{i_eff},'gauche')
            torseurs{end+1}=torseur_pied_G;
        end
    elseif contains(noms_efforts{i_eff},'hand') || contains(noms_efforts{i_eff},'main')
        if contains(noms_efforts{i_eff},'right') || contains(noms_efforts{i_eff},'droit')
            torseurs{end+1}=torseur_main_D;
        elseif contains(noms_efforts{i_eff},'left') || contains(noms_efforts{i_eff},'gauche')
            torseurs{end+1}=torseur_main_G;
        end
    end
end
            
%% écriture des fichiers des efforts pour une utilisation d'OpenSim.

for i_appui=1:length(noms_efforts)
    cur_F=torseurs{i_appui}(crop_inf:crop_sup,1:3);
    cur_M=torseurs{i_appui}(crop_inf:crop_sup,4:6);
    cur_P=torseurs{i_appui}(crop_inf:crop_sup,7:9);
    donnees=[donnees cur_F];
    donnees=[donnees cur_P/1000]; %Passage de mm à m pour Opensim
    donnees=[donnees cur_M];
    
end

%% écriture de l'en-tête
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