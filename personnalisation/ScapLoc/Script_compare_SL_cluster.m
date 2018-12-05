
addpath(genpath('D:\Git_Pipeline_OpenSim'))
Sujet='SP04CD';lat = 'droite' ;

Repertoire='D:\Git_Pipeline_OpenSim\dataTest\rep_global_FRMB\SP01SM\ScapLoc';
Fichier_prot='D:\Git_Pipeline_OpenSim\dataTest\rep_global_FRMB\info_global\FRM_bilateral_STJ.protOS';
st_protocole_pretraitement=lire_fichier_prot_2(Fichier_prot);

Fichier='Prop_R_F_01.c3d';%'Tennis_R_serve_01.c3d'; %'Prop_R_R_01.c3d'; %'Basket_R_shoot_01.c3d';
my_c3d = btk_loadc3d(fullfile(Repertoire, Fichier));
my_c3d = zero2NaN((NettoieMarkerLabels(my_c3d.marker_data.Markers)));
Marqueurs = fieldnames(my_c3d);
dist_SL = 0.085 ; %distance entre les palpeurs/marqueurs du SL

%1.2 Amélioration des données cinématique
%1.2.1 Changement de système d'axe pour éviter gimbal lock
M_pass_VICON_OS = eye(3,3);
for i_marqueur = 1:size(Marqueurs,1)
    Data_R0= my_c3d.(Marqueurs{i_marqueur});
    Data_R1= M_pass_VICON_OS' * Data_R0';
    my_c3d.(Marqueurs{i_marqueur}) = Data_R1';
end


%1.2.2 interpolation si petit trous
taille_trou = 15;
n_mg = 5;
nb_min_points = round( taille_trou/2);

for i_marqueur = 1:size(Marqueurs,1)
    Data = my_c3d.(Marqueurs{i_marqueur});
    Data_output = bouche_petits_trous_coord3D(Data,n_mg,taille_trou,nb_min_points);
    my_c3d.(Marqueurs{i_marqueur}) = Data_output;
end

% 1.2.3 Recalage rigide si gros trous
list_seg=fieldnames(st_protocole_pretraitement.SEGMENTS);
nb_seg=size(list_seg,1);

for i_seg=1:nb_seg
    try
        cur_seg=list_seg{i_seg};
        Marqueurs_Segment=st_protocole_pretraitement.SEGMENTS.(cur_seg);
        my_c3d = recalage_rigide_grands_trous(my_c3d,Marqueurs_Segment);
    catch
        disp(['!!! Erreur recalage rigide pour ',cur_seg,', marqueurs manquants dans le c3d !!!'])
    end
    
    
end

% 1.2.4 Re interpolation si petits trous

for i_marqueur = 1:size(Marqueurs,1)
    Data = my_c3d.(Marqueurs{i_marqueur});
    Data_output = bouche_petits_trous_coord3D(Data,n_mg,taille_trou,nb_min_points);
    my_c3d.(Marqueurs{i_marqueur}) = Data_output;
end

% 1.2.5 Extrapolation sur les bords
for i_marqueur = 1:size(Marqueurs,1)
    my_c3d.(Marqueurs{i_marqueur}) = extrapolation_petits_trous_bords(my_c3d.(Marqueurs{i_marqueur}),taille_trou);
end

% 2. Repères SCAPULA dans OS et Vicon
% SCAPULA LOCATOR
SCLM = my_c3d.SCLM/1000 ;
SCLB = my_c3d.SCLB/1000 ;
SCLL = my_c3d.SCLL/1000 ;
SCLHM = my_c3d.SCLHM/1000 ;
SCLHL = my_c3d.SCLHL/1000 ;
ACD = my_c3d.ACD/1000 ;

% Recalage vertical ScapLoc
u1 = (SCLHM - SCLB)./norm(SCLHM - SCLB);
u2 = (SCLHL - SCLB)./norm(SCLHL - SCLB);
normale_plan_ScapLoc = cross(u1,u2)./norm(cross(u1,u2));

SCLM = SCLM + dist_SL.*normale_plan_ScapLoc ;
SCLB = SCLB + dist_SL.*normale_plan_ScapLoc ;
SCLL = SCLL + dist_SL.*normale_plan_ScapLoc ;

% Création du repère ScapLoc
Z_SL=(SCLL-SCLM)./repmat(sqrt(sum((SCLL-SCLM).^2,2)),[1,3]);
Y_SL=(SCLM-SCLB)./repmat(sqrt(sum((SCLM-SCLB).^2,2)),[1,3]);
X_SL=cross(Y_SL,Z_SL)./repmat(sqrt(sum(cross(Y_SL,Z_SL).^2,2)),[1,3]);
Y_SL=cross(Z_SL,X_SL);
O_SL=SCLL;

%SCAPULA CLUSTER
MTACDL = my_c3d.MTACDL/1000 ;
MTACDM = my_c3d.MTACDM/1000 ;
MTACDB = my_c3d.MTACDB/1000 ;

iframe=1;
Z_CL=ACD(iframe,:)-mean([MTACDL(iframe,:);MTACDM(iframe,:);MTACDB(iframe,:)],1); Z_CL=Z_CL/norm(Z_CL);
Y_CL=MTACDM(iframe,:)-MTACDB(iframe,:); Y_CL=Y_CL/norm(Y_CL);
X_CL=cross(Y_CL,Z_CL);X_CL=X_CL/norm(X_CL);
Y_CL=cross(Z_CL,X_CL);
O_CL=ACD(iframe,:);

%Passage ScapLoc->CLuster
TR0_SL=[X_SL(iframe,:)' Y_SL(iframe,:)' Z_SL(iframe,:)' O_SL(iframe,:)' ; 0 0 0 1];
TR0_CL=[X_CL' Y_CL' Z_CL' O_CL' ; 0 0 0 1];
TSL_CL = inv(TR0_SL)*TR0_CL;

%SCAPULA VIRTUELLE
Cluster_to_register=[ACD(1,:); MTACDM(1,:); MTACDB(1,:); MTACDL(1,:)];
Axe_Angle=NaN(size(ACD,1),4);
Angle_Euler=NaN(size(ACD,1),3);
for iframe=1:size(ACD,1)
  
    TR0_SL=[X_SL(iframe,:)' Y_SL(iframe,:)' Z_SL(iframe,:)' O_SL(iframe,:)' ; 0 0 0 1];
   Cluster_Reference=[ACD(iframe,:); MTACDM(iframe,:); MTACDB(iframe,:); MTACDL(iframe,:)];
    if sum(isnan(Cluster_Reference(:,1)))==0
        
   Registered_Data = fct_recalage(Cluster_Reference,Cluster_to_register,Cluster_to_register);   
    Z_CL=Registered_Data(1,:)-mean(Registered_Data(2:4,:)); Z_CL=Z_CL/norm(Z_CL);
    Y_CL=Registered_Data(2,:)-Registered_Data(3,:); Y_CL=Y_CL/norm(Y_CL);
    X_CL=cross(Y_CL,Z_CL);X_CL=X_CL/norm(X_CL);
    Y_CL=cross(Z_CL,X_CL);
    O_CL=Registered_Data(1,:);
    TR0_CL=[X_CL' Y_CL' Z_CL' O_CL' ; 0 0 0 1];
    
    TSL_SV=inv(TR0_SL)*TR0_CL*inv(TSL_CL);
    Angle=acosd((trace(TSL_SV(1:3,1:3))-1)*.5);
    Axe=1/(2*sind(Angle))*(TSL_SV(1:3,1:3)-TSL_SV(1:3,1:3)');
    Axe_Angle(iframe,:)=[(-Axe(2,3)+Axe(3,2))*.5 (-Axe(3,1)+Axe(1,3))*.5 (-Axe(1,2)+Axe(2,1))*.5 Angle];    
    
    Angle_Euler(iframe,:)=axemobile_xyz(TSL_SV);   
    end
end