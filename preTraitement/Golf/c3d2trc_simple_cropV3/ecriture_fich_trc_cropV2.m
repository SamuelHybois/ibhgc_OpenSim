function   [output, VICON]=ecriture_fich_trc_cropV2(VICON,path_sortie, crop_inf, crop_sup)
% crop en frame vicon
clear coord_marqueurs
% disp('écriture du fichier trc')
dataheader1 = 'Frame#\tTime\t';
dataheader2 = '\t\t';
% format_text = '%i\t%i\t';
format_text = '%i\t%2.4f\t';
Time=VICON.Time;

if isnan(crop_inf)==1
    crop_inf=1;
end
if isnan(crop_sup)==1
    crop_sup=length(Time);
end


nb_frame=length(Time);% nombre total de frames
num_frame=[crop_inf:1:crop_sup]';%vecteur des numéros de frame
if size(Time,1)==1,
    Time=Time';
end
if size(num_frame,1)==1,
    num_frame=num_frame';
end
structure=VICON.Marqueurs;
noms_marqueurs=fieldnames(structure);
nb_marqueurs=length(noms_marqueurs);



Time=Time(crop_inf:crop_sup);

output=[num_frame Time];


change=0;
for i=1:nb_marqueurs,
    dataheader1 = [dataheader1 noms_marqueurs{i} '\t\t\t'];
    dataheader2 = [dataheader2 'X' num2str(i) '\t' 'Y' num2str(i) '\t'...
        'Z' num2str(i) '\t'];
    %     format_text = [format_text '%i\t%i\t%i\t'];
    format_text = [format_text '%f\t%f\t%f\t'];
    coord_marqueurs=structure.( noms_marqueurs{i} ) ;
    coord_marqueurs=coord_marqueurs(crop_inf:crop_sup,:);
    
    %changement des unités
    if strcmp(VICON.Info.unit,'mm')==1,
        change=1;
        coord_marqueurs = coord_marqueurs*(1/1000);
        %         output=[output; coord_marqueurs'];
        output=[output coord_marqueurs];
        
    elseif strcmp(VICON.Info.unit,'m')==1,
        %         output=[output; coord_marqueurs'];
        output=[output coord_marqueurs];
    else
        disp('unité des données Vicon sont ni mm ni m')
    end
    
end

if change==1,
    VICON.Info.unit='m';
    %     disp('changement d''unité')
end

dataheader1 = [dataheader1 '\n'];
dataheader2 = [dataheader2 '\n'];
format_text = [format_text '\n'];

% mkdir(path_sortie);
fid_1 = fopen(path_sortie,'w');

% écriture de l'en-tête
fprintf(fid_1,'%s\t%s\t%s\t%s\n', 'PathFileType','4', '(X/Y/Z)', path_sortie);
fprintf(fid_1,'DataRate\tCameraRate\tNumFrames\tNumMarkers\tUnits\tOrigDataRate\tOrigDataStartFrame\tOrigNumFrames\n');
fprintf(fid_1,'%d\t%d\t%d\t%d\t%s\t%d\t%d\t%d\n', VICON.Info.frequence, VICON.Info.frequence, VICON.Info.NumFrames, nb_marqueurs, VICON.Info.unit, VICON.Info.frequence,'1',VICON.Info.NumFrames);
fprintf(fid_1, dataheader1);
fprintf(fid_1, dataheader2);

% écriture des données des marqueurs
fprintf(fid_1, format_text, output');

% close the file
fclose(fid_1);

end

