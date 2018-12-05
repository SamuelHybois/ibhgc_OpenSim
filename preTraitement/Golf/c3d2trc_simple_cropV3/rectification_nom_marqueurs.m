function [struc_nom_marqueurs] = rectification_nom_marqueurs(struc_nom_marqueurs)

% Règle les problèmes liés à la labélisation erronés des marqueurs des
% ancillaires: il arrive qu'ils s'appellent MTHAD au lieu de MTBHAD etc.
% Signification: Marqueur Technique du Bras, Haut Antérieur Droit

% disp('changement de nom des marqueurs mal labélisés');

if isfield(struc_nom_marqueurs,'MTBAPD') == 1
    newField = 'MTBHPD';
    oldField = 'MTBAPD';
    [struc_nom_marqueurs.(newField)] = struc_nom_marqueurs.(oldField);
    struc_nom_marqueurs = rmfield(struc_nom_marqueurs,oldField);
end

if isfield(struc_nom_marqueurs,'MTHAD') == 1
    newField = 'MTBHAD';
    oldField = 'MTHAD';
    [struc_nom_marqueurs.(newField)] = struc_nom_marqueurs.(oldField);
    struc_nom_marqueurs = rmfield(struc_nom_marqueurs,oldField);
end

if isfield(struc_nom_marqueurs,'MTHPD') == 1
    newField = 'MTBHPD';
    oldField = 'MTHPD';
    [struc_nom_marqueurs.(newField)] = struc_nom_marqueurs.(oldField);
    struc_nom_marqueurs = rmfield(struc_nom_marqueurs,oldField);
end

if isfield(struc_nom_marqueurs,'MTBPD') == 1
    newField = 'MTBBPD';
    oldField = 'MTBPD';
    [struc_nom_marqueurs.(newField)] = struc_nom_marqueurs.(oldField);
    struc_nom_marqueurs = rmfield(struc_nom_marqueurs,oldField);
end

if isfield(struc_nom_marqueurs,'MTBAD') == 1
    newField = 'MTBBAD';
    oldField = 'MTBAD';
    [struc_nom_marqueurs.(newField)] = struc_nom_marqueurs.(oldField);
    struc_nom_marqueurs = rmfield(struc_nom_marqueurs,oldField);
end

if isfield(struc_nom_marqueurs,'MTHAG') == 1
    newField = 'MTBHAG';
    oldField = 'MTHAG';
    [struc_nom_marqueurs.(newField)] = struc_nom_marqueurs.(oldField);
    struc_nom_marqueurs = rmfield(struc_nom_marqueurs,oldField);
end

if isfield(struc_nom_marqueurs,'MTHPG') == 1
    newField = 'MTBHPG';
    oldField = 'MTHPG';
    [struc_nom_marqueurs.(newField)] = struc_nom_marqueurs.(oldField);
    struc_nom_marqueurs = rmfield(struc_nom_marqueurs,oldField);
end

if isfield(struc_nom_marqueurs,'MTBPG') == 1
    newField = 'MTBBPG';
    oldField = 'MTBPG';
    [struc_nom_marqueurs.(newField)] = struc_nom_marqueurs.(oldField);
    struc_nom_marqueurs = rmfield(struc_nom_marqueurs,oldField);
end

if isfield(struc_nom_marqueurs,'MTBAG') == 1
    newField = 'MTBBAG';
    oldField = 'MTBAG';
    [struc_nom_marqueurs.(newField)] = struc_nom_marqueurs.(oldField);
    struc_nom_marqueurs = rmfield(struc_nom_marqueurs,oldField);
end
end