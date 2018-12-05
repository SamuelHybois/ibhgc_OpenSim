function   reecriture_fich_ik_mot( FICH, nom_sortie, path_sortie)
%En cours à tester
%Pour le filtrage de la cinématique avant l'étape de dynamique inverse

clear coord_marqueurs



mkdir(path_sortie);
newfilename = strcat(path_sortie,'\',nom_sortie);
fid_1 = fopen(newfilename,'w+');

% écriture de l'en-tête
fprintf(fid_1,'%s\n', 'Coordinates');
fprintf(fid_1,'%s\n', ['version=' FICH.version] );
fprintf(fid_1,'%s\n', ['nRows=' FICH.nRows] );
fprintf(fid_1,'%s\n', ['nColumns=' FICH.nColumns] );
fprintf(fid_1,'%s\n', ['inDegrees=' FICH.inDegrees] );
fprintf(fid_1,'%s\n', '' );
fprintf(fid_1,'%s\n', cell2mat(FICH.Units(1) ));
fprintf(fid_1,'%s\n', cell2mat(FICH.Units(2) ));
fprintf(fid_1,'%s\n', '' );
fprintf(fid_1,'%s\n', 'endheader' );


% écriture marqueurs
dataheader1 = 'time\t';
format_text = '%2.4f\t';

noms_coord=FICH.noms;
nb_coord=length(noms_coord);

Time = FICH.tps;

output=[Time];

for i=1:nb_coord
    dataheader1 = [dataheader1 noms_coord{i} '\t'];
    format_text = [format_text '%f\t'];
    coord=FICH.coord(:,i) ;
    
    output=[output, coord];
    
end


dataheader1 = [dataheader1 '\n'];
format_text = [format_text '\n'];

fprintf(fid_1, dataheader1);

% écriture des données des marqueurs
fprintf(fid_1, format_text, output');

% close the file
fclose(fid_1);

end

