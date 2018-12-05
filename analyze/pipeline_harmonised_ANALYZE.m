   function [] = pipeline_harmonised_ANALYZE(cur_sujet,mysituation_name,mycinfile_nom,rep_global,myosim_Matlab_name,st_protocole,plugin_STJ)
% Version:     24/03/2017
% Langage:     Matlab R2016a (PC)
%______________________________________________________________________
%
% Projet FRM/Golf
%___________________________________________________________________________
%
% Description de la fonction : effectue, en batch OpenSim, le calcul de la
% cinématique inverse pour un fichier source .trc unique
%___________________________________________________________________________
%
% Paramètres d'entrée  :
%
% mypatient_name : string donnant le nom du patient (obtenu par lecture du
% dossier dans le code FRM_main_OS_treatment.m
%%% exemple : 'SA09AS_T0S_R1'

% my_osim_folder : string donnant le nom du dossier où sont stockés
% les modèles .osim issus du scaling. Commun à toute l'architecture. Permet
% d'aller chercher le modèle final scalé .osim de manière automatique
%%% actuellement : 'Modele_Osim_scaled'

% mysituation_name: string définissant le type de mouvement étudié, en accord avec
% nomenclature des fichiers Vicon/FRET.
%%% exemple : 'Propulsion', 'StartUp'

% myblock_name: string définissant le block étudié parmi la
% session/situation définie précédemment
%%% exemple : 'SA09AS_T0S_R1_ES1' , 'SA09AS_T0S_R1_ES2'

% mycinfile_nom: string définissant le nom du fichier .trc à traiter
%%% exemple : 'SA09AS_T0S_ES1_Propulsion_1.trc'

% rep_global : chemin du répertoire global contenant les différents
% sujets_sessions et le dossier info_global.
% Obtenu par uigetdir en utilisant le programme FRM_main_OS_treatment.m
%%% exemple : 'D:\OpenSim_2016\workingfile_test_automatisation'



% Paramètres de sortie :
% Les outputs sont écrits dans le même répertoire que celui contenant les
% données brutes .trc

%%% Fichier _ik.mot

%%% Fichier .xml de Setup_ANALYZE

%___________________________________________________________________________

%Le code peut être lancé individuellement en spécifiant tous les inputs en brut, ou
%bien de manière automatisée en bouclant sur différents essais, auquel cas
%il faut utiliser le fichier FRM_main_OS_treatment.m
%
%___________________________________________________________________________
%
% Mots clefs : OpenSim, ANALYZE, boucles
%___________________________________________________________________________

% LBM / Institut de Biomécanique Humaine Georges Charpak
% ENSAM C.E.R. de PARIS
% 151, bld de l'Hôpital
% 75013 PARIS
%__________________________________________________________________________

%%% Définition des répertoires de travail, à partir des inputs
% rep_osim = fullfile(rep_global, cur_sujet, my_osim_folder);
output_rep_analyze = fullfile(rep_global,cur_sujet,mysituation_name,[mycinfile_nom(1:end-4) '_ANALYZE']);%,mycinfile_nom(1:end-4));
rep_mot= fullfile(rep_global,cur_sujet,mysituation_name);
myIKfile = fullfile( rep_mot , [mycinfile_nom(1:end-4), '_ik_lisse.mot'] ) ; % résultat de la cinématique inverse
markerfileOS = mycinfile_nom ;

mycinfile_path = fullfile(rep_mot,mycinfile_nom) ;
data_trc = lire_donnees_trc(mycinfile_path) ; % extraction de la longueur du fichier statique utilisé

GRF_xmlfile = fullfile(rep_mot, [mycinfile_nom(1:end-4), '_GRF.xml'] ) ;
[~,GRF_xmlfile_name, GRF_xmlfile_ext] = fileparts(GRF_xmlfile) ;


disp(' ');
disp(' xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'),
disp(' ');
disp(['         ANALYZE   -  traitement du fichier ' mycinfile_nom(1:end-4)] ) ;
disp(' ');
disp(' xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'),
disp(' ')
%   chemins relatifs par rapport à l'emplacement du .xml à écrire
% modelfileOS = fullfile(rep_global,cur_sujet,'modele', [cur_sujet '_model_final.osim']);
% modelfileOS = fullfile(rep_global,cur_sujet,'modele', [cur_sujet '_model_final_FRM.osim']);
% modelfileOS = fullfile(rep_global,cur_sujet,'modele',[myosim_Matlab_name(1:end-5) '_unconstrained.osim']);
% modelfileOS = [myosim_Matlab_name(1:end-5) '_unconstrained.osim'];
modelfileOS = [myosim_Matlab_name];

% xxxxxxxxxxxxxxxxxx
%   Ecriture du fichier xml
setup_ANALYZE(...
    'ModelFile', modelfileOS, ...
    'InitialTime', num2str(data_trc.tps(1)) ,...
    'FinalTime', num2str(data_trc.tps(end)) ,...
    'ResultsDirectory', output_rep_analyze,...
    'Result_IK',myIKfile,...
    'MarkerFile', markerfileOS,...
    'GRFFile', fullfile(rep_global,cur_sujet,mysituation_name,[GRF_xmlfile_name, GRF_xmlfile_ext]),...
    'st_protocole',st_protocole);


% xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
%           run the ANALYZE tool from the command line
% xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

com = ['analyze -S ' fullfile(output_rep_analyze, [markerfileOS(1:end-4) '_Setup_ANALYZE.xml' ' -L ' plugin_STJ]) ];
dos(com)


disp('') ;
disp('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx') ;
disp('') ;
disp('          Fin de traitement   ANALYZE') ;
disp('') ;
disp('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx') ;


end