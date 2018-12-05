function[cur_mass] = cur_sujet_mass(structure_excel,st_protocole,cur_sujet)

%Dans le cas du FRM, on a pas l'extension de l'essai dans le nom du sujet
%On a SA09AS_T3S_R1
%On veut juste SA09AS

if ~isfield(structure_excel,cur_sujet)
    cur_sujet_split = strsplit(cur_sujet,'_');
    cur_sujet = cur_sujet_split{1};
end

% On va chercher la masse dans le excel sinon dans le prot.
if isfield(structure_excel.(cur_sujet),'Mass')
    cur_mass = structure_excel.(cur_sujet).Mass{1};
elseif ~isempty(st_protocole.SUJETS.(cur_sujet){1})
    cur_mass = st_protocole.SUJETS.(cur_sujet){1};
end

end