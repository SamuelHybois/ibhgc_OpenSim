function [ ] = crea_xml_scalemesset_from_protOS( protocole, file_sortie_xmlscale_measur_set)

% Objectif
%   - Création fichier.xml, définissant la manière de mettre le modèle à
%   l'échelle.
%   - A partir d'un fichier protocole
%   ex: quels marqueurs prendre pour changer l'échelle de la largeur de torse
%
% En entrée
%   - scaling_prot_file : répertoire + fichier protocole décrivant les marqueurs à
%                       utiliser pour mettre à l'échelle les segments du modèle
%                       (ex: d:\opensimtest\prot\frm.protOS)
%   - file_scale_measureset : répertoire et nom du fichier .xml à créer
%                       (ex: d:\opensimtest\frm_scale_measurementset.xml)
%
% En sortie
%   - fichier.xml créé, dont les nom et répertoire sont définis dans "file_scale_measureset"



%% xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
%           Début de fonction
% xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

% prot_file = 'H:\01-projets\FRM_propulsion\2015_siegel\__debug\automat_opensim\test\FRM.protOS' ;
% file_sortie_xmlscaleset = 'H:\01-projets\FRM_propulsion\2015_siegel\__debug\automat_opensim\test\testscalset.xml' ;

disp(' ');
disp('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx') ;
disp('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx') ;
disp(' '); disp('          lancement fonction "creation_xmltask_from_protOS" ... ') ;
disp(' ');

% xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
%           Répertoires et noms de fichiers à créer
% xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
[rep_sortie_fichiers, nom_scale_mesurement_set, ~] = fileparts( file_sortie_xmlscale_measur_set );

% xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
%           Lecture protocole
% xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

% récupération et écriture des informations de scaling
noms_scaling=fieldnames(protocole.SCALING);
nb_scaling=length(noms_scaling);


% xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
%           Début de création du fichier XML
% xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

% création du répertoire si non existant
mkdir( rep_sortie_fichiers ) ;

% début d'écriture
fid=fopen( file_sortie_xmlscale_measur_set, 'w' );

%% écriture de l'en-tête de scaling
fprintf(fid,'%s\n','<?xml version="1.0" encoding="UTF-8" ?>');
fprintf(fid,'%s\n','<!--Body segments are scaled by calculating the average distance between');
fprintf(fid,'%s\n','specified marker pairs.  The ratio between the averaged distance to the ');
fprintf(fid,'%s\n','distance in the generic model is then used to scale each specified segment ');
fprintf(fid,'%s\n','in the specified axis directions (e.g., X Y Z).-->');
fprintf(fid,'%s\n', ['<MeasurementSet name="', nom_scale_mesurement_set, '">']);
fprintf(fid,'\t%s\n','<objects>');

%% écriture des informations de scaling
for i=1:nb_scaling,
    nom_courant=noms_scaling{i};
    name=nom_courant(1:end-1);
    axe=nom_courant(end:end);
    
    h = size( protocole.SCALING.( nom_courant), 2 ); % nb de marqueurs utilisés
    
    if h>=2,
        fprintf(fid,'\t\t%s\n', ['<Measurement name="',nom_courant,'">']);
        fprintf(fid,'\t\t\t%s\n','<apply>true</apply>');
        fprintf(fid,'\t\t\t%s\n','<MarkerPairSet>');
        fprintf(fid,'\t\t\t\t%s\n','<objects>');
        
        
        
        %récupération des noms des marqueurs de scaling dans le cas où on
        %fait du simple scaling sur un seule axe
        X1=protocole.SCALING.(nom_courant){1} ;
        X2=protocole.SCALING.(nom_courant){2} ;
        fprintf(fid,'\t\t\t\t\t%s\n','<MarkerPair>');
        fprintf(fid,'\t\t\t\t\t\t%s\n', ['<markers> ',X1,' ',X2,'</markers>']);
        fprintf(fid,'\t\t\t\t\t%s\n','</MarkerPair>');
        if h==4
            %récupération des noms des marqueurs de scaling dans le cas où on
            %fait du double scaling sur le même élément et le même axe
            X3=protocole.SCALING.(nom_courant){3} ;
            X4=protocole.SCALING.(nom_courant){4} ;
            
            fprintf(fid,'\t\t\t\t\t%s\n','<MarkerPair>');
            fprintf(fid,'\t\t\t\t\t\t%s\n', ['<markers> ',X3,' ',X4,'</markers>']);
            fprintf(fid,'\t\t\t\t\t%s\n','</MarkerPair>');
        end
        if ~h==2 && ~h==4
            disp( ['!!!!!!!       probleme de scaling sur ', nom_courant, '  ... le nb de marqueurs est différent de 2 ou 4']);
        end
    end
    
    fprintf(fid,'\t\t\t\t%s\n','</objects>');
    fprintf(fid,'\t\t\t%s\n','<groups />');
    fprintf(fid,'\t\t\t%s\n','</MarkerPairSet>');
    fprintf(fid,'\t\t%s\n','<BodyScaleSet>');
    fprintf(fid,'\t\t\t\t%s\n','<objects>');
    fprintf(fid,'\t\t\t\t\t%s\n', ['<BodyScale name="',name,'">']);
    fprintf(fid,'\t\t\t\t\t\t%s\n', ['<axes> ',axe,'</axes>']);
    fprintf(fid,'\t\t\t\t\t%s\n','</BodyScale>');
    fprintf(fid,'\t\t\t\t%s\n','</objects>');
    fprintf(fid,'\t\t\t\t%s\n','<groups />');
    fprintf(fid,'\t\t\t%s\n','</BodyScaleSet>');
    fprintf(fid,'\t\t%s\n','</Measurement>');
end


fprintf(fid,'\t%s\n','</objects>');
fprintf(fid,'\t%s\n','<groups />');
fprintf(fid,'%s\n','</MeasurementSet>');

fclose(fid);

disp('Scaling_Setup.xml has been created')
disp(' ');
disp(' '); disp('          Fin de fonction "creation_xmltask_from_protOS" ... ') ;
disp(' '); disp('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx') ;
disp('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx') ;



end  % end function

