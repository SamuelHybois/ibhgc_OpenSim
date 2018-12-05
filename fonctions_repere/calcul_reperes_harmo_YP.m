%% Yoann Poulet 30/08/2018
%A chaque fois que l'on parle d'une région comme par exemple la tete femorale ou le condyle,
%il s'agit du barycentre de la région dans la forme suivante:[x y z]
%
%
% input pour le cas 'bassin':
%   ('bassin', Acetabulum droit, Acetabulum gauche, vecteur normal au plan_moindres_carres des deux tetes femorales et des deux épines sciatiques)
%
% input pour les cas 'femurD' et 'fermurG':
%   ('femurD', condyle ext, condyle int, tête femorale)
%
% input pour les cas 'tibiaD' et 'tibiaG':
%   ('tibiaD', Centre du genou, Malléole ext, Malléole int)
%
% input pour les cas 'chevilleD' et 'chevilleG':
%   ('chevilleD', Centre du genou,centre de la cheville,Bas_Mal)
% où Bas_mal est un struct contenant le point le plus bas de la malléole de chaque malléole (int et ext)
%
% input pour le cas 'cervicale'
%   ('cervicale', plateau inf, plateau sup, apophyse transverse gauche, apophyse transverse droite)
%
% input pour les cas 'lombaire' et 'thoracique':
%   ('lombaire', plateau inf, plateau sup, pédicule gauche, pédicule droit)
%
% input pour le cas 'tete':
%   ('tete', nasion, porion droit, porion gauche)
%%
function repere= calcul_reperes_harmo_YP(cas,varargin)

switch cas
    case 'bassin'
        A_D=varargin{1};
        A_G=varargin{2};
        Normale=varargin{3}; 
        Z=(A_D-A_G)/norm(A_D-A_G);
        X=cross(Normale,Z)/norm(cross(Normale,Z));
        Y=cross(Z,X);
        O=(A_D+A_G)/2;
        
    case 'femurD'
        Cond_ext=varargin{1};
        Cond_int=varargin{2};
        FH=varargin{3};
        milieu_condyle=(Cond_ext+Cond_int)/2;
        Y=(FH-milieu_condyle)/norm(FH-milieu_condyle);
        X=cross(Cond_ext-FH,Cond_int-FH)/norm(cross(Cond_ext-FH,Cond_int-FH));
        Z=cross(X,Y);
        O=FH;
        
    case 'femurG'
        Cond_ext=varargin{1};
        Cond_int=varargin{2};
        FH=varargin{3};
        milieu_condyle=(Cond_ext+Cond_int)/2;
        Y=(FH-milieu_condyle)/norm(FH-milieu_condyle);
        X=cross(Cond_int-FH,Cond_ext-FH)/norm(cross(Cond_int-FH,Cond_ext-FH));
        Z=cross(X,Y);
        O=FH;
        
    case 'tibiaD'
        KJC=varargin{1};
        Mal_ext=varargin{2};
        Mal_int=varargin{3};
        milieu_malleole=(Mal_ext+Mal_int)/2;
        Y=(KJC-milieu_malleole)/norm(KJC-milieu_malleole);
        X=cross(Mal_ext-KJC,Mal_int-KJC)/norm(cross(Mal_ext-KJC,Mal_int-KJC));
        Z=cross(X,Y);
        O=KJC;
        
    case 'tibiaG'
        KJC=varargin{1};
        Mal_ext=varargin{2};
        Mal_int=varargin{3};
        milieu_malleole=(Mal_ext+Mal_int)/2;
        Y=(KJC-milieu_malleole)/norm(KJC-milieu_malleole);
        X=cross(Mal_int-KJC,Mal_ext-KJC)/norm(cross(Mal_int-KJC,Mal_ext-KJC));
        Z=cross(X,Y);
        O=KJC;
        
    case 'chevilleD'
        KJC=varargin{1};
        AJC=varargin{2};
        Bas_Mal=varargin{3};
        milieu_bas_mal=(Bas_Mal.ext+Bas_Mal.int)/2;
        Y=(KJC-AJC)/norm(KJC-AJC);
        Z=(Bas_Mal.int-Bas_Mal.ext)/norm(Bas_Mal.int-Bas_Mal.ext);
        X=cross(Y,Z)/norm(cross(Y,Z));
        O=milieu_bas_mal;
        
    case 'chevilleG'
        KJC=varargin{1};
        AJC=varargin{2};
        Bas_Mal=varargin{3};
        milieu_bas_mal=(Bas_Mal.ext+Bas_Mal.int)/2;
        Y=(KJC-AJC)/norm(KJC-AJC);
        Z=(Bas_Mal.ext-Bas_Mal.int)/norm(Bas_Mal.ext-Bas_Mal.int);
        X=cross(Y,Z)/norm(cross(Y,Z));
        O=milieu_bas_mal;
        
    case 'cervicale'
        centre_plateau_inf=varargin{1};
        centre_plateau_sup=varargin{2};
        Apophyse_Transverse_G=varargin{3};
        Apophyse_Transverse_D=varargin{4};
        Y=((centre_plateau_sup-centre_plateau_inf)/norm((centre_plateau_sup-centre_plateau_inf)));
        X = cross(Y,Apophyse_Transverse_D-Apophyse_Transverse_G)/norm(cross(Y,Apophyse_Transverse_D-Apophyse_Transverse_G));
        Z=cross(X,Y);
        O =((centre_plateau_inf + centre_plateau_sup)/2);
        
    case 'lombaire'
        centre_plateau_inf=varargin{1};
        centre_plateau_sup=varargin{2};
        Ped_g=varargin{3};
        Ped_d=varargin{4};
        Y=((centre_plateau_sup-centre_plateau_inf)/norm((centre_plateau_sup-centre_plateau_inf)));
        X=cross(Y,Ped_d-Ped_g)/norm(cross(Y,Ped_d-Ped_g));
        Z=cross(X,Y);
        O =((centre_plateau_inf + centre_plateau_sup)/2);
        
    case 'thoracique'
        centre_plateau_inf=varargin{1};
        centre_plateau_sup=varargin{2};
        Ped_g=varargin{3};
        Ped_d=varargin{4};
        Y=((centre_plateau_sup-centre_plateau_inf)/norm((centre_plateau_sup-centre_plateau_inf)));
        X=cross(Y,Ped_d-Ped_g)/norm(cross(Y,Ped_d-Ped_g));
        Z=cross(X,Y);
        O =((centre_plateau_inf + centre_plateau_sup)/2);
        
    case 'tete'
        nasion=varargin{1};
        oreilleD=varargin{2};
        oreilleG=varargin{3};
        X=((nasion-((oreilleD + oreilleG)/2))/norm(nasion-((oreilleD + oreilleG)/2)));
        Z=((oreilleD-oreilleG)/norm(oreilleD-oreilleG));
        Y=cross(Z,X);
        O=((oreilleD + oreilleG)/2);
        
        
end

repere = [X',Y',Z',O';0,0,0,1];
end
