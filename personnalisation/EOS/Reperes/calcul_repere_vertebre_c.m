function M=calcul_repere_vertebre_c(objet)

% Calcule le rep�re d'une vert�bre C.

%% Listes des tags des points du mod�le

% Points plateau sup�rieur
tags.sup={'1','2','3','4','5','6','7','8','9','10','11','12','13','14', ...
          '15','16'};

% Points plateau inf�rieur
tags.inf={'64','65','66','67','68','69','70','71','72','73','74','75', ...
          '76','77','78','79'};

% Points r�gion post�rieure (Marc-Antoine Rousseau)
tags.post={'32','33','34','35','36','37','38','39','40','41','42','43', ...
           '44','45','46','47','48','49','50','51','52','53','54','55', ...
           '56','100','101','102','103','104','105','106','107','108', ...
           '109','110','111','112','113','114','115','116','117','118', ...
           '119','120','121','122','123','124','125','126','146','149', ...
           '150'};

% Points r�gion ant�rieure (Marc-Antoine Rousseau)
tags.ant={'1','2','3','4','5','6','7','8','9','10','11','12','13','14', ...
          '15','16','17','18','19','20','21','22','23','24','25','26', ...
          '27','28','30','31','57','58','59','60','61','62','63','64', ...
          '65','66','67','68','69','70','71','72','73','74','75','76', ...
          '77','78','79','80','81','82','83','84','85','86','87','88', ...
          '89','90','91','92','93','95','96','97','98','99','127','128', ...
          '129','130','131','132','137','138','139','140','141','142', ...
          '143','144','144','145','146','147','148','151','152','153', ...
          '154'};

% Points r�gion gauche (Marc-Antoine Rousseau)
tags.g={'43','44','45','46','47','48','49','50','51','52','53','54','55', ...
        '56','57','58','59','60','64','72','73','74','75','76','77','78', ...
        '79','80','81','82','87','88','89','90','91','93','94','95','96', ...
        '97','98','99','100','101','102','103','104','105','106','107', ...
        '108','109','110','111','112','133','134','135','136','137','138', ...
        '139','149','150','151','152','153','154'};

% Points r�gion droite (Marc-Antoine Rousseau)
tags.d={'31','32','33','34','34','36','37','38','39','40','41','42','43', ...
        '44','45','46','61','62','63','64','65','66','67','68','69','70', ...
        '71','72','82','83','84','85','86','87','91','92','113','114','115', ...
        '116','117','118','119','120','121','122','123','124','125','126', ...
        '127','128','129','130','131','132','135','136','140','141','142', ...
        '143','144','145','146','147','148'};

%% R�cup�re les points correspondant aux tags

% Points sup�rieurs et inf�rieurs
points.sup=objet.coord(matchcell(tags.sup,objet.tag),:);
points.inf=objet.coord(matchcell(tags.inf,objet.tag),:);

% Points ant�rieurs et post�rieurs
points.ant=objet.coord(matchcell(tags.ant,objet.tag),:);
points.post=objet.coord(matchcell(tags.post,objet.tag),:);

% Points gauches et droits
points.d=objet.coord(matchcell(tags.d,objet.tag),:);
points.g=objet.coord(matchcell(tags.g,objet.tag),:);

%% D�termine les points anatomiques

% Centres des plateaux
pt_sup=mean(points.sup);
pt_inf=mean(points.inf);

% Barycentres des zones ant�rieure et post�rieure
pt_ant=mean(points.ant);
pt_post=mean(points.post);

% Barycentres des zones gauche et droite
pt_g=mean(points.g);
pt_d=mean(points.d);

% Plan m�dian passant par les 4 points
[N,P]=plan_moindres_carres([pt_ant;pt_post;pt_g;pt_d]);
if size(N,1)==3
    N=N';
end

% Oriente la normale avec Z vers le haut
N=N*sign(dot(N,[0 0 1]));

%% D�termine la matrice de passage

% Origine
O=(pt_sup+pt_inf)/2;

% Axes du rep�re
Z=N;
X=cross(pt_g-pt_d,Z);
Y=cross(Z,X);

% Normalise les vecteurs
X=X/norm(X);
Y=Y/norm(Y);
Z=Z/norm(Z);

% Construit la matrice
M=[X' Y' Z' O';0 0 0 1];