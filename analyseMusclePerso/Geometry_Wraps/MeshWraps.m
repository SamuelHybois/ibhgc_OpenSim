function Wraps = ExtractWraps(rep_global,cur_sujet)
% Extract Wraps from OSIM model.
% Mesh ellipsoid to wrap muscle around.

model = load(fullfile(rep_global,cur_sujet,'modele',[cur_sujet '_model_final.mat']));

Wraps = extract_Wraps_ModelOS(model);

end