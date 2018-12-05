function   [output, VICON]=ecriture_fich_trc_crop_gym(VICON, nom_sortie, path_sortie, crop_inf, crop_sup)
% crop en frame vicon
clear coord_marqueurs
% disp('écriture du fichier trc')

Time=VICON.Time;

if isempty(crop_inf)
    crop_inf=1;
elseif isnan(crop_inf)
    crop_inf=1;
end
if isempty(crop_sup)
    crop_sup=length(Time);
elseif isnan(crop_sup)
    crop_sup=length(Time);
end

nb_phase=length(crop_sup);
for iphase = 1:nb_phase
    
    num_frame=[crop_inf(iphase):1:crop_sup(iphase)]';%vecteur des numéros de frame
    nb_frame=length(num_frame);% nombre total de frames

    structure=VICON.Marqueurs;
    noms_marqueurs=fieldnames(structure);
    nb_marqueurs=length(noms_marqueurs);

    Time=VICON.Time(crop_inf(iphase):crop_sup(iphase));
    if size(Time,1)==1,
        Time=Time';
    end
    
    output=[num_frame Time];
    dataheader1 = 'Frame#\tTime\t';
    dataheader2 = '\t\t';
    % format_text = '%i\t%i\t';
    format_text = '%i\t%2.4f\t';
    change=0;
    for i=1:nb_marqueurs,
        dataheader1 = [dataheader1 noms_marqueurs{i} '\t\t\t'];
        dataheader2 = [dataheader2 'X' num2str(i) '\t' 'Y' num2str(i) '\t'...
            'Z' num2str(i) '\t'];
        %     format_text = [format_text '%i\t%i\t%i\t'];
        format_text = [format_text '%f\t%f\t%f\t'];
        coord_marqueurs=structure.( noms_marqueurs{i} ) ;
        coord_marqueurs=coord_marqueurs(crop_inf(iphase):crop_sup(iphase),:);

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

    mkdir(path_sortie);
    newfilename = strcat(path_sortie,'\',nom_sortie,'.trc');
    fid_1 = fopen(newfilename,'w');

    % écriture de l'en-tête
    fprintf(fid_1,'%s\t%s\t%s\t%s\n', 'PathFileType','4', '(X/Y/Z)', newfilename);
    fprintf(fid_1,'DataRate\tCameraRate\tNumFrames\tNumMarkers\tUnits\tOrigDataRate\tOrigDataStartFrame\tOrigNumFrames\n');
    fprintf(fid_1,'%d\t%d\t%d\t%d\t%s\t%d\t%d\t%d\n', VICON.Info.frequence, VICON.Info.frequence, VICON.Info.NumFrames, nb_marqueurs, VICON.Info.unit, VICON.Info.frequence,'1',VICON.Info.NumFrames);
    fprintf(fid_1, dataheader1);
    fprintf(fid_1, dataheader2);

    % écriture des données des marqueurs
    fprintf(fid_1, format_text, output');

    % close the file
    fclose(fid_1);
end %iphase

end

