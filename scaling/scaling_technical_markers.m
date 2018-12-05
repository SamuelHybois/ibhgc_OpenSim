function file_model_markers = scaling_technical_markers(file_model_gen,rep_global,cur_static,cur_sujet)  
% This function aims at defining markers position in all rigid non deformable  
% bodies (clusters and scaploc) before scaling and kinematics


%0) INITIALIZE
%0.1) Definir les path d'entree et de sortie des modeles
file_model_markers = [cur_sujet,'_model_tech_mark.osim']; 
path_model_markers = fullfile(rep_global,cur_sujet,'modele',file_model_markers);
path_model_gen = fullfile(rep_global,cur_sujet,'modele',file_model_gen);

%0.2) Charger les coordonnées des marqueurs dans le fichier static
data_static_trc = lire_donnees_trc(cur_static);
    
%0.3) Récupérer le texte du fichier de modele
fid = fopen(path_model_gen);
TEXT = textscan(fid, '%s', 'Delimiter', '\n', 'CollectOutput', true);
fclose(fid);
nbline = numel(TEXT{1});
text = TEXT{1};

% %0.4) Charger la structure du modele
% 

%1) CALIBRATE
%1.1) Recupérer la liste des markers ainsi que les autres infos associees
line_mark = find(strncmp('<Marker name=',text,13));
mark_2_move = find(strcmp('<fixed>false</fixed>',text(line_mark+6)));
line_coord = line_mark(mark_2_move)+4;
nb_mark_2_move = length(mark_2_move);

for imark = 1:nb_mark_2_move
    % name of markers to move
    mark = char(text{line_mark(mark_2_move(imark))}(15:end-2));
    % name of associated segment 
    seg = char(text{line_mark(mark_2_move(imark))+2}(7:end-7));
    % coordinates of associated center of mass 
    line_seg = find(strcmp(['<Body name="' seg '">'],text));
    txt_cm = text{line_seg+2}(14:end-14);
    space_idx = regexp(txt_cm,'\s');
    cm = [str2num(txt_cm(1:space_idx(1))), str2num(txt_cm(space_idx(1):space_idx(2))), str2num(txt_cm(space_idx(2):end))];    
%     % List of associated co-markers
%     lines_co_mark = find(strcmp(['<Body>"' seg '"</Body>'],text));
%     nb_co_mark = length(lines_co_mark);
%     list_co_mark = cell(nb_co_mark,1);
%     for icomark = 1:nb_co_mark
%         list_co_mark{icomark} = char(text{line_mark(mark_2_move(imark))}(15:end-2));        
%     end
    
    % static coordinates of marker to move
    num_mark_static = find(strcmp(data_static_trc.noms,mark));
    coord_mark_static = data_static_trc.coord(1,num_mark_static*3-2:num_mark_static*3);
    
    % segment local matrix from static data
    RO_Rseg = segment_matrix_from_trc(data_static_trc,seg);
    RO_Rseg = RO_Rseg(:,:,1); %first frame only
%     RO_Rseg_cm(1:3,4) = RO_Rseg_cm(1:3,4)+cm; %move to com
    
    % local coordinates of marker to move
    coord_mark_local = (RO_Rseg\[coord_mark_static 1]');%-[cm 1]';
    
    % Replacer les coordonnées locales des marqueurs dans le modele opensim    
    text(line_mark(mark_2_move(imark))+4) = cellstr(sprintf('<location> %g %g %g</location>',coord_mark_local(1),coord_mark_local(2),coord_mark_local(3)));        

end %imark_to_move

%2) WRITE NEW MODEL: Reecrire le fichier texte du modelde opensim

fid = fopen(char(path_model_markers), 'w');
for iline = 1:nbline
    fprintf(fid, '%s\n', text{iline});
end
fclose(fid);

end % function