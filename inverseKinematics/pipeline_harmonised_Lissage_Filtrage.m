function [myIKfile_lisse] = pipeline_harmonised_Lissage_Filtrage(cur_sujet,mysituation_name,mycinfile_nom,rep_global,type_filtre)
% Version:     24/02/2016
% Langage:     Matlab R2016a (PC)
%______________________________________________________________________
%
% Projet FRM/Golf
%___________________________________________________________________________
%
% Description de la fonction : effectue le lissage/filtrage du r�sultat de
% l'optimisation cin�matique
%___________________________________________________________________________
%
% Param�tres d'entr�e  :
%
% mypatient_name : string donnant le nom du patient (obtenu par lecture du
% dossier dans le code FRM_main_OS_treatment.m
%%% exemple : 'SA09AS_T0S_R1'

% mysituation_name: string d�finissant le type de mouvement �tudi�, en accord avec
% nomenclature des fichiers Vicon/FRET.
%%% exemple : 'Propulsion', 'StartUp'

% myblock_name: string d�finissant le block �tudi� parmi la
% session/situation d�finie pr�c�demment
%%% exemple : 'SA09AS_T0S_R1_ES1' , 'SA09AS_T0S_R1_ES2'

% mycinfile_nom: string d�finissant le nom du fichier .trc � traiter
%%% exemple : 'SA09AS_T0S_ES1_Propulsion_1.trc'

% rep_global : chemin du r�pertoire global contenant les diff�rents
% sujets_sessions et le dossier info_global.
% Obtenu par uigetdir en utilisant le programme FRM_main_OS_treatment.m
%%% exemple : 'D:\OpenSim_2016\workingfile_test_automatisation'

% Param�tres de sortie :
% Les outputs sont �crits dans le m�me r�pertoire que celui contenant les
% donn�es brutes .trc

%%% Fichier _ik.mot Liss� ou filtr�
%___________________________________________________________________________
% Corrections : 
% 04/12/17 TM et CS
% Possibilit� choisir fr�quence et ordre pour BW et nb_valeur et nb_passe
% pour MG (dans le prot, d�clarer type_filtre=BW,freq,ordre et
% type_filtre=MG,nb_valeur,nb_passe
%___________________________________________________________________________

%Le code peut �tre lanc� individuellement en sp�cifiant tous les inputs en brut, ou
%bien de mani�re automatis�e en bouclant sur diff�rents essais, auquel cas
%il faut utiliser le fichier FRM_main_OS_treatment.m
%
%___________________________________________________________________________
%
% Mots clefs : OpenSim, cin�matique inverse, filtrage, lissage
%___________________________________________________________________________

% LBM / Institut de Biom�canique Humaine Georges Charpak
% ENSAM C.E.R. de PARIS
% 151, bld de l'H�pital
% 75013 PARIS
%__________________________________________________________________________

%%% D�finition des r�pertoires de travail, � partir des inputs
output_rep_cine = fullfile(rep_global,cur_sujet,mysituation_name);%,mycinfile_nom(1:end-4));


disp('') ;
disp('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx') ;
disp('') ;
disp(['          Filtrage/LISSAGE du r�sultat de Cin�matique INVERSE ' mycinfile_nom]) ;
disp('') ;
disp('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx') ;

% D�finition des arguments
type=type_filtre{1};
if length(type_filtre)==1
    if strcmp(type,'MG')
        freq=5; % Moyenne glissante sur 5 valeurs par d�faut
        passes=1;
    elseif strcmp(type,'BW')
        freq=6; % Fitre de ButterWorth � fc=6Hz par d�faut
        passes=2; % Correspond � l'ordre
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
        
        %On r�cup�re le c3d pour avoir l'info sur la fr�quence d'acquisition
        FICH = lire_donnees_trc(fullfile(output_rep_cine,mycinfile_nom));
        
        % Construction du filtre
        fc = freq; % fr�quence de coupure du filtre
        order = passes; % ordre du butterworth
        
        if order > 0 %Correction for filter order to ensure 1/sqrt(2) transfer at fc
            fc = fc /(sqrt(2) - 1)^(0.5/order);
        end
        
        fs = str2double(FICH.freq) ; % fr�quence d'�chantillonnage
        wn = 2*fc/fs; % p�riode du filtre
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