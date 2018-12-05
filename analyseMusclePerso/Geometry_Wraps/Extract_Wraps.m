function Wraps = Extract_Wraps(rep_global,cur_sujet,struct_OSIM)
% Extract Wraps from OSIM model.
% Mesh ellipsoid to wrap muscle around.
Wraps = extract_Wraps_ModelOS(struct_OSIM);

save(char(fullfile(rep_global,cur_sujet,'modele','Wraps.mat')),'Wraps');
end