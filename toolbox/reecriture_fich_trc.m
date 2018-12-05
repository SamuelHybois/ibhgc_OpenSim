function [output]=reecriture_fich_trc(structure_TRC, nom_sortie, path_sortie)
% même fonction que ecriture_fichier_trc mais à partir d'une structure TRC
% après avoir utiliser la fonction lire_fichier_trc

clear coord_marqueurs
% disp('écriture du fichier trc')
dataheader1 = 'Frame#\tTime\t';
dataheader2 = '\t\t';
% format_text = '%i\t%i\t';
format_text = '%i\t%2.4f\t';
% 
% nb_frame=str2num(structure_TRC.param_acquis.NumFrames  ;% nombre total de frames
% num_frame=[1:nb_frame];%vecteur des numéros de frame

num_frame = structure_TRC.frame

if size(num_frame,1)==1
    num_frame=num_frame';
end

noms_marqueurs = structure_TRC.noms;
nb_marqueurs = str2num(structure_TRC.param_acquis.NumMarkers)  ;

Time= structure_TRC.tps  ;
if size(Time,1)==1,
    Time=Time';
end

output=[num_frame'; Time'];


change=0;
for i=1:nb_marqueurs
    dataheader1 = [dataheader1 noms_marqueurs{i} '\t\t\t'];
    dataheader2 = ...
[dataheader2 'X' num2str(i) '\t' 'Y' num2str(i) '\t' 'Z' num2str(i) '\t'];

    %     format_text = [format_text '%i\t%i\t%i\t'];
    format_text = [format_text '%f\t%f\t%f\t'];
    
    coord_marqueurs= structure_TRC.coord(:,1+(i-1)*3:3+(i-1)*3)   ;
    
    
    %changement des unités
    if strcmp(structure_TRC.param_acquis.Units,'mm')==1,
        change=1;
        coord_marqueurs = coord_marqueurs*(1/1000);
                output=[output; coord_marqueurs'];
        
    elseif strcmp(structure_TRC.param_acquis.Units,'m')==1,
                output=[output; coord_marqueurs'];
    else
        disp('unité des données Vicon sont ni mm ni m')
    end
    
end

if change==1,
    structure_TRC.param_acquis.Units='m';
    %     disp('changement d''unité')
end

dataheader1 = [dataheader1 '\n'];
dataheader2 = [dataheader2 '\n'];
format_text = [format_text '\n'];

mkdir(path_sortie);

newfilename = strcat(path_sortie,'\',nom_sortie,'.trc');
fid_1 = fopen(newfilename,'w+');

% écriture de l'en-tête
fprintf(fid_1,'%s\t%s\t%s\t%s\n', 'PathFileType','4', '(X/Y/Z)', newfilename);
fprintf(fid_1,'DataRate\tCameraRate\tNumFrames\tNumMarkers\tUnits\tOrigDataRate\tOrigDataStartFrame\tOrigNumFrames\n');

fprintf(fid_1,'%d\t%d\t%d\t%d\t%s\t%d\t%d\t%d\n', str2num(structure_TRC.freq),...
 str2num(structure_TRC.freq), str2num(structure_TRC.param_acquis.NumFrames),...
 nb_marqueurs, structure_TRC.param_acquis.Units,...
 str2num(structure_TRC.freq),'1',str2num(structure_TRC.param_acquis.NumFrames));

fprintf(fid_1, dataheader1);
fprintf(fid_1, dataheader2);

% écriture des données des marqueurs
fprintf(fid_1, format_text, output);

% close the file
fclose(fid_1);

end

