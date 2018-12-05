function [ Bodies ] = attribution_nom_visualisation_OS_fullbody( folder_geo,cur_sujet )
% Maxime Bourgain
% 13/12/2016
% table des correspondances EOS / OpenSim


%MAJ pour fullbody avec ssacrum dissocié (étonnant comme principe mais
%bon..) 28/09/2017
%% ground
Bodies.ground={};

%% bassin
geo_OS_bassin{1}='r_pelvis.vtp';
geo_OS_bassin{2}='l_pelvis.vtp';
% geo_OS_bassin{3}='sacrum.vtp';
geo_EOS_bassin{1}=[cur_sujet '_Bassin.stl'];
[Bodies.pelvis]=association_EOS_OS(folder_geo,geo_EOS_bassin,geo_OS_bassin);

%% Sacrum
geo_OS_sacrum{1}='sacrum.vtp';
geo_EOS_sacrum{1}='';
[Bodies.sacrum]=association_EOS_OS(folder_geo,geo_EOS_bassin,geo_OS_bassin);

%% femur droit
geo_OS_femur_r{1}='femur_r.vtp';
geo_EOS_femur_r{1}=[cur_sujet '_FemurD.stl'];
[Bodies.femur_r]=association_EOS_OS(folder_geo,geo_EOS_femur_r,geo_OS_femur_r);

%% fémur gauche
geo_OS_femur_l{1}='femur_l.vtp';
geo_EOS_femur_l{1}=[cur_sujet '_FemurG.stl'];
[Bodies.femur_l]=association_EOS_OS(folder_geo,geo_EOS_femur_l,geo_OS_femur_l);

%% Tibia et Fibula Droit
geo_OS_tibia_r{1}='tibia_r.vtp';
geo_OS_tibia_r{2}='fibula_r.vtp';
geo_EOS_tibia_r{1}=[cur_sujet '_TibiaD.stl'];
geo_EOS_tibia_r{2}=[cur_sujet '_PeroneD.stl'];
[Bodies.tibia_r]=association_EOS_OS(folder_geo,geo_EOS_tibia_r,geo_OS_tibia_r);

%% Tibia et Fibula Gauche
geo_OS_tibia_l{1}='tibia_l.vtp';
geo_OS_tibia_l{2}='fibula_l.vtp';
geo_EOS_tibia_l{1}=[cur_sujet '_TibiaG.stl'];
geo_EOS_tibia_l{2}=[cur_sujet '_PeroneG.stl'];
[Bodies.tibia_l]=association_EOS_OS(folder_geo,geo_EOS_tibia_l,geo_OS_tibia_l);

%% Lombaires

geo_OS_L1{1}='lumbar1.vtp';
geo_EOS_L1{1}=[cur_sujet '_Vertebre_L1.stl'];
[Bodies.lumbar1]=association_EOS_OS(folder_geo,geo_EOS_L1,geo_OS_L1);

geo_OS_L2{1}='lumbar2.vtp';
geo_EOS_L2{1}=[cur_sujet '_Vertebre_L2.stl'];
[Bodies.lumbar2]=association_EOS_OS(folder_geo,geo_EOS_L2,geo_OS_L2);

geo_OS_L3{1}='lumbar3.vtp';
geo_EOS_L3{1}=[cur_sujet '_Vertebre_L3.stl'];
[Bodies.lumbar3]=association_EOS_OS(folder_geo,geo_EOS_L3,geo_OS_L3);

geo_OS_L4{1}='lumbar4.vtp';
geo_EOS_L4{1}=[cur_sujet '_Vertebre_L4.stl'];
[Bodies.lumbar4]=association_EOS_OS(folder_geo,geo_EOS_L4,geo_OS_L4);

geo_OS_L5{1}='lumbar5.vtp';
geo_EOS_L5{1}=[cur_sujet '_Vertebre_L5.stl'];
[Bodies.lumbar5]=association_EOS_OS(folder_geo,geo_EOS_L5,geo_OS_L5);

%% cervicales
geo_EOS_C1{1}=[cur_sujet '_Vertebre_C1.stl'];
geo_OS_C1{1}='cerv1.vtp';
[Bodies.cerv_1]=association_EOS_OS(folder_geo,geo_EOS_C1,geo_OS_C1);

geo_EOS_C2{1}=[cur_sujet '_Vertebre_C2.stl'];
geo_OS_C2{1}='cerv2.vtp';
[Bodies.cerv_2]=association_EOS_OS(folder_geo,geo_EOS_C2,geo_OS_C2);

geo_EOS_C3{1}=[cur_sujet '_Vertebre_C3.stl'];
geo_OS_C3{1}='cerv3.vtp';
[Bodies.cerv_3]=association_EOS_OS(folder_geo,geo_EOS_C3,geo_OS_C3);

geo_EOS_C4{1}=[cur_sujet '_Vertebre_C4.stl'];
geo_OS_C4{1}='cerv4.vtp';
[Bodies.cerv_4]=association_EOS_OS(folder_geo,geo_EOS_C4,geo_OS_C4);

geo_EOS_C5{1}=[cur_sujet '_Vertebre_C5.stl'];
geo_OS_C5{1}='cerv5.vtp';
[Bodies.cerv_5]=association_EOS_OS(folder_geo,geo_EOS_C5,geo_OS_C5);

geo_EOS_C6{1}=[cur_sujet '_Vertebre_C6.stl'];
geo_OS_C6{1}='cerv6.vtp';
[Bodies.cerv_6]=association_EOS_OS(folder_geo,geo_EOS_C6,geo_OS_C6);

geo_EOS_C7{1}=[cur_sujet '_Vertebre_C7.stl'];
geo_OS_C7{1}='cerv7.vtp';
[Bodies.cerv_7]=association_EOS_OS(folder_geo,geo_EOS_C7,geo_OS_C7);


%% thorax
Bodies.thorax{1}='thorax.vtp';
geo_EOS_T1{1}=[cur_sujet '_Vertebre_T1.stl'];
% on fait l'hypothèse que si le wrl de la première vertèbre thoracique
% existe, alors tous les wrl sont présents.
% Les cotes sont celles par défaut.

if exist(fullfile(folder_geo,geo_EOS_T1{1}),'file')~=0
    Bodies.thorax{1}=[cur_sujet '_Vertebre_T1.stl'];
    Bodies.thorax{2}=[cur_sujet '_Vertebre_T2.stl'];
    Bodies.thorax{3}=[cur_sujet '_Vertebre_T3.stl'];
    Bodies.thorax{4}=[cur_sujet '_Vertebre_T4.stl'];
    Bodies.thorax{5}=[cur_sujet '_Vertebre_T5.stl'];
    Bodies.thorax{6}=[cur_sujet '_Vertebre_T6.stl'];
    Bodies.thorax{7}=[cur_sujet '_Vertebre_T7.stl'];
    Bodies.thorax{8}=[cur_sujet '_Vertebre_T8.stl'];
    Bodies.thorax{9}=[cur_sujet '_Vertebre_T9.stl'];
    Bodies.thorax{10}=[cur_sujet '_Vertebre_T10.stl'];
    Bodies.thorax{11}=[cur_sujet '_Vertebre_T11.stl'];
    Bodies.thorax{12}=[cur_sujet '_Vertebre_T12.stl'];
    Bodies.thorax{13}='thorax.vtp';
else
    Bodies.thorax{1}='thoracic1_s.vtp';
    Bodies.thorax{2}='thoracic2_s.vtp';
    Bodies.thorax{3}='thoracic3_s.vtp';
    Bodies.thorax{4}='thoracic4_s.vtp';
    Bodies.thorax{5}='thoracic5_s.vtp';
    Bodies.thorax{6}='thoracic6_s.vtp';
    Bodies.thorax{7}='thoracic7_s.vtp';
    Bodies.thorax{8}='thoracic8_s.vtp';
    Bodies.thorax{9}='thoracic9_s.vtp';
    Bodies.thorax{10}='thoracic10_s.vtp';
    Bodies.thorax{11}='thoracic11_s.vtp';
    Bodies.thorax{12}='thoracic12_s.vtp';
    Bodies.thorax{13}='thorax.vtp';
    
end


Bodies.patella_r{1}='r_patella.vtp';
Bodies.patella_l{1}='l_patella.vtp';
Bodies.talus_r{1}='talus_rv.vtp';
Bodies.talus_l{1}='talus_lv.vtp';
Bodies.calcn_r{1}='foot.vtp';
Bodies.calcn_l{1}='l_foot.vtp';
Bodies.toes_r{1}='bofoot.vtp';
Bodies.toes_l{1}='l_bofoot.vtp';
Bodies.head{1}='skull.vtp';
Bodies.jaw{1}='jaw.vtp';
Bodies.clavile_r{1}='clavicle_r.vtp';
Bodies.clavile_l{1}='clavicle_l.vtp';
Bodies.scapula_r{1}='scapula_r.vtp';
Bodies.scapula_l{1}='scapula_l.vtp';
Bodies.humerus_r{1}='humerus_r.vtp';
Bodies.humerus_l{1}='humerus_l.vtp';
Bodies.ulna_r{1}='ulna_r.vtp';
Bodies.ulna_l{1}='ulna_l.vtp';
Bodies.radius_r{1}='radius.vtp';
Bodies.radius_l{1}='radius_left_source.vtp';
Bodies.hand_r{1}='pisiform_rvs.vtp';
Bodies.hand_r{2}='lunate_rvs.vtp';
Bodies.hand_r{3}='scaphoid_rvs.vtp';
Bodies.hand_r{4}='triquetrum_rvs.vtp';
Bodies.hand_r{5}='hamate_rvs.vtp';
Bodies.hand_r{6}='capitate_rvs.vtp';
Bodies.hand_r{7}='trapezoid_rvs.vtp';
Bodies.hand_r{8}='trapezium_rvs.vtp';
Bodies.hand_r{9}='metacarpal2_rvs.vtp';
Bodies.hand_r{10}='index_proximal_rvs.vtp';
Bodies.hand_r{11}='index_medial_rvs.vtp';
Bodies.hand_r{12}='index_distal_rvs.vtp';
Bodies.hand_r{13}='metacarpal3_rvs.vtp';
Bodies.hand_r{14}='middle_proximal_rvs.vtp';
Bodies.hand_r{15}='middle_medial_rvs.vtp';
Bodies.hand_r{16}='middle_distal_rvs.vtp';
Bodies.hand_r{17}='metacarpal4_rvs.vtp';
Bodies.hand_r{18}='ring_proximal_rvs.vtp';
Bodies.hand_r{19}='ring_medial_rvs.vtp';
Bodies.hand_r{20}='ring_distal_rvs.vtp';
Bodies.hand_r{21}='metacarpal5_rvs.vtp';
Bodies.hand_r{22}='little_proximal_rvs.vtp';
Bodies.hand_r{23}='little_medial_rvs.vtp';
Bodies.hand_r{24}='little_distal_rvs.vtp';
Bodies.hand_r{25}='metacarpal1_rvs.vtp';
Bodies.hand_r{26}='thumb_proximal_rvs.vtp';
Bodies.hand_r{27}='thumb_distal_rvs.vtp';
Bodies.hand_l{1}='pisiform_lvs.vtp';
Bodies.hand_l{2}='lunate_lvs.vtp';
Bodies.hand_l{3}='scaphoid_lvs.vtp';
Bodies.hand_l{4}='triquetrum_lvs.vtp';
Bodies.hand_l{5}='hamate_lvs.vtp';
Bodies.hand_l{6}='capitate_lvs.vtp';
Bodies.hand_l{7}='trapezoid_lvs.vtp';
Bodies.hand_l{8}='trapezium_lvs.vtp';
Bodies.hand_l{9}='metacarpal2_lvs.vtp';
Bodies.hand_l{10}='index_proximal_lvs.vtp';
Bodies.hand_l{11}='index_medial_lvs.vtp';
Bodies.hand_l{12}='index_distal_lvs.vtp';
Bodies.hand_l{13}='metacarpal3_lvs.vtp';
Bodies.hand_l{14}='middle_proximal_lvs.vtp';
Bodies.hand_l{15}='middle_medial_lvs.vtp';
Bodies.hand_l{16}='middle_distal_lvs.vtp';
Bodies.hand_l{17}='metacarpal4_lvs.vtp';
Bodies.hand_l{18}='ring_proximal_lvs.vtp';
Bodies.hand_l{19}='ring_medial_lvs.vtp';
Bodies.hand_l{20}='ring_distal_lvs.vtp';
Bodies.hand_l{21}='metacarpal5_lvs.vtp';
Bodies.hand_l{22}='little_proximal_lvs.vtp';
Bodies.hand_l{23}='little_medial_lvs.vtp';
Bodies.hand_l{24}='little_distal_lvs.vtp';
Bodies.hand_l{25}='metacarpal1_lvs.vtp';
Bodies.hand_l{26}='thumb_proximal_lvs.vtp';
Bodies.hand_l{27}='thumb_distal_lvs.vtp';
Bodies.clavicle_r{1}='clavicle_r.vtp';
Bodies.clavicle_l{1}='clavicle_l.vtp';
Bodies.club{1}='Golf_Grip_Repositioned.stl';
Bodies.club{2}='Golf_Head_Repositioned.stl';
Bodies.club{3}='Golf_Shaft_Repositioned.stl';

end
