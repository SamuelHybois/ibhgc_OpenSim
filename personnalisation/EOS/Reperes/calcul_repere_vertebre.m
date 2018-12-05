function M=calcul_repere_vertebre(objet,type)

% Calcule le rep�re d'une vert�bre

type=regexprep(type,'Vertebre_','');
type=regexprep(type,'\d+','');

switch type
    case 'C'
        M=calcul_repere_vertebre_c(objet);
    case 'T'
        M=calcul_repere_vertebre_tl(objet);
    case 'L'
        M=calcul_repere_vertebre_tl(objet);
    otherwise
        error('Type de vert�bre non reconnu !');
end