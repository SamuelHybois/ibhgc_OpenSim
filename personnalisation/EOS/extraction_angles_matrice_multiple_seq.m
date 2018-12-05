function [ angles_sorties ] = extraction_angles_matrice_multiple_seq( M )

% création de la matrice des angles de rotation d'une matrice données en
% fonction de la séquence considérée.
% angles_sorties = matrice 6x3
% [axyz,bxyz,cxyz]
% [axzy,bxzy,cxzy]
% [ayxz,byxz,cyxz]
% [ayzx,byzx,cyzx]
% [azxy,bzxy,czxy]
% [azyx,bzyx,czyx]

[axyz,bxyz,cxyz]=axe_mobile_xyz(M);
angles_sorties=[axyz,bxyz,cxyz];
[axzy,bxzy,cxzy]=axe_mobile_xzy(M);
angles_sorties=[angles_sorties; axzy,bxzy,cxzy];

[ayxz,byxz,cyxz]=axe_mobile_yxz(M);
angles_sorties=[angles_sorties;ayxz,byxz,cyxz];
[ayzx,byzx,cyzx]=axe_mobile_yzx(M);
angles_sorties=[angles_sorties;ayzx,byzx,cyzx];

[azxy,bzxy,czxy]=axe_mobile_zxy(M);
angles_sorties=[angles_sorties;azxy,bzxy,czxy];
[azyx,bzyx,czyx]=axe_mobile_zyx(M);
angles_sorties=[angles_sorties;azyx,bzyx,czyx];




end

