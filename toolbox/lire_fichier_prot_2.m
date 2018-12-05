function [protocole] = lire_fichier_prot_2(fichier_prot)

% Version:     9.2 (2007)
% Langage:     Matlab    Version: 7.5
% Plate-forme: PC 

% Auteurs : H. Goujon X. Bonnet
% Date de création : 06-04-07

% Créé dans le cadre de : Thèse
% Professeur responsable : F. Lavaste
% Revision 2010-05-18: J.Bascou: ajout du nom du fichier en argument
%_________________________________________________________________________
% Laboratoire de Biomécanique LBM
% ENSAM C.E.R. de PARIS                          email: lbm@paris.ensam.fr
% 151, bld de l'Hôpital                          tel:   01.44.24.63.63
% 75013 PARIS                                    fax:   01.44.24.63.66
%__________________________________________________________________________
% Toutes copies ou diffusions de cette fonction ne peut être réalisée sans
% l'accord du LBM
%__________________________________________________________________________
% Version:     9.1 (2006)  
% Description de la fonction : lit le fichier de protocole (.prot)
%__________________________________________________________________________
% Paramètres d'entrée  : 
%   - rep_mesures : adresse du repertoire de mesure ou se trouve le fichier
% .prot
%   - nom_fich: nom du fichier protocole
%
% Paramètres de sortie : 
%   - protocole : structure dont els champs sont définis dans le fichier prot
%___________________________________________________________________________
%

[rep_mesures,nom_fich,~] = fileparts(fichier_prot);

cd(rep_mesures);

% Si le nom de fichier n'est pas renseigné, sélection du premier fichier
% .prot trouvé
    if nargin==1
        % nom du fichier contenant les noms des marqueurs par segment osseux
            a=dir([cd,'\*.protOS']);

        % ouverture du fichier
        if length(a)~=1
            errordlg('il y a plusieurs fichiers de protocole dans le répertoire !!!!')
            return
        else
            nom_fich=a(1).name;
        end
    end
    
%% ouverture du fichier
fid=fopen(nom_fich,'r');
comp = 1;
if fid == -1
    errordlg(['impossible d''ouvrir le fichier' nom_fichier])
    return
    %     fclose(fid)
%     return;
end;


%% Recherche des listes de marqueurs
while ~feof(fid)
    ligne=fgetl(fid);
    %*** itération jusqu a trouver un entete (signe '#')
    while (isempty(strfind(ligne,'#')) || ~isempty( strfind(ligne,'##') ) ) && ~feof(fid)
        ligne=fgetl(fid);
    end;
    if ~feof(fid)
%     if isempty( strfind(ligne,'##') ) % *** verif si champ non annulé
%     (deux signes '##')
        champ = strrep(ligne,'#',''); % **** déclaration d un entete
        [protocole.(champ)] = lire_fichier_prot_args(fid); % **** remplissage de toutes les donnees de l entete
    end
end;
fclose(fid);
