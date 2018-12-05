function cur_static = define_static_file(cur_path,prot_file,st_protocole)
% Create a unique reference file with all anatomical marqueurs for static
% calibration

static_folder = fullfile(parentfolder(cur_path,1),'Statique');
scaploc_folder = fullfile(parentfolder(cur_path,1),'ScapLoc');
cur_static_r = [];
cur_static_l = [];

%0. Tester si les fichier de reference statique existent
[~,file_l] = PathContent_Type(static_folder,'L_scaploc.c3d');
[~,file_r] = PathContent_Type(static_folder,'R_scaploc.c3d');
[~,file_b] = PathContent_Type(static_folder,'_ref.c3d');

%1. Selectionner les fichiers statique de reference pour les cotes droit et/ou gauche    
if isfield(st_protocole.SEGMENTS,'scapula_locator')% Scaploc calib !!!ameliorer pour les cas où on ne s'interesse pas à la scapula!!!
    is_scapula_locator = 1;%both sides
    if ~isempty(file_r)
        cur_static_r = PathContent_Type(static_folder,'R_scaploc.c3d');
    else
        [~,list_scaploc] = PathContent_Type(scaploc_folder,'.c3d');
        list_scaploc_prop = list_scaploc(find(strncmp(list_scaploc','Prop_R_',7)));
%         [file_static,path_static] = uigetfile([parentfolder(cur_path,1) '/*.c3d'], 'Select a file to define  reference for right side with scaploc');
%         cur_static_r = fullfile(static_folder,file_static);
        if ~isempty(list_scaploc_prop)
            cur_static_r = fullfile(scaploc_folder,list_scaploc_prop(1));       
        else
            is_scapula_locator = 2;%only_left 
        end
    end
    if ~isempty(file_l), 
        cur_static_l = PathContent_Type(static_folder,'L_scaploc.c3d'); 
    else
        [~,list_scaploc] = PathContent_Type(scaploc_folder,'.c3d');
        list_scaploc_prop = list_scaploc(find(strncmp(list_scaploc','Prop_L_',7)));
        if ~isempty(list_scaploc_prop)
            cur_static_l = fullfile(scaploc_folder,list_scaploc_prop(1));   
        else
            is_scapula_locator = 3;%only right
        end
    end
else
    is_scapula_locator = 0;%none
end

%1. Selectionner le fichier statique de reference global    
if  ~isempty(file_b),
    [~,file_static] = PathContent_Type(static_folder,'_ref.c3d');
    cur_static = char(fullfile(static_folder,file_static));
else
    if is_scapula_locator == 0;
        display('no static trial, select manual a ref')
        [file_static,path_static] = uigetfile([parentfolder(cur_path,1) '/*.c3d'], 'Select a file to define static reference');
        cur_static = fullfile(path_static,file_static);
    elseif is_scapula_locator <= 2;
        cur_static = cur_static_l;
    else
        cur_static = cur_static_r;
    end
end

    % preprocessing static files
    preparationDataFRM_static(char(prot_file),char(cur_static),char(cur_static_r),char(cur_static_l),is_scapula_locator)
    cur_static = char(strrep(cur_static,'c3d','trc'));

end %function