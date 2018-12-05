%% DEFINITION
% script permettant de décrire les positions des vertèbres dans deux sets
% de clichés : droit et tourne.

%% ALGO
%%Partie 0 : idées et remarques
% les fichiers vrml brutes ne permettent pas d'obtenir des informations
% pour créer les repères directement. Il est donc pas possible de se baser
% sur ceux tournés pour directement faire des repères et en déduire les
% angles. Ainsi, il est nécessaire de passer par une étape de recalage du
% repère initial dans l'image tournée en partant du principe que les points
% décrivant le vrml sont identiques entre les images droite et tournée
% (mouvement de corps rigide).
% Pour cela, on fait intervenir un repère technique construit à partir de 3
% points quelconques issus des deux fichiers .vrml. On calcule la
% transformation permettant d'aller du repère anatomique au repère
% technique. Cette transformation est la même dans les deux sets de clichés
% donc permet de passer du repère technique au repère anatomique dans le
% set de clichés 'tournés'.
% Les données produites à partir de patients ayant une courbure dans le
% plan frontal par exemple (pouvant être une légère scoliose) rendent le
% dépouillement des données parfois difficile.

%%Partie 1 : chargement des données
% Il est nécessaire d'avoir au préalable : 
%     - les fichiers vrml des éléments à étudier (bassin, L5, L4, L3, L2, 
%       L1, C7) dans les positions droite et tournée. Ceux de la partie
%       droite sont issues de la reconstruction, ceux de la partie tournée
%       sont issues de mouvements de corps rigides à partir des
%       reconstructions.
%     - les fichiers O3 et PN3 de la reconstruction droite
%     - les coordonnées des points permettant de faire le vecteur de la
%     référence de rotation (issus du fichier .o2

%%Partie 2 : création des repères
% pour chaque élément (bassin, vertèbres)
% - importation des fichiers .vrml droits
% - création du repère anatomique
% - création du repère technique
% - importation des fichiers .vrml tournés
% - calcul du repère anatomique à partir du repère technique
% - calcul des angles des éléments dans bassin 
% - calcul des angles des éléments dans L5
% - calcul des angles du baton 

%%Partie 3 : écriture dans un fichier de : 
% - les angles du baton dans le plan XY du bassin/L5
% - les 3 angles avec les 6 séquences pour chaque vertèbre droite, dans le
% repère bassin
% - les 3 angles avec les 6 séquences pour chaque vertèbre droite, dans le
% repère L5

%% Partie 1
nom_sujet='ReBe_M_1968';
% nom_sujet='DuAd_M_1987';
% nom_sujet='JeMa_M_1992';
affichage=0;
% element_reference='L5';
element_reference='bassin';
% repertoire_sortie='E:\essais_angle_test_or';
repertoire_sortie='E\data_cafe_scientifique';
fichier_sortie=[repertoire_sortie '\angles_' nom_sujet]; 
fichier_o3=strcat(nom_sujet,'.o3');

qui_fait_la_manip='kev';
switch nom_sujet
    case 'ReBe_M_1968'

%         rep_droit='H:\sauvegarde_ddr\Cours_these\Recherche\DATA\EOS\ReBe_M_1968\reconstruction_6\droit';
        rep_droit='H:\sauvegarde_ddr\Cours_these\Recherche\DATA\test_kevin\droit';
%         rep_tourne='H:\sauvegarde_ddr\Cours_these\Recherche\DATA\EOS\ReBe_M_1968\reconstruction_6\tourne';
%          rep_droit='H:\sauvegarde_ddr\Cours_these\Recherche\DATA\test_or\droit';
%         rep_tourne='H:\sauvegarde_ddr\Cours_these\Recherche\DATA\test_or\tourne';
        rep_tourne='H:\sauvegarde_ddr\Cours_these\Recherche\DATA\test_kevin\tourne';
        % points du bassin servant à créer un repère, ils viennent du
        % fichier .N3
        CPS=[-32.413914  22.030329 1388.588101];
        C_D=[-15.538472 -72.897621 1289.764594];
        C_G=[-20.961482 105.219761 1293.208364];
        
        barre_2_tourne=[180.8111 -5.2548 1941.8898];
        barre_3_tourne=[-78.3282 -179.1345 1927.3973];
     
    case 'DuAd_M_1987'
        rep_droit='H:\sauvegarde_ddr\Cours_these\Recherche\DATA\EOS\DuAd_M_1987\reconstructions\droite_2';
        rep_tourne='H:\sauvegarde_ddr\Cours_these\Recherche\DATA\EOS\DuAd_M_1987\reconstructions\tourne_2';
        
        % points du bassin servant à créer un repère, ils viennent du
        % fichier .N3
        CPS=[-47.716855  -6.901144 1232.712427];
        C_D=[-24.001097 -75.138176 1139.165228];
        C_G=[-5.732514  73.698322 1148.635594];
         
        barre_2_tourne=[56.3304 -90.0588 1735.3060];
        barre_3_tourne=[-50.7100 -124.3286 1730.6785];       
        
    case 'JeMa_M_1992'
        rep_droit='H:\sauvegarde_ddr\Cours_these\Recherche\DATA\EOS\2015_08_26-donnees_EOS\reconstructions\colonne_droite';
        rep_tourne='H:\sauvegarde_ddr\Cours_these\Recherche\DATA\EOS\2015_08_26-donnees_EOS\reconstructions\colonne_tournee';
        
        % points du bassin servant à créer un repère, ils viennent du
        % fichier .N3
        CPS=[-40.490978 -12.492989 1330.430132];
        C_D=[-32.420486 -97.105123 1222.169048];
        C_G=[-0.180215  64.408243 1223.639825];
        
        barre_1_tourne=[19.7979 -87.2313 1939.9886];
        barre_2_tourne=[77.2119 -177.2062 1928.0408];
        barre_3_tourne=[190.1581 -5.1570 1941.6245];
        
end

%% Partie 2
%%creation du repère bassin droit

Y=C_G-C_D;
Y=Y/norm(Y);
X=cross(C_D-CPS,C_G-CPS);
X=X/norm(X);
Z=cross(X,Y);
centre=(CPS+C_D+C_G)*1/3;
M_droit_bassin=[X' Y' Z'];

%%récupération du WRL bassin droit
rep_bassin_droit=strcat(rep_droit,'\Bassin.wrl');
movie_droit_bassin=lire_fichier_wrml(rep_bassin_droit);
Noeuds_droit_bassin=movie_droit_bassin.Noeuds;
% INFO  : size(Noeuds_droit)=15492,3
% création du repère technique du bassin droit
P1_droit_bassin=Noeuds_droit_bassin(1,:);
P2_droit_bassin=Noeuds_droit_bassin(700,:);
P3_droit_bassin=Noeuds_droit_bassin(1200,:);
M_movie_droit_bassin=repere_3pts(P1_droit_bassin,P2_droit_bassin,P3_droit_bassin);
M_tech_anat_bassin=M_movie_droit_bassin'*M_droit_bassin;

%%récupération du WRL bassin tourne
rep_bassin_tourne=strcat(rep_tourne,'\Bassin.wrl');
movie_tourne=lire_fichier_wrml(rep_bassin_tourne);
Noeuds_tourne_bassin=movie_tourne.Noeuds;
% INFO  : size(Noeuds_tourne)=15492,3
% création du repère technique du bassin tourne
P1_tourne_bassin=Noeuds_tourne_bassin(1,:);
P2_tourne_bassin=Noeuds_tourne_bassin(700,:);
P3_tourne_bassin=Noeuds_tourne_bassin(1200,:);
M_movie_tourne_bassin=repere_3pts(P1_tourne_bassin,P2_tourne_bassin,P3_tourne_bassin);
M_bassin_tourne_anat=M_movie_tourne_bassin*M_tech_anat_bassin;

extraction_angles_matrice_multiple_seq(M_bassin_tourne_anat);

%%creation du repère vertebre L1
cd(rep_droit)
o3_sujet=lire_fichier_o3(fichier_o3, {'Vertebre_L1'});
MH_droit_L1=calcul_repere_vertebre_tl(o3_sujet);
M_droit_L1=MH_droit_L1(1:3,1:3);

%%récupération des wrl
rep_L1_droit=strcat(rep_droit,'\Vertebre_L1.wrl');
movie_droit_L1=lire_fichier_wrml(rep_L1_droit);
Noeuds_droit_L1=movie_droit_L1.Noeuds;
% INFO : size(Noeuds_droit_L1)=2176,3
P1_droit_L1=Noeuds_droit_L1(1,:);
P2_droit_L1=Noeuds_droit_L1(1000,:);
P3_droit_L1=Noeuds_droit_L1(1500,:);
M_movie_droit_L1=repere_3pts(P1_droit_L1,P2_droit_L1,P3_droit_L1);
M_tech_anat_L1=M_movie_droit_L1'*M_droit_L1;

rep_L1_tourne=strcat(rep_tourne,'\Vertebre_L1.wrl');
movie_tourne_L1=lire_fichier_wrml(rep_L1_tourne);
Noeuds_tourne_L1=movie_tourne_L1.Noeuds;
% INFO : size(Noeuds_tourne_L1)=2176,3
P1_tourne_L1=Noeuds_tourne_L1(1,:);
P2_tourne_L1=Noeuds_tourne_L1(1000,:);
P3_tourne_L1=Noeuds_tourne_L1(1500,:);
M_movie_tourne_L1=repere_3pts(P1_tourne_L1,P2_tourne_L1,P3_tourne_L1);
M_anat_tourne_L1=M_movie_tourne_L1*M_tech_anat_L1;

M_bassin_L1_tourne=M_bassin_tourne_anat'*M_anat_tourne_L1;
angles_bassin_L1_tourne=extraction_angles_matrice_multiple_seq(M_bassin_L1_tourne);

M_bassin_L1_droit=M_droit_bassin'*M_droit_L1;
angles_bassin_L1_droit=extraction_angles_matrice_multiple_seq(M_bassin_L1_droit);


%% creation du repère vertebre L2
cd(rep_droit)
o3_sujet=lire_fichier_o3(fichier_o3, {'Vertebre_L2'});
MH_droit_L2=calcul_repere_vertebre_tl(o3_sujet);
M_droit_L2=MH_droit_L2(1:3,1:3);

%% récupération des wrl
rep_L2_droit=strcat(rep_droit,'\Vertebre_L2.wrl');
movie_droit_L2=lire_fichier_wrml(rep_L2_droit);
Noeuds_droit_L2=movie_droit_L2.Noeuds;
% INFO : size(Noeuds_droit_L2)=2176,3
P1_droit_L2=Noeuds_droit_L2(1,:);
P2_droit_L2=Noeuds_droit_L2(1000,:);
P3_droit_L2=Noeuds_droit_L2(1500,:);
M_movie_droit_L2=repere_3pts(P1_droit_L2,P2_droit_L2,P3_droit_L2);
M_tech_anat_L2=M_movie_droit_L2'*M_droit_L2;

rep_L2_tourne=strcat(rep_tourne,'\Vertebre_L2.wrl');
movie_tourne_L2=lire_fichier_wrml(rep_L2_tourne);
Noeuds_tourne_L2=movie_tourne_L2.Noeuds;
% INFO : size(Noeuds_tourne_L2)=2176,3
P1_tourne_L2=Noeuds_tourne_L2(1,:);
P2_tourne_L2=Noeuds_tourne_L2(1000,:);
P3_tourne_L2=Noeuds_tourne_L2(1500,:);
M_movie_tourne_L2=repere_3pts(P1_tourne_L2,P2_tourne_L2,P3_tourne_L2);
M_anat_tourne_L2=M_movie_tourne_L2*M_tech_anat_L2;

M_bassin_L2_tourne=M_bassin_tourne_anat'*M_anat_tourne_L2;
angles_bassin_L2_tourne=extraction_angles_matrice_multiple_seq(M_bassin_L2_tourne);

M_bassin_L2_droit=M_droit_bassin'*M_droit_L2;
angles_bassin_L2_droit=extraction_angles_matrice_multiple_seq(M_bassin_L2_droit);

%% creation du repère vertebre L3
cd(rep_droit)
o3_sujet=lire_fichier_o3(fichier_o3, {'Vertebre_L3'});
MH_droit_L3=calcul_repere_vertebre_tl(o3_sujet);
M_droit_L3=MH_droit_L3(1:3,1:3);

%% récupération des wrl
rep_L3_droit=strcat(rep_droit,'\Vertebre_L3.wrl');
movie_droit_L3=lire_fichier_wrml(rep_L3_droit);
Noeuds_droit_L3=movie_droit_L3.Noeuds;
% INFO : size(Noeuds_droit_L3)=2176,3
P1_droit_L3=Noeuds_droit_L3(1,:);
P2_droit_L3=Noeuds_droit_L3(1000,:);
P3_droit_L3=Noeuds_droit_L3(1500,:);
M_movie_droit_L3=repere_3pts(P1_droit_L3,P2_droit_L3,P3_droit_L3);
M_tech_anat_L3=M_movie_droit_L3'*M_droit_L3;

rep_L3_tourne=strcat(rep_tourne,'\Vertebre_L3.wrl');
movie_tourne_L3=lire_fichier_wrml(rep_L3_tourne);
Noeuds_tourne_L3=movie_tourne_L3.Noeuds;
% INFO : size(Noeuds_tourne_L3)=2176,3
P1_tourne_L3=Noeuds_tourne_L3(1,:);
P2_tourne_L3=Noeuds_tourne_L3(1000,:);
P3_tourne_L3=Noeuds_tourne_L3(1500,:);
M_movie_tourne_L3=repere_3pts(P1_tourne_L3,P2_tourne_L3,P3_tourne_L3);
M_anat_tourne_L3=M_movie_tourne_L3*M_tech_anat_L3;

M_bassin_L3_tourne=M_bassin_tourne_anat'*M_anat_tourne_L3;
angles_bassin_L3_tourne=extraction_angles_matrice_multiple_seq(M_bassin_L3_tourne);

M_bassin_L3_droit=M_droit_bassin'*M_droit_L3;
angles_bassin_L3_droit=extraction_angles_matrice_multiple_seq(M_bassin_L3_droit);

%% creation du repère vertebre L4
cd(rep_droit)
o3_sujet=lire_fichier_o3(fichier_o3, {'Vertebre_L4'});
MH_droit_L4=calcul_repere_vertebre_tl(o3_sujet);
M_droit_L4=MH_droit_L4(1:3,1:3);

%% récupération des wrl
rep_L4_droit=strcat(rep_droit,'\Vertebre_L4.wrl');
movie_droit_L4=lire_fichier_wrml(rep_L4_droit);
Noeuds_droit_L4=movie_droit_L4.Noeuds;
% INFO : size(Noeuds_droit_L4)=2176,3
P1_droit_L4=Noeuds_droit_L4(1,:);
P2_droit_L4=Noeuds_droit_L4(1000,:);
P3_droit_L4=Noeuds_droit_L4(1500,:);
M_movie_droit_L4=repere_3pts(P1_droit_L4,P2_droit_L4,P3_droit_L4);
M_tech_anat_L4=M_movie_droit_L4'*M_droit_L4;

rep_L4_tourne=strcat(rep_tourne,'\Vertebre_L4.wrl');
movie_tourne_L4=lire_fichier_wrml(rep_L4_tourne);
Noeuds_tourne_L4=movie_tourne_L4.Noeuds;
% INFO : size(Noeuds_tourne_L4)=2176,3
P1_tourne_L4=Noeuds_tourne_L4(1,:);
P2_tourne_L4=Noeuds_tourne_L4(1000,:);
P3_tourne_L4=Noeuds_tourne_L4(1500,:);
M_movie_tourne_L4=repere_3pts(P1_tourne_L4,P2_tourne_L4,P3_tourne_L4);
M_anat_tourne_L4=M_movie_tourne_L4*M_tech_anat_L4;

M_bassin_L4_tourne=M_bassin_tourne_anat'*M_anat_tourne_L4;
angles_bassin_L4_tourne=extraction_angles_matrice_multiple_seq(M_bassin_L4_tourne);

M_bassin_L4_droit=M_droit_bassin'*M_droit_L4;
angles_bassin_L4_droit=extraction_angles_matrice_multiple_seq(M_bassin_L4_droit);

%% creation du repère vertebre L5
cd(rep_droit)
o3_sujet=lire_fichier_o3(fichier_o3, {'Vertebre_L5'});
MH_droit_L5=calcul_repere_vertebre_tl(o3_sujet);
M_droit_L5=MH_droit_L5(1:3,1:3);

%% récupération des wrl
rep_L5_droit=strcat(rep_droit,'\Vertebre_L5.wrl');
movie_droit_L5=lire_fichier_wrml(rep_L5_droit);
Noeuds_droit_L5=movie_droit_L5.Noeuds;
% INFO : size(Noeuds_droit_L5)=2176,3
P1_droit_L5=Noeuds_droit_L5(1,:);
P2_droit_L5=Noeuds_droit_L5(1000,:);
P3_droit_L5=Noeuds_droit_L5(1500,:);
M_movie_droit_L5=repere_3pts(P1_droit_L5,P2_droit_L5,P3_droit_L5);
M_tech_anat_L5=M_movie_droit_L5'*M_droit_L5;

rep_L5_tourne=strcat(rep_tourne,'\Vertebre_L5.wrl');
movie_tourne_L5=lire_fichier_wrml(rep_L5_tourne);
Noeuds_tourne_L5=movie_tourne_L5.Noeuds;
% INFO : size(Noeuds_tourne_L5)=2176,3
P1_tourne_L5=Noeuds_tourne_L5(1,:);
P2_tourne_L5=Noeuds_tourne_L5(1000,:);
P3_tourne_L5=Noeuds_tourne_L5(1500,:);
M_movie_tourne_L5=repere_3pts(P1_tourne_L5,P2_tourne_L5,P3_tourne_L5);
M_anat_tourne_L5=M_movie_tourne_L5*M_tech_anat_L5;

M_bassin_L5_tourne=M_bassin_tourne_anat'*M_anat_tourne_L5;
angles_bassin_L5_tourne=extraction_angles_matrice_multiple_seq(M_bassin_L5_tourne);

M_bassin_L5_droit=M_droit_bassin'*M_droit_L5;
angles_bassin_L5_droit=extraction_angles_matrice_multiple_seq(M_bassin_L5_droit);

% % % angles_L5=angles_bassin_L5_tourne-angles_bassin_L5_droit

%% creation du repère vertebre C7
cd(rep_droit)
o3_sujet=lire_fichier_o3(fichier_o3, {'Vertebre_C7'});
MH_droit_C7=calcul_repere_vertebre_c(o3_sujet);
M_droit_C7=MH_droit_C7(1:3,1:3);

%% récupération des wrl de C7
rep_C7_droit=strcat(rep_droit,'\Vertebre_C7.wrl');
movie_droit_C7=lire_fichier_wrml(rep_C7_droit);
Noeuds_droit_C7=movie_droit_C7.Noeuds;
% INFO : size(Noeuds_droit_C7)=2176,3
P1_droit_C7=Noeuds_droit_C7(1,:);
P2_droit_C7=Noeuds_droit_C7(1000,:);
P3_droit_C7=Noeuds_droit_C7(1500,:);
M_movie_droit_C7=repere_3pts(P1_droit_C7,P2_droit_C7,P3_droit_C7);
M_tech_anat_C7=M_movie_droit_C7'*M_droit_C7;

rep_C7_tourne=strcat(rep_tourne,'\Vertebre_C7.wrl');
movie_tourne_C7=lire_fichier_wrml(rep_C7_tourne);
Noeuds_tourne_C7=movie_tourne_C7.Noeuds;
% INFO : size(Noeuds_tourne_C7)=2176,3
P1_tourne_C7=Noeuds_tourne_C7(1,:);
P2_tourne_C7=Noeuds_tourne_C7(1000,:);
P3_tourne_C7=Noeuds_tourne_C7(1500,:);
M_movie_tourne_C7=repere_3pts(P1_tourne_C7,P2_tourne_C7,P3_tourne_C7);
M_anat_tourne_C7=M_movie_tourne_C7*M_tech_anat_C7;

M_bassin_C7_tourne=M_bassin_tourne_anat'*M_anat_tourne_C7;
angles_bassin_C7_tourne=extraction_angles_matrice_multiple_seq(M_bassin_C7_tourne);

M_bassin_C7_droit=M_droit_bassin'*M_droit_C7;
angles_bassin_C7_droit=extraction_angles_matrice_multiple_seq(M_bassin_C7_droit);

%% dans repère L5
M_L5_C7_tourne=M_anat_tourne_L5'*M_anat_tourne_C7;
angles_L5_C7_tourne=extraction_angles_matrice_multiple_seq(M_L5_C7_tourne);

M_L5_C7_droit=M_droit_L5'*M_droit_C7;
angles_L5_C7_droit=extraction_angles_matrice_multiple_seq(M_L5_C7_droit);

M_L5_L1_tourne=M_anat_tourne_L5'*M_anat_tourne_L1;
angles_L5_L1_tourne=extraction_angles_matrice_multiple_seq(M_L5_L1_tourne);

M_L5_L1_droit=M_droit_L5'*M_droit_L1;
angles_L5_L1_droit=extraction_angles_matrice_multiple_seq(M_L5_L1_droit);

M_L5_L2_tourne=M_anat_tourne_L5'*M_anat_tourne_L2;
angles_L5_L2_tourne=extraction_angles_matrice_multiple_seq(M_L5_L2_tourne);

M_L5_L2_droit=M_droit_L5'*M_droit_L2;
angles_L5_L2_droit=extraction_angles_matrice_multiple_seq(M_L5_L2_droit);

M_L5_L3_tourne=M_anat_tourne_L5'*M_anat_tourne_L3;
angles_L5_L3_tourne=extraction_angles_matrice_multiple_seq(M_L5_L3_tourne);

M_L5_L3_droit=M_droit_L5'*M_droit_L3;
angles_L5_L3_droit=extraction_angles_matrice_multiple_seq(M_L5_L3_droit);

M_L5_L4_tourne=M_anat_tourne_L5'*M_anat_tourne_L4;
angles_L5_L4_tourne=extraction_angles_matrice_multiple_seq(M_L5_L4_tourne);

M_L5_L4_droit=M_droit_L5'*M_droit_L4;
angles_L5_L4_droit=extraction_angles_matrice_multiple_seq(M_L5_L4_droit);

%% angle de la barre
vecteur_barre_tourne=barre_2_tourne-barre_3_tourne;
%%repere L5
vecteur_tourne_barre_L5=M_anat_tourne_L5'*vecteur_barre_tourne';
vecteur_tourne_barre_L5=vecteur_tourne_barre_L5/(vecteur_tourne_barre_L5(1)^2+...
    vecteur_tourne_barre_L5(2)^2)^0.5;
angle1_L5=-acosd(vecteur_tourne_barre_L5(1));
angle2_L5=-asind(vecteur_tourne_barre_L5(2));
angle3_L5=-acosd(vecteur_tourne_barre_L5(2));
angle4_L5=-asind(vecteur_tourne_barre_L5(1));
angle_moy_L5=0.25*(angle1_L5+angle2_L5+angle3_L5+angle4_L5);

angle_test_L5=angles_L5_C7_tourne(6,3)/angle_moy_L5;
if angle_test_L5 <= 0
    disp('vérfier le signe de angle baton')
end


%%repere bassin
vecteur_tourne_barre_bassin=M_bassin_tourne_anat'*vecteur_barre_tourne';
vecteur_tourne_barre_bassin=vecteur_tourne_barre_bassin/(vecteur_tourne_barre_bassin(1)^2+...
    vecteur_tourne_barre_bassin(2)^2)^0.5;
angle1_bassin=-acosd(vecteur_tourne_barre_bassin(1));
angle2_bassin=-asind(vecteur_tourne_barre_bassin(2));
angle3_bassin=-acosd(vecteur_tourne_barre_bassin(2));
angle4_bassin=-asind(vecteur_tourne_barre_bassin(1));
angle_moy_bassin=0.25*(angle1_bassin+angle2_bassin+angle3_bassin+angle4_bassin);

angle_test_bassin=angles_bassin_C7_tourne(6,3)/angle_moy_bassin;
if angle_test_bassin <= 0
    disp('vérfier le signe de angle baton')
end

% disp('angles_bassin_C7_tourne'); angles_bassin_C7_tourne(6,:)
% disp('angles_bassin_C7_droit'); angles_bassin_C7_droit(6,:)
% 
% disp('angles_bassin_L1_tourne'); angles_bassin_L1_tourne(6,:)
% disp('angles_bassin_L1_droit'); angles_bassin_L1_droit(6,:)
% 
% disp('angles_bassin_L2_tourne'); angles_bassin_L2_tourne(6,:)
% disp('angles_bassin_L2_droit'); angles_bassin_L2_droit(6,:)
% 
% disp('angles_bassin_L3_tourne'); angles_bassin_L3_tourne(6,:)
% disp('angles_bassin_L3_droit'); angles_bassin_L3_droit(6,:)
% 
% disp('angles_bassin_L4_tourne'); angles_bassin_L4_tourne(6,:)
% disp('angles_bassin_L4_droit'); angles_bassin_L4_droit(6,:)
% 
% disp('angles_bassin_L5_tourne'); angles_bassin_L5_tourne(6,:)
% disp('angles_bassin_L5_droit'); angles_bassin_L5_droit(6,:)


%% ECRITURE FICHIER SORTIE
%%dans le repère bassin
cd(repertoire_sortie)
fichier_sortie_bassin=[ fichier_sortie qui_fait_la_manip '_bassin.txt'];
fid=fopen(fichier_sortie_bassin, 'w');
fprintf(fid, '%s\n', 'angles dans le repère bassin');

fprintf(fid, '%s\n', 'approximation de la répartition de la rotation');
angle_lombaire_approx_bassin=angles_bassin_L1_tourne(6,3)-angles_bassin_L1_droit(6,3);
angle_total_approx_bassin=0.25*(angle1_bassin+angle1_bassin+angle3_bassin+angle4_bassin);
angle_thoracique_approx_bassin=angles_bassin_C7_tourne(6,3)-angles_bassin_C7_droit(6,3)-...
    angle_lombaire_approx_bassin;
angle_epaule_approx_bassin=angle_total_approx_bassin-angle_thoracique_approx_bassin-angle_lombaire_approx_bassin;


fprintf(fid, '%s\t%s\t%s\n', 'type angle', 'degrés', 'pourcentage');
fprintf(fid, '%s\t%6.2f%s\t%6.2f%s\n', 'lombaires', angle_lombaire_approx_bassin, 'deg',(angle_lombaire_approx_bassin/angle_total_approx_bassin*100), '%');
fprintf(fid, '%s\t%6.2f%s\t%6.2f%s\n', 'thoraciques', angle_thoracique_approx_bassin, 'deg',(angle_thoracique_approx_bassin/angle_total_approx_bassin*100), '%');
fprintf(fid, '%s\t%6.2f%s\t%6.2f%s\n', 'épaule', angle_epaule_approx_bassin, 'deg',(angle_epaule_approx_bassin/angle_total_approx_bassin*100), '%');


fprintf(fid, '%s\t%s\t%s\t%s\t%s\t%s\n', 'droit_X', 'droit_Y', 'droit_Z', 'tourne_X', 'tourne_Y', 'tourne_Z');
fprintf(fid, '\n%s\n', 'angle_barre_degré');
fprintf(fid, '%6.2f\t', angle1_bassin);
fprintf(fid, '%6.2f\t', angle2_bassin);
fprintf(fid, '%6.2f\t', angle3_bassin);
fprintf(fid, '%6.2f\t\n', angle4_bassin);


fprintf(fid, '\n%s\n', 'L5');
fprintf(fid, '%6.2f\t', angles_bassin_L5_droit(1,1));
fprintf(fid, '%6.2f\t', angles_bassin_L5_droit(1,2));
fprintf(fid, '%6.2f\t', angles_bassin_L5_droit(1,3));
fprintf(fid, '%6.2f\t', angles_bassin_L5_tourne(1,1));
fprintf(fid, '%6.2f\t', angles_bassin_L5_tourne(1,2));
fprintf(fid, '%6.2f\n', angles_bassin_L5_tourne(1,3));

fprintf(fid, '%6.2f\t', angles_bassin_L5_droit(2,1));
fprintf(fid, '%6.2f\t', angles_bassin_L5_droit(2,2));
fprintf(fid, '%6.2f\t', angles_bassin_L5_droit(2,3));
fprintf(fid, '%6.2f\t', angles_bassin_L5_tourne(2,1));
fprintf(fid, '%6.2f\t', angles_bassin_L5_tourne(2,2));
fprintf(fid, '%6.2f\n', angles_bassin_L5_tourne(2,3));

fprintf(fid, '%6.2f\t', angles_bassin_L5_droit(3,1));
fprintf(fid, '%6.2f\t', angles_bassin_L5_droit(3,2));
fprintf(fid, '%6.2f\t', angles_bassin_L5_droit(3,3));
fprintf(fid, '%6.2f\t', angles_bassin_L5_tourne(3,1));
fprintf(fid, '%6.2f\t', angles_bassin_L5_tourne(3,2));
fprintf(fid, '%6.2f\n', angles_bassin_L5_tourne(3,3));

fprintf(fid, '%6.2f\t', angles_bassin_L5_droit(4,1));
fprintf(fid, '%6.2f\t', angles_bassin_L5_droit(4,2));
fprintf(fid, '%6.2f\t', angles_bassin_L5_droit(4,3));
fprintf(fid, '%6.2f\t', angles_bassin_L5_tourne(4,1));
fprintf(fid, '%6.2f\t', angles_bassin_L5_tourne(4,2));
fprintf(fid, '%6.2f\n', angles_bassin_L5_tourne(4,3));

fprintf(fid, '%6.2f\t', angles_bassin_L5_droit(5,1));
fprintf(fid, '%6.2f\t', angles_bassin_L5_droit(5,2));
fprintf(fid, '%6.2f\t', angles_bassin_L5_droit(5,3));
fprintf(fid, '%6.2f\t', angles_bassin_L5_tourne(5,1));
fprintf(fid, '%6.2f\t', angles_bassin_L5_tourne(5,2));
fprintf(fid, '%6.2f\n', angles_bassin_L5_tourne(5,3));

fprintf(fid, '%6.2f\t', angles_bassin_L5_droit(6,1));
fprintf(fid, '%6.2f\t', angles_bassin_L5_droit(6,2));
fprintf(fid, '%6.2f\t', angles_bassin_L5_droit(6,3));
fprintf(fid, '%6.2f\t', angles_bassin_L5_tourne(6,1));
fprintf(fid, '%6.2f\t', angles_bassin_L5_tourne(6,2));
fprintf(fid, '%6.2f\n', angles_bassin_L5_tourne(6,3));

fprintf(fid, '\n%s\n', 'L4');
fprintf(fid, '%6.2f\t', angles_bassin_L4_droit(1,1));
fprintf(fid, '%6.2f\t', angles_bassin_L4_droit(1,2));
fprintf(fid, '%6.2f\t', angles_bassin_L4_droit(1,3));
fprintf(fid, '%6.2f\t', angles_bassin_L4_tourne(1,1));
fprintf(fid, '%6.2f\t', angles_bassin_L4_tourne(1,2));
fprintf(fid, '%6.2f\n', angles_bassin_L4_tourne(1,3));

fprintf(fid, '%6.2f\t', angles_bassin_L4_droit(2,1));
fprintf(fid, '%6.2f\t', angles_bassin_L4_droit(2,2));
fprintf(fid, '%6.2f\t', angles_bassin_L4_droit(2,3));
fprintf(fid, '%6.2f\t', angles_bassin_L4_tourne(2,1));
fprintf(fid, '%6.2f\t', angles_bassin_L4_tourne(2,2));
fprintf(fid, '%6.2f\n', angles_bassin_L4_tourne(2,3));

fprintf(fid, '%6.2f\t', angles_bassin_L4_droit(3,1));
fprintf(fid, '%6.2f\t', angles_bassin_L4_droit(3,2));
fprintf(fid, '%6.2f\t', angles_bassin_L4_droit(3,3));
fprintf(fid, '%6.2f\t', angles_bassin_L4_tourne(3,1));
fprintf(fid, '%6.2f\t', angles_bassin_L4_tourne(3,2));
fprintf(fid, '%6.2f\n', angles_bassin_L4_tourne(3,3));

fprintf(fid, '%6.2f\t', angles_bassin_L4_droit(4,1));
fprintf(fid, '%6.2f\t', angles_bassin_L4_droit(4,2));
fprintf(fid, '%6.2f\t', angles_bassin_L4_droit(4,3));
fprintf(fid, '%6.2f\t', angles_bassin_L4_tourne(4,1));
fprintf(fid, '%6.2f\t', angles_bassin_L4_tourne(4,2));
fprintf(fid, '%6.2f\n', angles_bassin_L4_tourne(4,3));

fprintf(fid, '%6.2f\t', angles_bassin_L4_droit(5,1));
fprintf(fid, '%6.2f\t', angles_bassin_L4_droit(5,2));
fprintf(fid, '%6.2f\t', angles_bassin_L4_droit(5,3));
fprintf(fid, '%6.2f\t', angles_bassin_L4_tourne(5,1));
fprintf(fid, '%6.2f\t', angles_bassin_L4_tourne(5,2));
fprintf(fid, '%6.2f\n', angles_bassin_L4_tourne(5,3));

fprintf(fid, '%6.2f\t', angles_bassin_L4_droit(6,1));
fprintf(fid, '%6.2f\t', angles_bassin_L4_droit(6,2));
fprintf(fid, '%6.2f\t', angles_bassin_L4_droit(6,3));
fprintf(fid, '%6.2f\t', angles_bassin_L4_tourne(6,1));
fprintf(fid, '%6.2f\t', angles_bassin_L4_tourne(6,2));
fprintf(fid, '%6.2f\n', angles_bassin_L4_tourne(6,3));

fprintf(fid, '\n%s\n', 'L3');
fprintf(fid, '%6.2f\t', angles_bassin_L3_droit(1,1));
fprintf(fid, '%6.2f\t', angles_bassin_L3_droit(1,2));
fprintf(fid, '%6.2f\t', angles_bassin_L3_droit(1,3));
fprintf(fid, '%6.2f\t', angles_bassin_L3_tourne(1,1));
fprintf(fid, '%6.2f\t', angles_bassin_L3_tourne(1,2));
fprintf(fid, '%6.2f\n', angles_bassin_L3_tourne(1,3));

fprintf(fid, '%6.2f\t', angles_bassin_L3_droit(2,1));
fprintf(fid, '%6.2f\t', angles_bassin_L3_droit(2,2));
fprintf(fid, '%6.2f\t', angles_bassin_L3_droit(2,3));
fprintf(fid, '%6.2f\t', angles_bassin_L3_tourne(2,1));
fprintf(fid, '%6.2f\t', angles_bassin_L3_tourne(2,2));
fprintf(fid, '%6.2f\n', angles_bassin_L3_tourne(2,3));

fprintf(fid, '%6.2f\t', angles_bassin_L3_droit(3,1));
fprintf(fid, '%6.2f\t', angles_bassin_L3_droit(3,2));
fprintf(fid, '%6.2f\t', angles_bassin_L3_droit(3,3));
fprintf(fid, '%6.2f\t', angles_bassin_L3_tourne(3,1));
fprintf(fid, '%6.2f\t', angles_bassin_L3_tourne(3,2));
fprintf(fid, '%6.2f\n', angles_bassin_L3_tourne(3,3));

fprintf(fid, '%6.2f\t', angles_bassin_L3_droit(4,1));
fprintf(fid, '%6.2f\t', angles_bassin_L3_droit(4,2));
fprintf(fid, '%6.2f\t', angles_bassin_L3_droit(4,3));
fprintf(fid, '%6.2f\t', angles_bassin_L3_tourne(4,1));
fprintf(fid, '%6.2f\t', angles_bassin_L3_tourne(4,2));
fprintf(fid, '%6.2f\n', angles_bassin_L3_tourne(4,3));

fprintf(fid, '%6.2f\t', angles_bassin_L3_droit(5,1));
fprintf(fid, '%6.2f\t', angles_bassin_L3_droit(5,2));
fprintf(fid, '%6.2f\t', angles_bassin_L3_droit(5,3));
fprintf(fid, '%6.2f\t', angles_bassin_L3_tourne(5,1));
fprintf(fid, '%6.2f\t', angles_bassin_L3_tourne(5,2));
fprintf(fid, '%6.2f\n', angles_bassin_L3_tourne(5,3));

fprintf(fid, '%6.2f\t', angles_bassin_L3_droit(6,1));
fprintf(fid, '%6.2f\t', angles_bassin_L3_droit(6,2));
fprintf(fid, '%6.2f\t', angles_bassin_L3_droit(6,3));
fprintf(fid, '%6.2f\t', angles_bassin_L3_tourne(6,1));
fprintf(fid, '%6.2f\t', angles_bassin_L3_tourne(6,2));
fprintf(fid, '%6.2f\n', angles_bassin_L3_tourne(6,3));

fprintf(fid, '\n%s\n', 'L2');
fprintf(fid, '%6.2f\t', angles_bassin_L2_droit(1,1));
fprintf(fid, '%6.2f\t', angles_bassin_L2_droit(1,2));
fprintf(fid, '%6.2f\t', angles_bassin_L2_droit(1,3));
fprintf(fid, '%6.2f\t', angles_bassin_L2_tourne(1,1));
fprintf(fid, '%6.2f\t', angles_bassin_L2_tourne(1,2));
fprintf(fid, '%6.2f\n', angles_bassin_L2_tourne(1,3));

fprintf(fid, '%6.2f\t', angles_bassin_L2_droit(2,1));
fprintf(fid, '%6.2f\t', angles_bassin_L2_droit(2,2));
fprintf(fid, '%6.2f\t', angles_bassin_L2_droit(2,3));
fprintf(fid, '%6.2f\t', angles_bassin_L2_tourne(2,1));
fprintf(fid, '%6.2f\t', angles_bassin_L2_tourne(2,2));
fprintf(fid, '%6.2f\n', angles_bassin_L2_tourne(2,3));

fprintf(fid, '%6.2f\t', angles_bassin_L2_droit(3,1));
fprintf(fid, '%6.2f\t', angles_bassin_L2_droit(3,2));
fprintf(fid, '%6.2f\t', angles_bassin_L2_droit(3,3));
fprintf(fid, '%6.2f\t', angles_bassin_L2_tourne(3,1));
fprintf(fid, '%6.2f\t', angles_bassin_L2_tourne(3,2));
fprintf(fid, '%6.2f\n', angles_bassin_L2_tourne(3,3));

fprintf(fid, '%6.2f\t', angles_bassin_L2_droit(4,1));
fprintf(fid, '%6.2f\t', angles_bassin_L2_droit(4,2));
fprintf(fid, '%6.2f\t', angles_bassin_L2_droit(4,3));
fprintf(fid, '%6.2f\t', angles_bassin_L2_tourne(4,1));
fprintf(fid, '%6.2f\t', angles_bassin_L2_tourne(4,2));
fprintf(fid, '%6.2f\n', angles_bassin_L2_tourne(4,3));

fprintf(fid, '%6.2f\t', angles_bassin_L2_droit(5,1));
fprintf(fid, '%6.2f\t', angles_bassin_L2_droit(5,2));
fprintf(fid, '%6.2f\t', angles_bassin_L2_droit(5,3));
fprintf(fid, '%6.2f\t', angles_bassin_L2_tourne(5,1));
fprintf(fid, '%6.2f\t', angles_bassin_L2_tourne(5,2));
fprintf(fid, '%6.2f\n', angles_bassin_L2_tourne(5,3));

fprintf(fid, '%6.2f\t', angles_bassin_L2_droit(6,1));
fprintf(fid, '%6.2f\t', angles_bassin_L2_droit(6,2));
fprintf(fid, '%6.2f\t', angles_bassin_L2_droit(6,3));
fprintf(fid, '%6.2f\t', angles_bassin_L2_tourne(6,1));
fprintf(fid, '%6.2f\t', angles_bassin_L2_tourne(6,2));
fprintf(fid, '%6.2f\n', angles_bassin_L2_tourne(6,3));

fprintf(fid, '\n%s\n', 'L1');
fprintf(fid, '%6.2f\t', angles_bassin_L1_droit(1,1));
fprintf(fid, '%6.2f\t', angles_bassin_L1_droit(1,2));
fprintf(fid, '%6.2f\t', angles_bassin_L1_droit(1,3));
fprintf(fid, '%6.2f\t', angles_bassin_L1_tourne(1,1));
fprintf(fid, '%6.2f\t', angles_bassin_L1_tourne(1,2));
fprintf(fid, '%6.2f\n', angles_bassin_L1_tourne(1,3));

fprintf(fid, '%6.2f\t', angles_bassin_L1_droit(2,1));
fprintf(fid, '%6.2f\t', angles_bassin_L1_droit(2,2));
fprintf(fid, '%6.2f\t', angles_bassin_L1_droit(2,3));
fprintf(fid, '%6.2f\t', angles_bassin_L1_tourne(2,1));
fprintf(fid, '%6.2f\t', angles_bassin_L1_tourne(2,2));
fprintf(fid, '%6.2f\n', angles_bassin_L1_tourne(2,3));

fprintf(fid, '%6.2f\t', angles_bassin_L1_droit(3,1));
fprintf(fid, '%6.2f\t', angles_bassin_L1_droit(3,2));
fprintf(fid, '%6.2f\t', angles_bassin_L1_droit(3,3));
fprintf(fid, '%6.2f\t', angles_bassin_L1_tourne(3,1));
fprintf(fid, '%6.2f\t', angles_bassin_L1_tourne(3,2));
fprintf(fid, '%6.2f\n', angles_bassin_L1_tourne(3,3));

fprintf(fid, '%6.2f\t', angles_bassin_L1_droit(4,1));
fprintf(fid, '%6.2f\t', angles_bassin_L1_droit(4,2));
fprintf(fid, '%6.2f\t', angles_bassin_L1_droit(4,3));
fprintf(fid, '%6.2f\t', angles_bassin_L1_tourne(4,1));
fprintf(fid, '%6.2f\t', angles_bassin_L1_tourne(4,2));
fprintf(fid, '%6.2f\n', angles_bassin_L1_tourne(4,3));

fprintf(fid, '%6.2f\t', angles_bassin_L1_droit(5,1));
fprintf(fid, '%6.2f\t', angles_bassin_L1_droit(5,2));
fprintf(fid, '%6.2f\t', angles_bassin_L1_droit(5,3));
fprintf(fid, '%6.2f\t', angles_bassin_L1_tourne(5,1));
fprintf(fid, '%6.2f\t', angles_bassin_L1_tourne(5,2));
fprintf(fid, '%6.2f\n', angles_bassin_L1_tourne(5,3));

fprintf(fid, '%6.2f\t', angles_bassin_L1_droit(6,1));
fprintf(fid, '%6.2f\t', angles_bassin_L1_droit(6,2));
fprintf(fid, '%6.2f\t', angles_bassin_L1_droit(6,3));
fprintf(fid, '%6.2f\t', angles_bassin_L1_tourne(6,1));
fprintf(fid, '%6.2f\t', angles_bassin_L1_tourne(6,2));
fprintf(fid, '%6.2f\n', angles_bassin_L1_tourne(6,3));

fprintf(fid, '\n%s\n', 'C7');
fprintf(fid, '%6.2f\t', angles_bassin_C7_droit(1,1));
fprintf(fid, '%6.2f\t', angles_bassin_C7_droit(1,2));
fprintf(fid, '%6.2f\t', angles_bassin_C7_droit(1,3));
fprintf(fid, '%6.2f\t', angles_bassin_C7_tourne(1,1));
fprintf(fid, '%6.2f\t', angles_bassin_C7_tourne(1,2));
fprintf(fid, '%6.2f\n', angles_bassin_C7_tourne(1,3));

fprintf(fid, '%6.2f\t', angles_bassin_C7_droit(2,1));
fprintf(fid, '%6.2f\t', angles_bassin_C7_droit(2,2));
fprintf(fid, '%6.2f\t', angles_bassin_C7_droit(2,3));
fprintf(fid, '%6.2f\t', angles_bassin_C7_tourne(2,1));
fprintf(fid, '%6.2f\t', angles_bassin_C7_tourne(2,2));
fprintf(fid, '%6.2f\n', angles_bassin_C7_tourne(2,3));

fprintf(fid, '%6.2f\t', angles_bassin_C7_droit(3,1));
fprintf(fid, '%6.2f\t', angles_bassin_C7_droit(3,2));
fprintf(fid, '%6.2f\t', angles_bassin_C7_droit(3,3));
fprintf(fid, '%6.2f\t', angles_bassin_C7_tourne(3,1));
fprintf(fid, '%6.2f\t', angles_bassin_C7_tourne(3,2));
fprintf(fid, '%6.2f\n', angles_bassin_C7_tourne(3,3));

fprintf(fid, '%6.2f\t', angles_bassin_C7_droit(4,1));
fprintf(fid, '%6.2f\t', angles_bassin_C7_droit(4,2));
fprintf(fid, '%6.2f\t', angles_bassin_C7_droit(4,3));
fprintf(fid, '%6.2f\t', angles_bassin_C7_tourne(4,1));
fprintf(fid, '%6.2f\t', angles_bassin_C7_tourne(4,2));
fprintf(fid, '%6.2f\n', angles_bassin_C7_tourne(4,3));

fprintf(fid, '%6.2f\t', angles_bassin_C7_droit(5,1));
fprintf(fid, '%6.2f\t', angles_bassin_C7_droit(5,2));
fprintf(fid, '%6.2f\t', angles_bassin_C7_droit(5,3));
fprintf(fid, '%6.2f\t', angles_bassin_C7_tourne(5,1));
fprintf(fid, '%6.2f\t', angles_bassin_C7_tourne(5,2));
fprintf(fid, '%6.2f\n', angles_bassin_C7_tourne(5,3));

fprintf(fid, '%6.2f\t', angles_bassin_C7_droit(6,1));
fprintf(fid, '%6.2f\t', angles_bassin_C7_droit(6,2));
fprintf(fid, '%6.2f\t', angles_bassin_C7_droit(6,3));
fprintf(fid, '%6.2f\t', angles_bassin_C7_tourne(6,1));
fprintf(fid, '%6.2f\t', angles_bassin_C7_tourne(6,2));
fprintf(fid, '%6.2f\n', angles_bassin_C7_tourne(6,3));

fclose(fid);


%%dans le repère L5
cd(repertoire_sortie)
fichier_sortie_L5=[fichier_sortie qui_fait_la_manip '_L5.txt'];
fid=fopen(fichier_sortie_L5, 'w');
fprintf(fid, '%s\n', 'angles dans le repère de L5');

fprintf(fid, '%s\n', 'approximation de la répartition de la rotation');
angle_lombaire_approx_L5=angles_L5_L1_tourne(6,3)-angles_L5_L1_droit(6,3);
angle_total_approx_L5=0.25*(angle1_L5+angle1_L5+angle3_L5+angle4_L5);
angle_thoracique_approx_L5=angles_L5_C7_tourne(6,3)-angles_L5_C7_droit(6,3)-...
    angle_lombaire_approx_L5;
angle_epaule_approx_L5=angle_total_approx_L5-angle_thoracique_approx_L5-angle_lombaire_approx_L5;
fprintf(fid, '%s\t%s\t%s\n', 'type angle', 'degrés', 'pourcentage');
fprintf(fid, '%s\t%6.2f%s\t%6.2f%s\n', 'lombaires', angle_lombaire_approx_L5, 'deg',(angle_lombaire_approx_L5/angle_total_approx_L5*100), '%');
fprintf(fid, '%s\t%6.2f%s\t%6.2f%s\n', 'thoraciques', angle_thoracique_approx_L5,'deg', (angle_thoracique_approx_L5/angle_total_approx_L5*100), '%');
fprintf(fid, '%s\t%6.2f%s\t%6.2f%s\n', 'épaule', angle_epaule_approx_L5, 'deg',(angle_epaule_approx_L5/angle_total_approx_L5*100), '%');

fprintf(fid, '%s\t%s\t%s\t%s\t%s\t%s\n', 'droit_X', 'droit_Y', 'droit_Z', 'tourne_X', 'tourne_Y', 'tourne_Z');
fprintf(fid, '\n%s\n', 'angle_barre_degré');
fprintf(fid, '%6.2f\t', angle1_L5);
fprintf(fid, '%6.2f\t', angle2_L5);
fprintf(fid, '%6.2f\t', angle3_L5);
fprintf(fid, '%6.2f\t\n', angle4_L5);


fprintf(fid, '\n%s\n', 'L4');
fprintf(fid, '%6.2f\t', angles_L5_L4_droit(1,1));
fprintf(fid, '%6.2f\t', angles_L5_L4_droit(1,2));
fprintf(fid, '%6.2f\t', angles_L5_L4_droit(1,3));
fprintf(fid, '%6.2f\t', angles_L5_L4_tourne(1,1));
fprintf(fid, '%6.2f\t', angles_L5_L4_tourne(1,2));
fprintf(fid, '%6.2f\n', angles_L5_L4_tourne(1,3));

fprintf(fid, '%6.2f\t', angles_L5_L4_droit(2,1));
fprintf(fid, '%6.2f\t', angles_L5_L4_droit(2,2));
fprintf(fid, '%6.2f\t', angles_L5_L4_droit(2,3));
fprintf(fid, '%6.2f\t', angles_L5_L4_tourne(2,1));
fprintf(fid, '%6.2f\t', angles_L5_L4_tourne(2,2));
fprintf(fid, '%6.2f\n', angles_L5_L4_tourne(2,3));

fprintf(fid, '%6.2f\t', angles_L5_L4_droit(3,1));
fprintf(fid, '%6.2f\t', angles_L5_L4_droit(3,2));
fprintf(fid, '%6.2f\t', angles_L5_L4_droit(3,3));
fprintf(fid, '%6.2f\t', angles_L5_L4_tourne(3,1));
fprintf(fid, '%6.2f\t', angles_L5_L4_tourne(3,2));
fprintf(fid, '%6.2f\n', angles_L5_L4_tourne(3,3));

fprintf(fid, '%6.2f\t', angles_L5_L4_droit(4,1));
fprintf(fid, '%6.2f\t', angles_L5_L4_droit(4,2));
fprintf(fid, '%6.2f\t', angles_L5_L4_droit(4,3));
fprintf(fid, '%6.2f\t', angles_L5_L4_tourne(4,1));
fprintf(fid, '%6.2f\t', angles_L5_L4_tourne(4,2));
fprintf(fid, '%6.2f\n', angles_L5_L4_tourne(4,3));

fprintf(fid, '%6.2f\t', angles_L5_L4_droit(5,1));
fprintf(fid, '%6.2f\t', angles_L5_L4_droit(5,2));
fprintf(fid, '%6.2f\t', angles_L5_L4_droit(5,3));
fprintf(fid, '%6.2f\t', angles_L5_L4_tourne(5,1));
fprintf(fid, '%6.2f\t', angles_L5_L4_tourne(5,2));
fprintf(fid, '%6.2f\n', angles_L5_L4_tourne(5,3));

fprintf(fid, '%6.2f\t', angles_L5_L4_droit(6,1));
fprintf(fid, '%6.2f\t', angles_L5_L4_droit(6,2));
fprintf(fid, '%6.2f\t', angles_L5_L4_droit(6,3));
fprintf(fid, '%6.2f\t', angles_L5_L4_tourne(6,1));
fprintf(fid, '%6.2f\t', angles_L5_L4_tourne(6,2));
fprintf(fid, '%6.2f\n', angles_L5_L4_tourne(6,3));

fprintf(fid, '\n%s\n', 'L3');
fprintf(fid, '%6.2f\t', angles_L5_L3_droit(1,1));
fprintf(fid, '%6.2f\t', angles_L5_L3_droit(1,2));
fprintf(fid, '%6.2f\t', angles_L5_L3_droit(1,3));
fprintf(fid, '%6.2f\t', angles_L5_L3_tourne(1,1));
fprintf(fid, '%6.2f\t', angles_L5_L3_tourne(1,2));
fprintf(fid, '%6.2f\n', angles_L5_L3_tourne(1,3));

fprintf(fid, '%6.2f\t', angles_L5_L3_droit(2,1));
fprintf(fid, '%6.2f\t', angles_L5_L3_droit(2,2));
fprintf(fid, '%6.2f\t', angles_L5_L3_droit(2,3));
fprintf(fid, '%6.2f\t', angles_L5_L3_tourne(2,1));
fprintf(fid, '%6.2f\t', angles_L5_L3_tourne(2,2));
fprintf(fid, '%6.2f\n', angles_L5_L3_tourne(2,3));

fprintf(fid, '%6.2f\t', angles_L5_L3_droit(3,1));
fprintf(fid, '%6.2f\t', angles_L5_L3_droit(3,2));
fprintf(fid, '%6.2f\t', angles_L5_L3_droit(3,3));
fprintf(fid, '%6.2f\t', angles_L5_L3_tourne(3,1));
fprintf(fid, '%6.2f\t', angles_L5_L3_tourne(3,2));
fprintf(fid, '%6.2f\n', angles_L5_L3_tourne(3,3));

fprintf(fid, '%6.2f\t', angles_L5_L3_droit(4,1));
fprintf(fid, '%6.2f\t', angles_L5_L3_droit(4,2));
fprintf(fid, '%6.2f\t', angles_L5_L3_droit(4,3));
fprintf(fid, '%6.2f\t', angles_L5_L3_tourne(4,1));
fprintf(fid, '%6.2f\t', angles_L5_L3_tourne(4,2));
fprintf(fid, '%6.2f\n', angles_L5_L3_tourne(4,3));

fprintf(fid, '%6.2f\t', angles_L5_L3_droit(5,1));
fprintf(fid, '%6.2f\t', angles_L5_L3_droit(5,2));
fprintf(fid, '%6.2f\t', angles_L5_L3_droit(5,3));
fprintf(fid, '%6.2f\t', angles_L5_L3_tourne(5,1));
fprintf(fid, '%6.2f\t', angles_L5_L3_tourne(5,2));
fprintf(fid, '%6.2f\n', angles_L5_L3_tourne(5,3));

fprintf(fid, '%6.2f\t', angles_L5_L3_droit(6,1));
fprintf(fid, '%6.2f\t', angles_L5_L3_droit(6,2));
fprintf(fid, '%6.2f\t', angles_L5_L3_droit(6,3));
fprintf(fid, '%6.2f\t', angles_L5_L3_tourne(6,1));
fprintf(fid, '%6.2f\t', angles_L5_L3_tourne(6,2));
fprintf(fid, '%6.2f\n', angles_L5_L3_tourne(6,3));

fprintf(fid, '\n%s\n', 'L2');
fprintf(fid, '%6.2f\t', angles_L5_L2_droit(1,1));
fprintf(fid, '%6.2f\t', angles_L5_L2_droit(1,2));
fprintf(fid, '%6.2f\t', angles_L5_L2_droit(1,3));
fprintf(fid, '%6.2f\t', angles_L5_L2_tourne(1,1));
fprintf(fid, '%6.2f\t', angles_L5_L2_tourne(1,2));
fprintf(fid, '%6.2f\n', angles_L5_L2_tourne(1,3));

fprintf(fid, '%6.2f\t', angles_L5_L2_droit(2,1));
fprintf(fid, '%6.2f\t', angles_L5_L2_droit(2,2));
fprintf(fid, '%6.2f\t', angles_L5_L2_droit(2,3));
fprintf(fid, '%6.2f\t', angles_L5_L2_tourne(2,1));
fprintf(fid, '%6.2f\t', angles_L5_L2_tourne(2,2));
fprintf(fid, '%6.2f\n', angles_L5_L2_tourne(2,3));

fprintf(fid, '%6.2f\t', angles_L5_L2_droit(3,1));
fprintf(fid, '%6.2f\t', angles_L5_L2_droit(3,2));
fprintf(fid, '%6.2f\t', angles_L5_L2_droit(3,3));
fprintf(fid, '%6.2f\t', angles_L5_L2_tourne(3,1));
fprintf(fid, '%6.2f\t', angles_L5_L2_tourne(3,2));
fprintf(fid, '%6.2f\n', angles_L5_L2_tourne(3,3));

fprintf(fid, '%6.2f\t', angles_L5_L2_droit(4,1));
fprintf(fid, '%6.2f\t', angles_L5_L2_droit(4,2));
fprintf(fid, '%6.2f\t', angles_L5_L2_droit(4,3));
fprintf(fid, '%6.2f\t', angles_L5_L2_tourne(4,1));
fprintf(fid, '%6.2f\t', angles_L5_L2_tourne(4,2));
fprintf(fid, '%6.2f\n', angles_L5_L2_tourne(4,3));

fprintf(fid, '%6.2f\t', angles_L5_L2_droit(5,1));
fprintf(fid, '%6.2f\t', angles_L5_L2_droit(5,2));
fprintf(fid, '%6.2f\t', angles_L5_L2_droit(5,3));
fprintf(fid, '%6.2f\t', angles_L5_L2_tourne(5,1));
fprintf(fid, '%6.2f\t', angles_L5_L2_tourne(5,2));
fprintf(fid, '%6.2f\n', angles_L5_L2_tourne(5,3));

fprintf(fid, '%6.2f\t', angles_L5_L2_droit(6,1));
fprintf(fid, '%6.2f\t', angles_L5_L2_droit(6,2));
fprintf(fid, '%6.2f\t', angles_L5_L2_droit(6,3));
fprintf(fid, '%6.2f\t', angles_L5_L2_tourne(6,1));
fprintf(fid, '%6.2f\t', angles_L5_L2_tourne(6,2));
fprintf(fid, '%6.2f\n', angles_L5_L2_tourne(6,3));

fprintf(fid, '\n%s\n', 'L1');
fprintf(fid, '%6.2f\t', angles_L5_L1_droit(1,1));
fprintf(fid, '%6.2f\t', angles_L5_L1_droit(1,2));
fprintf(fid, '%6.2f\t', angles_L5_L1_droit(1,3));
fprintf(fid, '%6.2f\t', angles_L5_L1_tourne(1,1));
fprintf(fid, '%6.2f\t', angles_L5_L1_tourne(1,2));
fprintf(fid, '%6.2f\n', angles_L5_L1_tourne(1,3));

fprintf(fid, '%6.2f\t', angles_L5_L1_droit(2,1));
fprintf(fid, '%6.2f\t', angles_L5_L1_droit(2,2));
fprintf(fid, '%6.2f\t', angles_L5_L1_droit(2,3));
fprintf(fid, '%6.2f\t', angles_L5_L1_tourne(2,1));
fprintf(fid, '%6.2f\t', angles_L5_L1_tourne(2,2));
fprintf(fid, '%6.2f\n', angles_L5_L1_tourne(2,3));

fprintf(fid, '%6.2f\t', angles_L5_L1_droit(3,1));
fprintf(fid, '%6.2f\t', angles_L5_L1_droit(3,2));
fprintf(fid, '%6.2f\t', angles_L5_L1_droit(3,3));
fprintf(fid, '%6.2f\t', angles_L5_L1_tourne(3,1));
fprintf(fid, '%6.2f\t', angles_L5_L1_tourne(3,2));
fprintf(fid, '%6.2f\n', angles_L5_L1_tourne(3,3));

fprintf(fid, '%6.2f\t', angles_L5_L1_droit(4,1));
fprintf(fid, '%6.2f\t', angles_L5_L1_droit(4,2));
fprintf(fid, '%6.2f\t', angles_L5_L1_droit(4,3));
fprintf(fid, '%6.2f\t', angles_L5_L1_tourne(4,1));
fprintf(fid, '%6.2f\t', angles_L5_L1_tourne(4,2));
fprintf(fid, '%6.2f\n', angles_L5_L1_tourne(4,3));

fprintf(fid, '%6.2f\t', angles_L5_L1_droit(5,1));
fprintf(fid, '%6.2f\t', angles_L5_L1_droit(5,2));
fprintf(fid, '%6.2f\t', angles_L5_L1_droit(5,3));
fprintf(fid, '%6.2f\t', angles_L5_L1_tourne(5,1));
fprintf(fid, '%6.2f\t', angles_L5_L1_tourne(5,2));
fprintf(fid, '%6.2f\n', angles_L5_L1_tourne(5,3));

fprintf(fid, '%6.2f\t', angles_L5_L1_droit(6,1));
fprintf(fid, '%6.2f\t', angles_L5_L1_droit(6,2));
fprintf(fid, '%6.2f\t', angles_L5_L1_droit(6,3));
fprintf(fid, '%6.2f\t', angles_L5_L1_tourne(6,1));
fprintf(fid, '%6.2f\t', angles_L5_L1_tourne(6,2));
fprintf(fid, '%6.2f\n', angles_L5_L1_tourne(6,3));

fprintf(fid, '\n%s\n', 'C7');
fprintf(fid, '%6.2f\t', angles_L5_C7_droit(1,1));
fprintf(fid, '%6.2f\t', angles_L5_C7_droit(1,2));
fprintf(fid, '%6.2f\t', angles_L5_C7_droit(1,3));
fprintf(fid, '%6.2f\t', angles_L5_C7_tourne(1,1));
fprintf(fid, '%6.2f\t', angles_L5_C7_tourne(1,2));
fprintf(fid, '%6.2f\n', angles_L5_C7_tourne(1,3));

fprintf(fid, '%6.2f\t', angles_L5_C7_droit(2,1));
fprintf(fid, '%6.2f\t', angles_L5_C7_droit(2,2));
fprintf(fid, '%6.2f\t', angles_L5_C7_droit(2,3));
fprintf(fid, '%6.2f\t', angles_L5_C7_tourne(2,1));
fprintf(fid, '%6.2f\t', angles_L5_C7_tourne(2,2));
fprintf(fid, '%6.2f\n', angles_L5_C7_tourne(2,3));

fprintf(fid, '%6.2f\t', angles_L5_C7_droit(3,1));
fprintf(fid, '%6.2f\t', angles_L5_C7_droit(3,2));
fprintf(fid, '%6.2f\t', angles_L5_C7_droit(3,3));
fprintf(fid, '%6.2f\t', angles_L5_C7_tourne(3,1));
fprintf(fid, '%6.2f\t', angles_L5_C7_tourne(3,2));
fprintf(fid, '%6.2f\n', angles_L5_C7_tourne(3,3));

fprintf(fid, '%6.2f\t', angles_L5_C7_droit(4,1));
fprintf(fid, '%6.2f\t', angles_L5_C7_droit(4,2));
fprintf(fid, '%6.2f\t', angles_L5_C7_droit(4,3));
fprintf(fid, '%6.2f\t', angles_L5_C7_tourne(4,1));
fprintf(fid, '%6.2f\t', angles_L5_C7_tourne(4,2));
fprintf(fid, '%6.2f\n', angles_L5_C7_tourne(4,3));

fprintf(fid, '%6.2f\t', angles_L5_C7_droit(5,1));
fprintf(fid, '%6.2f\t', angles_L5_C7_droit(5,2));
fprintf(fid, '%6.2f\t', angles_L5_C7_droit(5,3));
fprintf(fid, '%6.2f\t', angles_L5_C7_tourne(5,1));
fprintf(fid, '%6.2f\t', angles_L5_C7_tourne(5,2));
fprintf(fid, '%6.2f\n', angles_L5_C7_tourne(5,3));

fprintf(fid, '%6.2f\t', angles_L5_C7_droit(6,1));
fprintf(fid, '%6.2f\t', angles_L5_C7_droit(6,2));
fprintf(fid, '%6.2f\t', angles_L5_C7_droit(6,3));
fprintf(fid, '%6.2f\t', angles_L5_C7_tourne(6,1));
fprintf(fid, '%6.2f\t', angles_L5_C7_tourne(6,2));
fprintf(fid, '%6.2f\n', angles_L5_C7_tourne(6,3));

fclose(fid);