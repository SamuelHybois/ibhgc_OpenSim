function M=calcul_repere_vertebre_tl(objet)

% Calcule le repère d'une vertèbre L. ou T.

%% Listes des tags des points du modèle

% Points plateau supérieur
tags.sup={'platsup1','platsup2','platsup3','platsup4','platsup5', ...
          'platsup6','platsup7','platsup8','platsup9','platsup10', ...
          'platsup11','platsup12'};

% Points plateau inférieur
tags.inf={'platinf1','platinf2','platinf3','platinf4','platinf5', ...
          'platinf6','platinf7','platinf8','platinf9','platinf10', ...
          'platinf11','platinf12'};

% Points côté droit
tags.d={'pediculd1','pediculd2','pediculd3','pediculd4','pediculd5', ...
        'pediculd6','pediculd7','pediculd8','platsup8','platsup9', ...
        'platsup10','platsup11','platsup18','platsup19','platsup20', ...
        'platinf2','platinf3','platinf4','platinf5','platinf6', ...
        'platinf14','platinf15','platinf16','facinfd1','facinfd2', ...
        'facinfd3','facinfd4','facinfd5','facinfd6','facinfd7', ...
        'facinfd8','facinfd9','facsupd1','facsupd3','facsupd5', ...
        'facsupd6','facsupd7','facsupd9','facsupd11','facsupd12', ...
        'facsupd13','facsupd14','facsupd15'};

% Points côté gauche
tags.g={'pediculg5','pediculg4','pediculg3','pediculg2','pediculg1', ...
        'pediculg8','pediculg7','pediculg6','platsup6','platsup5', ...
        'platsup4','platsup3','platsup16','platsup15','platsup14', ...
        'platinf12','platinf11','platinf10','platinf9','platinf8', ...
        'platinf20','platinf19','platinf18','facinfg1','facinfg8', ...
        'facinfg7','facinfg6','facinfg5','facinfg4','facinfg3', ...
        'facinfg2','facinfg9','facsupg1','facsupg9','facsupg7', ...
        'facsupg6','facsupg5','facsupg3','facsupg11','facsupg12', ...
        'facsupg13','facsupg14','facsupg15'};

%% Récupère les points correspondant aux tags

% Points supérieurs et inférieurs
points.sup=objet.coord(matchcell(tags.sup,objet.tag),:);
points.inf=objet.coord(matchcell(tags.inf,objet.tag),:);

% Points gauches et droits
points.d=objet.coord(matchcell(tags.d,objet.tag),:);
points.g=objet.coord(matchcell(tags.g,objet.tag),:);

% Points milieu
points.m=(points.d+points.g)/2;

%% Détermine les points anatomiques

% Centres des plateaux
pt_sup=mean(points.sup);
pt_inf=mean(points.inf);

% Plan sagittal
[N,P]=plan_moindres_carres(points.m);

% Oriente la normale de la droite vers la gauche
N=N*sign(dot(N,points.g(3,:)-points.d(3,:)));

%% Détermine la matrice de passage

% Origine
O=(pt_sup+pt_inf)/2;

% Axes du repère
Z=pt_sup-pt_inf;
X=cross(N,Z);
Y=cross(Z,X);

% Normalise les vecteurs
X=X/norm(X);
Y=Y/norm(Y);
Z=Z/norm(Z);

% Construit la matrice
M=[X' Y' Z' O';0 0 0 1];