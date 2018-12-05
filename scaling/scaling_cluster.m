function file_model_cluster = scaling_cluster(file_model_gen,rep_global,cur_static,cur_sujet)  
% This function aims at defining markers position in all rigid non deformable  
% bodies (clusters and scaploc) before scaling and kinematics


%0) INITIALIZE
%0.1) Definir les path d'entree et de sortie des modeles
file_model_cluster = [cur_sujet,'_model_cluster.osim']; 
path_model_cluster = fullfile(rep_global,cur_sujet,'modele',file_model_cluster);
path_model_gen = fullfile(rep_global,'info_global',file_model_gen);

%0.2) Charger les coordonnées des marqueurs dans le fichier static
data_static_trc = lire_donnees_trc(cur_static);
    
%0.3) Récupérer le texte du fichier de modele
fid = fopen(char(path_model_gen));
text = textscan(fid, '%s', 'Delimiter', '\n', 'CollectOutput', true);
fclose(fid);
nbline = numel(text{1,1});

%1) CALIBRATE
%1.1) Recupérer la liste des segments du modèle
list_seg = '';
% list_seg_parent = '';
% list_seg_loc_in_parent = [];
for iline = 1:nbline
    line = text{1,1}(iline,1);    
    if ~cellfun(@isempty,strfind(line,'<Body name='))
        lim = strfind(line{1,1},'"');
        list_seg = [list_seg; cellstr(line{1,1}(lim(1)+1:lim(2)-1))];
        
%         line_cm = text{1,1}(iline+2,1);
%         coord_cm = NaN(1,3);
%         coord_cm_beg = cell2mat(regexp(line_cm,'\d'));
%         for i_coord_cm = 1:3
%             coord_cm_end_temp = regexp (line_cm{1,1}(coord_cm_beg(i_coord_cm)+1:end),'\D');
%             coord_cm_end = coord_cm_end_temp(1)+coord_cm_beg(i_coord_cm)-1;
%             coord_cm(i_coord_cm) = str2double(line_cm{1,1}(coord_cm_beg(i_coord_cm):coord_cm_end));
%         end
%         list_seg_loc_in_parent = [list_seg_origin; coord_cm];
    end
end

%1.2) Isoler les clusters
list_clust = find(~cellfun(@isempty , strfind(list_seg,'cluster')));

%1.3) Recuperer la liste des marqueurs du cluster le cas echeant
for iseg = list_clust'
    cur_seg = list_seg(iseg);
    list_mark = '';
    num_line_mark_coord = [];
        
    for iline = 1:nbline
        line = text{1,1}(iline,1);    
        if ~cellfun(@isempty,strfind(line,'<Marker name='))
            line_seg = text{1,1}(iline+2,1); 
            if ~cellfun(@isempty,strfind(line_seg,cur_seg))
                lim = strfind(line{1,1},'"');
                list_mark = [list_mark; cellstr(line{1,1}(lim(1)+1:lim(2)-1))];
                num_line_mark_coord = [num_line_mark_coord; iline+4];
            end
        end
    end
            
%1.4) Construire un referentiel local et calculer les coordonnées des
%marqueur dans ce referentiel
    nb_mark = numel(list_mark);
    mark_coord_global = NaN(3,nb_mark);
    for imark = 1:nb_mark
        mark_name = list_mark{imark};
        num_mark = find(~cellfun(@isempty , strfind(data_static_trc.noms,mark_name)));
        mark_coord_global(:,imark) = data_static_trc.coord(1,num_mark*3-2:num_mark*3)';
    end

    As = mark_coord_global(:,1);
    Bs = mark_coord_global(:,2);
    Cs = mark_coord_global(:,end);
    Os = mean(mark_coord_global,2);
    Xs = (Cs-As)./norm(Cs-As);
    Ys = (Bs-As)./norm(Bs-As);
    Zs = cross(Xs,Ys)./norm(cross(Xs,Ys));
    Xs = cross(Ys,Zs);
    global2local = [Xs Ys Zs Os;0 0 0 1];

    mark_coord_local = NaN(3,nb_mark); 
    for imark = 1:nb_mark
        mark_coord_local_temp = global2local\[mark_coord_global(:,imark);1];
        mark_coord_local(:,imark) = mark_coord_local_temp(1:3);
    end
    
%1.5) Replacer les coordonnées locales des marqueurs du cluster dans le
%texte modele opensim    
    for imark = 1:nb_mark
        line_coord = num_line_mark_coord(imark);
        mark_coord =  mark_coord_local(:,imark)';
        text{1,1}(line_coord) = cellstr(sprintf('<location> %g %g %g </location>',mark_coord(1),mark_coord(2),mark_coord(3)));        
    end        
end %iseg

%2) WRITE NEW MODEL: Reecrire le fichier texte du modelde opensim
fid = fopen(char(path_model_cluster), 'w');
for iline = 1:nbline
    fprintf(fid, '%s\n', char(text{1,1}{iline}));
end
fclose(fid);

end % function