function [ ] = crea_xml_scalemesset_from_protOS( protocole, file_sortie_xmlscale_measur_set)

% Objectif
%   - Cr�ation fichier.xml, d�finissant la mani�re de mettre le mod�le �
%   l'�chelle.
%   - A partir d'un fichier protocole
%   ex: quels marqueurs prendre pour changer l'�chelle de la largeur de torse
%
% En entr�e
%   - scaling_prot_file : r�pertoire + fichier protocole d�crivant les marqueurs �
%                       utiliser pour mettre � l'�chelle les segments du mod�le
%                       (ex: d:\opensimtest\prot\frm.protOS)
%   - file_scale_measureset : r�pertoire et nom du fichier .xml � cr�er
%                       (ex: d:\opensimtest\frm_scale_measurementset.xml)
%
% En sortie
%   - fichier.xml cr��, dont les nom et r�pertoire sont d�finis dans "file_scale_measureset"



%% xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
%           D�but de fonction
% xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

% prot_file = 'H:\01-projets\FRM_propulsion\2015_siegel\__debug\automat_opensim\test\FRM.protOS' ;
% file_sortie_xmlscaleset = 'H:\01-projets\FRM_propulsion\2015_siegel\__debug\automat_opensim\test\testscalset.xml' ;

disp(' ');
disp('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx') ;
disp('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx') ;
disp(' '); disp('          lancement fonction "creation_xmltask_from_protOS" ... ') ;
disp(' ');

% xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
%           R�pertoires et noms de fichiers � cr�er
% xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
[rep_sortie_fichiers, nom_scale_mesurement_set, ~] = fileparts( file_sortie_xmlscale_measur_set );

% xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
%           Lecture protocole
% xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

% r�cup�ration et �criture des informations de scaling
noms_scaling=fieldnames(protocole.SCALING);
nb_scaling=length(noms_scaling);


% xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
%           D�but de cr�ation du fichier XML
% xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

% cr�ation du r�pertoire si non existant
mkdir( rep_sortie_fichiers ) ;

% d�but d'�criture
fid=fopen( file_sortie_xmlscale_measur_set, 'w' );

%% �criture de l'en-t�te de scaling
fprintf(fid,'%s\n','<?xml version="1.0" encoding="UTF-8" ?>');
fprintf(fid,'%s\n','<!--Body segments are scaled by calculating the average distance between');
fprintf(fid,'%s\n','specified marker pairs.  The ratio between the averaged distance to the ');
fprintf(fid,'%s\n','distance in the generic model is then used to scale each specified segment ');
fprintf(fid,'%s\n','in the specified axis directions (e.g., X Y Z).-->');
fprintf(fid,'%s\n', ['<MeasurementSet name="', nom_scale_mesurement_set, '">']);
fprintf(fid,'\t%s\n','<objects>');

%% �criture des informations de scaling
for i=1:nb_scaling,
    nom_courant=noms_scaling{i};
    name=nom_courant(1:end-1);
    axe=nom_courant(end:end);
    
    h = size( protocole.SCALING.( nom_courant), 2 ); % nb de marqueurs utilis�s
    
    if h>=2,
        fprintf(fid,'\t\t%s\n', ['<Measurement name="',nom_courant,'">']);
        fprintf(fid,'\t\t\t%s\n','<apply>true</apply>');
        fprintf(fid,'\t\t\t%s\n','<MarkerPairSet>');
        fprintf(fid,'\t\t\t\t%s\n','<objects>');
        
        
        
        %r�cup�ration des noms des marqueurs de scaling dans le cas o� on
        %fait du simple scaling sur un seule axe
        X1=protocole.SCALING.(nom_courant){1} ;
        X2=protocole.SCALING.(nom_courant){2} ;
        fprintf(fid,'\t\t\t\t\t%s\n','<MarkerPair>');
        fprintf(fid,'\t\t\t\t\t\t%s\n', ['<markers> ',X1,' ',X2,'</markers>']);
        fprintf(fid,'\t\t\t\t\t%s\n','</MarkerPair>');
        if h==4
            %r�cup�ration des noms des marqueurs de scaling dans le cas o� on
            %fait du double scaling sur le m�me �l�ment et le m�me axe
            X3=protocole.SCALING.(nom_courant){3} ;
            X4=protocole.SCALING.(nom_courant){4} ;
            
            fprintf(fid,'\t\t\t\t\t%s\n','<MarkerPair>');
            fprintf(fid,'\t\t\t\t\t\t%s\n', ['<markers> ',X3,' ',X4,'</markers>']);
            fprintf(fid,'\t\t\t\t\t%s\n','</MarkerPair>');
        end
        if ~h==2 && ~h==4
            disp( ['!!!!!!!       probleme de scaling sur ', nom_courant, '  ... le nb de marqueurs est diff�rent de 2 ou 4']);
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

