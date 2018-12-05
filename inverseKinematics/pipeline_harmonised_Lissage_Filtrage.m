function [myIKfile_lisse] = pipeline_harmonised_Lissage_Filtrage(cur_sujet,mysituation_name,mycinfile_nom,rep_global,type_filtre)
% Version:     24/02/2016
% Langage:     Matlab R2016a (PC)
%______________________________________________________________________
%
% Projet FRM/Golf
%___________________________________________________________________________
%
% Description de la fonction : effectue le lissage/filtrage du résultat de
% l'optimisation cinématique
%___________________________________________________________________________
%
% Paramètres d'entrée  :
%
% mypatient_name : string donnant le nom du patient (obtenu par lecture du
% dossier dans le code FRM_main_OS_treatment.m
%%% exemple : 'SA09AS_T0S_R1'

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

%%% Fichier _ik.mot Lissé ou filtré
%___________________________________________________________________________
% Corrections : 
% 04/12/17 TM et CS
% Possibilité choisir fréquence et ordre pour BW et nb_valeur et nb_passe
% pour MG (dans le prot, déclarer type_filtre=BW,freq,ordre et
% type_filtre=MG,nb_valeur,nb_passe
%___________________________________________________________________________

%Le code peut être lancé individuellement en spécifiant tous les inputs en brut, ou
%bien de manière automatisée en bouclant sur différents essais, auquel cas
%il faut utiliser le fichier FRM_main_OS_treatment.m
%
%___________________________________________________________________________
%
% Mots clefs : OpenSim, cinématique inverse, filtrage, lissage
%___________________________________________________________________________

% LBM / Institut de Biomécanique Humaine Georges Charpak
% ENSAM C.E.R. de PARIS
% 151, bld de l'Hôpital
% 75013 PARIS
%__________________________________________________________________________

%%% Définition des répertoires de travail, à partir des inputs
output_rep_cine = fullfile(rep_global,cur_sujet,mysituation_name);%,mycinfile_nom(1:end-4));


disp('') ;
disp('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx') ;
disp('') ;
disp(['          Filtrage/LISSAGE du résultat de Cinématique INVERSE ' mycinfile_nom]) ;
disp('') ;
disp('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx') ;

% Définition des arguments
type=type_filtre{1};
if length(type_filtre)==1
    if strcmp(type,'MG')
        freq=5; % Moyenne glissante sur 5 valeurs par défaut
        passes=1;
    elseif strcmp(type,'BW')
        freq=6; % Fitre de ButterWorth à fc=6Hz par défaut
        passes=2; % Correspond à l'ordre
    end
else
    freq=str2double(type_filtre{2});
    passes=str2double(type_filtre{3});
end
%Lecture du fichier ik.mot

donnees_ik=lire_donnee_ik_mot(fullfile(output_rep_cine,[mycinfile_nom(1:end-4),'_ik.mot']));


switch type
    
    case 'MG' % Moyenne glissante
        
        for i_coord=1:size(donnees_ik.coord,2)
            for i_passe=1:passes
                donnees_ik.coord(:,i_coord)=fct_moyenne_glissante(donnees_ik.coord(:,i_coord),freq);
            end
        end
        
    case 'BW' % Butterworth Ordre 2 filfilt
        
        %On récupère le c3d pour avoir l'info sur la fréquence d'acquisition
        FICH = lire_donnees_trc(fullfile(output_rep_cine,mycinfile_nom));
        
        % Construction du filtre
        fc = freq; % fréquence de coupure du filtre
        order = passes; % ordre du butterworth
        
        if order > 0 %Correction for filter order to ensure 1/sqrt(2) transfer at fc
            fc = fc /(sqrt(2) - 1)^(0.5/order);
        end
        
        fs = str2double(FICH.freq) ; % fréquence d'échantillonnage
        wn = 2*fc/fs; % période du filtre
        [b,a] = butter(order,wn); %filtre butter
        
        for i_coord = 1:size(donnees_ik.coord,2)
            
            donnees_ik.coord(:,i_coord)= filtfilt(b,a,donnees_ik.coord(:,i_coord)); %filtfilt
            
        end
        
end

donnees_ik.coord(isnan(donnees_ik.coord))=0;
nom_sortie=[mycinfile_nom(1:end-4),'_ik_lisse.mot'];
reecriture_fich_ik_mot(donnees_ik,nom_sortie,output_rep_cine);

disp('') ;
disp('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx') ;
disp('') ;
disp('          Fin de traitement Filtrage/LISSAGE') ;
disp('') ;
disp('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx') ;





end