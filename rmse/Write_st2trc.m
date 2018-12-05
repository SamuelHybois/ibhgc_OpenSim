function Write_st2trc(st_trc,chemin_sortie,freq,frame,temps)
%% Objectif
% fonction permettant d'écrire un fichier trc lissbile par OpenSim, à
% partir d'une structure de coordonnées.

%% Hypothèse
% par défaut on considère que les distances sont en mètre



dataheader1 = 'Frame#\tTime\t';
dataheader2 = '\t\t';
format_text = '%i\t%2.4f\t';

nb_frame=length(temps);% nombre total de frames
num_frame=frame;%vecteur des numéros de frame

if size(num_frame,1)==1,
    num_frame=num_frame';
end

noms_marqueurs=fieldnames(st_trc);
nb_marqueurs=length(noms_marqueurs);

Time=temps;
if size(Time,1)==1,
    Time=Time';
end

output=[num_frame'; Time'];


for i=1:nb_marqueurs,
    dataheader1 = [dataheader1 noms_marqueurs{i} '\t\t\t'];
    dataheader2 = [dataheader2 'X' num2str(i) '\t' 'Y' num2str(i) '\t'...
        'Z' num2str(i) '\t'];
    format_text = [format_text '%f\t%f\t%f\t'];
    coord_marqueurs=st_trc.( noms_marqueurs{i} ) ;
    output=[output; coord_marqueurs'];
    
end



dataheader1 = [dataheader1 '\n'];
dataheader2 = [dataheader2 '\n'];
format_text = [format_text '\n'];

newfilename=chemin_sortie;
fid_1 = fopen(newfilename,'w');

% écriture de l'en-tête
fprintf(fid_1,'%s\t%s\t%s\t%s\n', 'PathFileType','4', '(X/Y/Z)', newfilename);
fprintf(fid_1,'DataRate\tCameraRate\tNumFrames\tNumMarkers\tUnits\tOrigDataRate\tOrigDataStartFrame\tOrigNumFrames\n');
fprintf(fid_1,'%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n', num2str(freq), num2str(freq), num2str(nb_frame), num2str(nb_marqueurs), 'm', num2str(freq),'1',num2str(nb_frame));
fprintf(fid_1, dataheader1);
fprintf(fid_1, dataheader2);

% écriture des données des marqueurs
fprintf(fid_1, format_text, output);

% close the file
fclose(fid_1);



end

