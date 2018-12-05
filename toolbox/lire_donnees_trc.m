function FICH = lire_donnees_trc(fichier)



% Description de la fonction : extrait les donn�es du fichier intitul�
% "fichier" dnas une structure "FICH"
%___________________________________________________________________________
%
% Param�tres d'entr�e  :
%
% fichier : string nom du fichier csv export� � partir de VICON en ASCII
%
% Param�tres de sortie :
%
% FICH : structure a 4 champs : noms, coord, actmec, EMG, param_acquis,frame,tps contenant la liste
% des noms de marqueurs, la matrice des coordonnees des marqueurs, la
% matrice des actions m�caniques et la matrice des EMG, les parametres
% d'acquisition, le num�ro de prise de mesure et le temps auquel cette
% mesure a �t� prise.
%___________________________________________________________________________
%
% Notes :
%___________________________________________________________________________
%
% Fichiers, Fonctions ou Sous-Programmes associ�s
%
% Appelants :
% recherche_points
%
% Appel�s : extraire_noms
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
    % detection de la ligne contenant les parametres acquisition (d�bute par
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
    % detection de la ligne contenant les noms marqueurs(d�bute par
    % "Frame"
    while isempty(strfind(ligne,'Frame'))
        ligne=fgetl(fid);
        nbligne = nbligne +1 ;
    end;
    ligne = regexprep(ligne,'\.',''); % *** enlever les points qui pourraient gener l'interpretation
    str_tmp = strread(ligne,'%s');
    FICH.noms = str_tmp(3:end); % *** non prise en compte de la frame et du tps

    fclose(fid);
    
    % *********** maj coordonn�es ***********
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