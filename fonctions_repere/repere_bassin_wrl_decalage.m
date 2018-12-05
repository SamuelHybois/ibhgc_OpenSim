function [MH_R0Rlocal,SP]=repere_bassin_wrl_decalage(file_wrl,file_ddr,decalage_in_bassin_G_mm,decalage_in_bassin_D_mm)
% Sauret Christophe
% 20/01/2016
% modification fev 2016
%
% Définition du repère Bassin à partir du fichier wrl EOS et du fichier ddr
% file_wrl et file_ddr contiennent le chemin et le nom de fichier
%
% Attention les coordonnées du centres sont données en mm


% lire le fichier wrl
Objet_Bassin=lire_fichier_vrml(file_wrl);

% lire le fichier ddr
Reg_fem = lire_fichier_ddr(file_ddr);
Regions_Bassin = RegtyI2tyII(Reg_fem,'Polygones');

% Accetabulum G
AccetaG = ISOLE_SURF_MAILLAGE('Polygones',Regions_Bassin.Acetabulum_G.Polygones,Objet_Bassin);
AG = sphere_moindres_carres(AccetaG.Noeuds); AG=AG.Centre';
if norm(decalage_in_bassin_G_mm)~=0
    AG=AG+decalage_in_bassin_G_mm;
end

% Accetabulum D
AccetaD = ISOLE_SURF_MAILLAGE('Polygones',Regions_Bassin.Acetabulum_D.Polygones,Objet_Bassin);
AD = sphere_moindres_carres(AccetaD.Noeuds); AD=AD.Centre';
if norm(decalage_in_bassin_D_mm)~=0
    AD=AD+decalage_in_bassin_D_mm;
end

% Plateau sacré
SacralPlate = ISOLE_SURF_MAILLAGE('Polygones',Regions_Bassin.Plateau_Sacrum.Polygones,Objet_Bassin);
SP = barycentre(SacralPlate.Noeuds); SP=SP';

% construction du repère Bassin
Z= (AD-AG); Z=Z/norm(Z); % médio-latéral
X = (cross(AD-SP,AG-SP)); X=X/norm(X); %normal au plan contenant accétabulum et plateau sacré (globalement postéro-antérieur)
Y = cross(Z,X); % globalement inféro-supérieur
O = (AD + AG)/2; % milieu des acétabulum

MH_R0Rlocal = [X,Y,Z,O;[0,0,0,1]];






