function [] = preparationDataFRM(fichier_prot,path_c3d,cur_static,crop_inf,crop_sup)

% La fonction permet d'extraire du .c3d un fichier .trc entre les frames [crop_inf , crop_sup]
% et permet d'am�liorer les donn�es cin�matiques (disparition de marqueurs,
% etc.) par interpolation ou recalage rigide

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%ARGUMENTS D'ENTREE 
% - Fichier protocole : fichier .protOS qui correspond � la manip associ�e,
% et d�clare notamment les marqueurs des diff�rents segments, pour le recalage rigide. 
% e.g : fichier_prot = 'E:\MusculoSkeletalModelling\ModeleScapula\traitementOpenSim_scalingSansContrainte\info_global\FRM_bilateral_STJ.protOS' ;

% - Chemin du c3d : fichier d'analyse du mouvement trait�, contenant les
% coordonn�es 3D de tous les marqueurs, �ventuellement sur une dur�e plus
% longue que la tache � �tudier
% e.g : path_c3d = 'E:\MusculoSkeletalModelling\SP01SM_Propulsion_roue_reculee_03.c3d';

% - Frame de d�but de t�che : num�ro de la frame de d�but de t�che (fin du cycle
% de propulsion, fin du service tennis, etc.)
% e.g : crop_inf = 397 ;
% - Frame de fin de t�che : num�ro de la frame de fin de t�che (fin du cycle
% de propulsion, fin du service tennis, etc.)
% e.g : crop_sup = 555 ;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% 1 DATA 

%Ouverture des donn�es
[dossier_c3d,nom_c3d,~] = fileparts(path_c3d) ;
st_protocole_pretraitement = lire_fichier_prot_2(fichier_prot);
[st_marqueurs_cine,st_VICON] = lire_donnees_c3d(path_c3d);
Marqueurs = fieldnames(st_marqueurs_cine);
[~,~,side] = side_of_acquisition(nom_c3d);

<<<<<<< HEAD

%1.2 Am�lioration des donn�es cin�matique
%1.2.1 Changement de syst�me d'axe pour �viter gimbal lock
if ~exist('M_pass_VICON_OS','var'), 
    M_pass_VICON_OS = [[1 0 0]',[0 0 1]',[0 -1 0]'] ;
end
for i_marqueur = 1:size(Marqueurs,1)
    Data_R0= st_marqueurs_cine.(Marqueurs{i_marqueur});
    Data_R1= M_pass_VICON_OS' * Data_R0';
    st_marqueurs_cine.(Marqueurs{i_marqueur}) = Data_R1';
end

=======
%% 2 DATA CORRECTION
>>>>>>> dev_diane_ENSAM

%2.1 Interpolation si petit trous
taille_trou = 15;
n_mg = 5;
nb_min_points = round( taille_trou/2);

for i_marqueur = 1:size(Marqueurs,1)
    Data = st_marqueurs_cine.(Marqueurs{i_marqueur});
    Data_output = bouche_petits_trous_coord3D(Data,n_mg,taille_trou,nb_min_points);
    st_marqueurs_cine.(Marqueurs{i_marqueur}) = Data_output;
end

%2.2 Recalage rigide si gros trous
list_seg=fieldnames(st_protocole_pretraitement.SEGMENTS);
nb_seg=size(list_seg,1);
for i_seg=1:nb_seg
    cur_seg=list_seg{i_seg};
    Marqueurs_Segment=st_protocole_pretraitement.SEGMENTS.(cur_seg);
    if strcmp(cur_seg,'scapula_locator')
        Marqueurs_Segment{find(strcmp(Marqueurs_Segment,'SCLHL'))}=['SCLHL' side];
        Marqueurs_Segment{find(strcmp(Marqueurs_Segment,'SCLHM'))}=['SCLHM' side];
        Marqueurs_Segment{find(strcmp(Marqueurs_Segment,'SCLL'))}=['AA' side];
        Marqueurs_Segment{find(strcmp(Marqueurs_Segment,'SCLM'))}=['TS' side];
        Marqueurs_Segment{find(strcmp(Marqueurs_Segment,'SCLB'))}=['AI' side];
    end
    [st_marqueurs_cine,flag_marqueur_absent] = recalage_rigide_grands_trous(st_marqueurs_cine,Marqueurs_Segment);

%2.3 ...puis recallage rigide si marqueur totalement absent
    if flag_marqueur_absent
        try
            st_marqueurs_cine = recalage_rigide_absent(st_marqueurs_cine,Marqueurs_Segment,cur_seg,cur_static);
        catch
            disp(['!!! Erreur recalage rigide pour ',cur_seg,', marqueurs manquants dans le c3d !!!'])
        end
    end    
end %for i_seg

%2.4 Re interpolation si petits trous
for i_marqueur = 1:size(Marqueurs,1)
    Data = st_marqueurs_cine.(Marqueurs{i_marqueur});
    Data_output = bouche_petits_trous_coord3D(Data,n_mg,taille_trou,nb_min_points);
    st_marqueurs_cine.(Marqueurs{i_marqueur}) = Data_output;
end

%2.5 Extrapolation sur les bords
for i_marqueur = 1:size(Marqueurs,1)
    st_marqueurs_cine.(Marqueurs{i_marqueur}) = extrapolation_petits_trous_bords(st_marqueurs_cine.(Marqueurs{i_marqueur}),taille_trou,Marqueurs{i_marqueur},path_c3d);
end

<<<<<<< HEAD
% 2.1 D�tection du cas des essais avec ScapLoc 
N_scaploc = 0 ;
for i_mq=1:size(Marqueurs,1)
    if(strcmp(Marqueurs{i_mq,:},'SCLM')==1)
       N_scaploc = N_scaploc + 1 ;
    end
end

% 2.2 D�calage des marqueurs du ScapLoc pour correspondre aux points palp�s
d_ScapLoc = 90 ; %Distance en mm entre les marqueurs r�fl�chissants et les points palp�s sur la scapula
if N_scaploc == 1
    [st_marqueurs_cine] = decalageMarqueursScapLoc(st_marqueurs_cine,d_ScapLoc) ;
end

VICON_cine.Marqueurs=st_marqueurs_cine;
=======
%% SAVE
st_VICON.Marqueurs=st_marqueurs_cine;

>>>>>>> dev_diane_ENSAM
if ~exist('crop_inf','var'), crop_inf=[]; end
if ~exist('crop_sup','var'), crop_sup=[]; end
ecriture_fich_trc_crop(st_VICON, nom_c3d ,dossier_c3d,crop_inf, crop_sup);

end