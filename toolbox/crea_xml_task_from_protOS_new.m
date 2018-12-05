function [ ] = crea_xml_task_from_protOS_new( st_protocole, file_sortie_xmltask, choix )

% Objectif
%   - Création fichier.xml, définissant les poids associés à chq marqueur
%   pour la procédure de cinématique inverse (ou de scaling)
%       A partir d'un protocole décrivant les marqueurs à utiliser pour le
%       modèle
%
% En entrée
%   - prot_file : répertoire + fichier protocole décrivant les marqueurs à
%                       utiliser pour le modèle et les poids associés
%                       (ex: d:\opensimtest\prot\frm.protOS)
%   - file_sortie_xmltask : répertoire et nom du fichier .xml à créer
%                       (ex: d:\opensimtest\iktask\frm_iktask.xml)
%
% En sortie
%   - fichier.xml créé, dont les nom et répertoire sont définis dans "file_sortie_xmltask"



%% xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
%           Début de fonction
% xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

% prot_file = 'H:\01-projets\FRM_propulsion\2015_siegel\__debug\automat_opensim\test\FRM.protOS' ;
% file_sortie_xmltask = 'H:\01-projets\FRM_propulsion\2015_siegel\__debug\automat_opensim\test\testxmltsk.xml' ;

disp(' '); 
disp('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx') ;
disp('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx') ;
disp(' '); disp('          lancement fonction "creation_xmltask_from_protOS" ... ') ;
disp(' '); 
% xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
%           Répertoires et noms de fichiers à créer
% xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
[rep_sortie_fichiers, nom_IK_task_set, ext_tmp] = fileparts( file_sortie_xmltask );

% xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
%           Lecture protocole
% xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

% lecture du protocole
nb_mark=length(fieldnames(st_protocole.POIDS));
% nb_ddl=length(fieldnames(st_protocole.DEGRES_DE_LIBERTE));
% name_ddl=fieldnames(st_protocole.DEGRES_DE_LIBERTE);

% récupération des données de poids associés à chq marqueur
name_mark=fieldnames(st_protocole.POIDS);
% nb_poids=length(noms_poids);
% if nb_poids<nb_marqueurs,
%     disp('il manque des poids pour les marqueurs')
% elseif nb_poids>nb_marqueurs,
%     disp('il y a trop de données de poids pour le nombre de marqueurs')
% end

poids=zeros(nb_mark,1);
% true_ddl=zeros(nb_ddl,1);

switch choix
    case 'scaling_1'%scaling pour fichier .mot de la position ref
        ik_idx = 1;
    case 'scaling_2'%scaling position marqueurs statiques et clusters
        ik_idx = 1;
    case 'ik'
        ik_idx = 2;
end 

for k=1:nb_mark
    hpoids=(strcat('(st_protocole.POIDS.',name_mark{k}));
    hpoids=(strcat(hpoids,sprintf('{%g})',ik_idx)));
    hpoids=eval(hpoids);
    hpoids=str2double(hpoids);
    poids(k,1)=hpoids;
end
% for i=1:nb_ddl
%     hddl=(strcat('(st_protocole.DEGRES_DE_LIBERTE.',name_ddl{i}));
%     hddl=(strcat(hddl,sprintf('{%g})',ik_idx)));
%     hddl=eval(hddl);
%     hddl=str2double(hddl);
%     true_ddl(i,1)=hddl;
% end


% xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
%           Début de création du fichier XML
% xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

% création du répertoire si non existant
mkdir( rep_sortie_fichiers ) ;

% début d'écriture
fid=fopen( file_sortie_xmltask, 'w' );

%% écriture de l'en-tête de scaling
fprintf(fid,'%s\n','<?xml version="1.0" encoding="UTF-8" ?>');
fprintf(fid,'%s\n',['<IKTaskSet name="', nom_IK_task_set, '">']);  % nom du task set
fprintf(fid,'\t%s\n','<objects>');

% xxxxxxxxxxxxxxxxx
%   itération sur les poids de chaque marqueurs
for ipoids=1:nb_mark
    fprintf(fid,'\t\t%s\n',['<IKMarkerTask name="',name_mark{ipoids},'">']);
    % pour le moment on considère que tout est true => à modifier
    fprintf(fid,'\t\t\t%s\n','<apply>true</apply>');
    poids_temps=num2str(poids(ipoids));
    fprintf(fid,'\t\t\t%s\n',['<weight>',poids_temps,'</weight>']);
    fprintf(fid,'\t\t%s\n','</IKMarkerTask>');
end  % ipoids

% %   itération sur les degres de liberte du model
% for iddl=1:nb_ddl
%     if true_ddl(iddl), trueORfalse = 'true'; else trueORfalse = 'false'; end
%     poids_temps=num2str( true_ddl(iddl));
%     fprintf(fid,'\t\t%s\n',['<IKCoordinateTask name="',name_ddl{iddl},'">']);
%     fprintf(fid,'\t\t\t%s\n',['<apply>' trueORfalse '</apply>']);
%     fprintf(fid,'\t\t\t%s\n',['<weight>',poids_temps,'</weight>']);
%     fprintf(fid,'\t\t%s\n','<value_type>from_file</value_type>');
%     fprintf(fid,'\t\t%s\n','<value>0</value>');
%     fprintf(fid,'\t\t%s\n','</IKCoordinateTask>');
% end  % iddl

fprintf(fid,'\t%s\n','</objects>');
fprintf(fid,'\t%s\n','<groups />');
fprintf(fid,'%s\n','</IKTaskSet>');

fclose(fid);

disp([ nom_IK_task_set '.xml has been created']) ;
disp(' '); 
disp(' '); disp('          Fin de fonction "creation_xmltask_from_protOS" ... ') ;
disp(' '); disp('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx') ;
disp('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx') ;

end % function

