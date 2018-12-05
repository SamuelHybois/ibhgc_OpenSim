function FICH = lire_donnees_trc(fichier)



% Description de la fonction : extrait les données du fichier intitulé
% "fichier" dnas une structure "FICH"
%___________________________________________________________________________
%
% Paramètres d'entrée  :
%
% fichier : string nom du fichier csv exporté à partir de VICON en ASCII
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

%% ************* ouverture fichier
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
    % "DataRate"
    while isempty(strfind(ligne,'DataRate'))
        ligne=fgetl(fid);
        nbligne = nbligne +1 ;
    end;
    lst_param = strread(ligne, '%s');
    ligne = fgetl(fid);
    nbligne = nbligne +1 ;
    str_tmp = strread(ligne,'%s');
    for iparam = 1:length(lst_param)
        if ~isempty( num2str(str_tmp{iparam}) )
            FICH.param_acquis.(lst_param{iparam}) = num2str(str_tmp{iparam});
        else
            FICH.param_acquis.(lst_param{iparam}) = str_tmp{iparam};
        end
    end
    FICH.freq = FICH.param_acquis.CameraRate;
    
    
    % *********** maj noms marqueurs ***********
    % detection de la ligne contenant les noms marqueurs(débute par
    % "Frame"
    while isempty(strfind(ligne,'Frame'))
        ligne=fgetl(fid);
        nbligne = nbligne +1 ;
    end;
    ligne = regexprep(ligne,'\.',''); % *** enlever les points qui pourraient gener l'interpretation
    str_tmp = strread(ligne,'%s');
    FICH.noms = str_tmp(3:end); % *** non prise en compte de la frame et du tps

    fclose(fid);
    
    % *********** maj coordonnées ***********
    m = dlmread(fichier,'\t',nbligne+1,0); 
    m_resh = reshape(m,size(m,1)*size(m,2),1);
    m_resh(find(m_resh==0)) = NaN;
    m_nan = reshape(m_resh,size(m,1),size(m,2));
    
    
    FICH.frame = m_nan(:,1);
    FICH.tps = m_nan(:,2);
    FICH.coord = m_nan(:,3:end);
    FICH.actmec = [];
    FICH.EMG = [];
end