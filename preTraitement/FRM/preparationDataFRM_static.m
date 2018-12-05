function cur_static = preparationDataFRM_static(fichier_prot,path_static,path_static_r,path_static_l,is_scapula_locator)

% La fonction permet d'extraire du .c3d un fichier .trc et de recaler les
% marqueurs anatomiques de la scapula par rapport au cluster sur une meme
% position de reference grâce à une calibration avec le scaploc
% Diane H, 12.09.2018

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%ARGUMENTS D'ENTREE 
% - Fichier protocole : fichier .protOS qui correspond à la manip associée,
% et déclare notamment les marqueurs des différents segments, pour le recalage rigide. 
% e.g : fichier_prot = 'E:\MusculoSkeletalModelling\ModeleScapula\traitementOpenSim_scalingSansContrainte\info_global\FRM_bilateral_STJ.protOS' ;

% - Chemin du statique : fichier statique c3d, contenant les
% coordonnées 3D de tous les marqueurs 
% e.g : path_static = 'E:\...\static_ref.c3d';

% - Fichier static de calibration a gauche : fichier specifique pour
% recaler le scapula locator par raport au cluster scapula gauche
%
% - Fichier static de calibration a droite : fichier specifique pour
% recaler le scapula locator par raport au cluster scapula droit
%
% - Calibration de la scapula par le scapula locator : 0.absent, 1.deux
% cotes, 2.cote gauche seul,3.cote droit seul
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%1.1 Ouverture des données

[dossier_c3d,nom_c3d,~] = fileparts(path_static) ;
[st_marqueurs_cine,st_VICON] = lire_donnees_c3d(path_static);
st_protocole_pretraitement = lire_fichier_prot_2(fichier_prot);
Marqueurs = fieldnames(st_marqueurs_cine);

%1. Recuperation du scaploc par recallage rigide
 if is_scapula_locator>=1
%1.a) right side
   if is_scapula_locator==1||is_scapula_locator==3,
       % transform static right c3d to trc file
       [st_marqueurs_cine_r,st_VICON_r] = lire_donnees_c3d(path_static_r);
       st_VICON_r.Marqueurs = st_marqueurs_cine_r;

       [rep_c3d_r,file_c3d_r,~] = fileparts(path_static_r) ;
       ecriture_fich_trc_crop(st_VICON_r, file_c3d_r,rep_c3d_r,[],[]);
       path_static_r_trc = char(strrep(path_static_r,'c3d','trc'));
       % incorporate right scaploc into the global static file
%        Marqueurs_Segment=['SCLHMD','TSD','AID','AAD','SCLHLD',cellstr(st_protocole_pretraitement.SEGMENTS.scapula_cluster_r)];
       Marqueurs_Segment=['SCLHMD','SCLHLD',cellstr(st_protocole_pretraitement.SEGMENTS.scapula_r)];
        st_marqueurs_cine = recalage_rigide_absent(st_marqueurs_cine,Marqueurs_Segment,'scapula_locator',path_static_r_trc);
        if is_scapula_locator==3%only right
             st_marqueurs_cine = symetrical_scaploc_mark(st_marqueurs_cine,'D');
        end   
   end
%1.b) left side
   if is_scapula_locator==1||is_scapula_locator==2,
       % transform static left c3d to trc file
       [st_marqueurs_cine_l,st_VICON_l] = lire_donnees_c3d(path_static_l);
       st_VICON_l.Marqueurs = st_marqueurs_cine_l;
       [rep_c3d_l,file_c3d_l,~] = fileparts(path_static_l) ;
       ecriture_fich_trc_crop(st_VICON_l, file_c3d_l,rep_c3d_l,[],[]);
       path_static_l_trc = char(strrep(path_static_l,'c3d','trc'));
       % incorporate right scaploc into the global static file
%        Marqueurs_Segment=['SCLHMG','TSG','AIG','AAG','SCLHLG',cellstr(st_protocole_pretraitement.SEGMENTS.scapula_l)];
       Marqueurs_Segment=['SCLHMG','SCLHLG',cellstr(st_protocole_pretraitement.SEGMENTS.scapula_l)];
       st_marqueurs_cine = recalage_rigide_absent(st_marqueurs_cine,Marqueurs_Segment,'scapula_locator',path_static_l_trc);
       if is_scapula_locator==2%only right
             st_marqueurs_cine = symetrical_scaploc_mark(st_marqueurs_cine,'G');
       end   
   end       
end

st_VICON.Marqueurs=st_marqueurs_cine;

if ~exist('crop_inf','var'), crop_inf=[]; end
if ~exist('crop_sup','var'), crop_sup=[]; end
ecriture_fich_trc_crop(st_VICON, nom_c3d ,dossier_c3d,crop_inf, crop_sup);

end