function FICH = lire_donnee_ik_mot(fichier)

% Description de la fonction : extrait les données du fichier intitulé
% "fichier" dnas une structure "FICH"
%___________________________________________________________________________
%
% Paramètres d'entrée  :
%
% fichier : string nom du fichier ik.mot exporté à partir de OPENSIM
%
% Paramètres de sortie :
%
% FICH : structure a 4 champs : noms, coord, actmec, EMG, param_acquis,frame,tps contenant la liste
% des noms de marqueurs, la matrice des coordonnees des marqueurs, la
% matrice des actions mécaniques et la matrice des EMG, les parametres
% d'acquisition, le numéro de prise de mesure et le temps auquel cette
% mesure a été prise.
%___________________________________________________________________________
%
% Notes :
%___________________________________________________________________________
%
% Fichiers, Fonctions ou Sous-Programmes associés
%
% Appelants :
% recherche_points
%
% Appelés : extraire_noms
%___________________________________________________________________________
%
% Mots clefs : extraction de donnees dans un fichier csv, analyse de la
% marche
%___________________________________________________________________________

%% ************* ouverture fichier *************
fid=fopen(fichier,'r');
if isempty(fichier) || fid==-1
    FICH.noms=0;
    FICH.coord=0;
    disp('le fichier n''existe pas')
else
    ligne=fgetl(fid);
    nbligne =1;
    % *********** maj infos acquisition ***********
    % detection de la ligne contenant les parametres acquisition (débute par
    % "Coordinates"
    while isempty(strfind(ligne,'Coordinates'))
        ligne=fgetl(fid);
        nbligne = nbligne +1 ;
    end;
    
    lst_param = strread(ligne, '%s');
    
    ligne = fgetl(fid);
    nbligne = nbligne +1 ;
    
    str_tmp = strread(ligne,'%s');
    str_tmp = cell2mat(str_tmp);
    x = strfind( str_tmp , '=' ) ;
    
    FICH.version = str_tmp(x+1:end) ;
    
    ligne = fgetl(fid);
    nbligne = nbligne +1 ;
    
    str_tmp = strread(ligne,'%s');
    str_tmp = cell2mat(str_tmp);
    x = strfind( str_tmp , '=' ) ;
    
    FICH.nRows = str_tmp(x+1:end) ;
    
    ligne = fgetl(fid);
    nbligne = nbligne +1 ;
    
    str_tmp = strread(ligne,'%s');
    str_tmp = cell2mat(str_tmp);
    x = strfind( str_tmp , '=' ) ;
    
    FICH.nColumns = str_tmp(x+1:end) ;
    
    ligne = fgetl(fid);
    nbligne = nbligne +1 ;
    
    str_tmp = strread(ligne,'%s');
    str_tmp = cell2mat(str_tmp);
    x = strfind( str_tmp , '=' ) ;
    
    FICH.inDegrees = str_tmp(x+1:end) ;
    
    while isempty(strfind(ligne,'Units'))
        ligne=fgetl(fid);
        nbligne = nbligne +1 ;
        FICH.Units{1} = ligne ;
    end;
    
    ligne=fgetl(fid);
    nbligne = nbligne +1 ;
    FICH.Units{2} = ligne ;
    
    while isempty(strfind(ligne,'endheader'))
        ligne=fgetl(fid);
        nbligne = nbligne +1 ;
    end;
    
    
    % *********** maj noms marqueurs ***********
    % detection de la ligne contenant les noms marqueurs(débute par
    % "time"
    while isempty(strfind(ligne,'time'))
        ligne=fgetl(fid);
        nbligne = nbligne +1 ;
    end;
    ligne = regexprep(ligne,'\.',''); % *** enlever les points qui pourraient gener l'interpretation
    str_tmp = strread(ligne,'%s');
    FICH.noms = str_tmp(2:end); % *** non prise en compte du tps
    
    fclose(fid);
    
    % *********** maj coordonnées ***********
    m = dlmread(fichier,'\t',nbligne,0);
    m_resh = reshape(m,size(m,1)*size(m,2),1);
    m_resh(m_resh==0) = NaN;
    m_nan = reshape(m_resh,size(m,1),size(m,2));
       
    FICH.tps = m_nan(:,1);
    FICH.coord = m_nan(:,2:end);
    FICH.actmec = [];
    FICH.EMG = [];
end