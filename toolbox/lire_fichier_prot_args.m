function [liste_noms] = lire_fichier_prot_args(fid)


% Version:     9.2 (2007)
% Langage:     Matlab    Version: 7.0
% Plate-forme: PC 

% Auteurs : H. Goujon X. Bonnet
% Date de cr�ation : 06-04-07
% Cr�� dans le cadre de : Th�se
% Professeur responsable : F. Lavaste
%_________________________________________________________________________
% Laboratoire de Biom�canique LBM
% ENSAM C.E.R. de PARIS                          email: lbm@paris.ensam.fr
% 151, bld de l'H�pital                          tel:   01.44.24.63.63
% 75013 PARIS                                    fax:   01.44.24.63.66
%_________________________________________________________________________
% Toutes copies ou diffusions de cette fonction ne peut �tre r�alis�e sans
% l'accord du LBM
%__________________________________________________________________________
% Description de la fonction : lit un bloc de ligne d�limit� par une ligne
% vide en prenant les intitul�s � droite du signe egal et les arguments associ�s
% s�par�s par une virgule � gauche du signe �gal
%__________________________________________________________________________
% Param�tres d'entr�e  : 
%   - fid : ientifiant fichier
%
% Param�tres de sortie : 
%   - liste_noms : structure avec des champs correspondant
% � la liste intitul�
%___________________________________________________________________________

liste_noms=[];
ligne=fgetl(fid); % *** rm: nous sommes a une ligne specifique du fichier

while ~isempty(ligne)
    % *** r�cup�ration de l intitule
    [label,list_arg] = strtok(ligne,'=');
    compt=1; % *** compteur utilis� pour le remplissage de la structure r�sultat
    
    % *** boucle de remplissage des arguments dans la variable r�sultat
    while ~isempty(list_arg)
        [nom_arg,list_arg]=strtok(list_arg,'=,'); % *** s�paration du premier argument de la liste
        liste_noms.(label){compt}=nom_arg; % *** insertion de cet argument dans la structure r�sultat
        compt=compt+1;
    end;
    
    % *** d�tection de fin ou passage a une nouvelle ligne
    if feof(fid)
        break;
    else
        ligne=fgetl(fid); 
    end;
end;