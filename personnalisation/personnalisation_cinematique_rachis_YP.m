function model_modif=personnalisation_cinematique_rachis_YP(model,angles_lomb_EOS,angles_thor_EOS)
%% Mesure de la répartition des rotations inter-vertebrales en position statique
%lombaire
L1_x=angles_lomb_EOS(1,1);
L2_x=angles_lomb_EOS(2,1);
L3_x=angles_lomb_EOS(3,1);
L4_x=angles_lomb_EOS(4,1);
L5_x=angles_lomb_EOS(5,1);

L1_y=angles_lomb_EOS(1,2);
L2_y=angles_lomb_EOS(2,2);
L3_y=angles_lomb_EOS(3,2);
L4_y=angles_lomb_EOS(4,2);
L5_y=angles_lomb_EOS(5,2);

L1_z=angles_lomb_EOS(1,3);
L2_z=angles_lomb_EOS(2,3);
L3_z=angles_lomb_EOS(3,3);
L4_z=angles_lomb_EOS(4,3);
L5_z=angles_lomb_EOS(5,3);

%Thoraciques
T1_x=angles_thor_EOS(1,1);
T2_x=angles_thor_EOS(2,1);
T3_x=angles_thor_EOS(3,1);
T4_x=angles_thor_EOS(4,1);
T5_x=angles_thor_EOS(5,1);
T6_x=angles_thor_EOS(6,1);
T7_x=angles_thor_EOS(7,1);
T8_x=angles_thor_EOS(8,1);
T9_x=angles_thor_EOS(9,1);
T10_x=angles_thor_EOS(10,1);
T11_x=angles_thor_EOS(11,1); 
T12_x=angles_thor_EOS(12,1);

T1_y=angles_thor_EOS(1,2);
T2_y=angles_thor_EOS(2,2);
T3_y=angles_thor_EOS(3,2);
T4_y=angles_thor_EOS(4,2);
T5_y=angles_thor_EOS(5,2);
T6_y=angles_thor_EOS(6,2);
T7_y=angles_thor_EOS(7,2);
T8_y=angles_thor_EOS(8,2);
T9_y=angles_thor_EOS(9,2);
T10_y=angles_thor_EOS(10,2);
T11_y=angles_thor_EOS(11,2); 
T12_y=angles_thor_EOS(12,2);

T1_z=angles_thor_EOS(1,3);
T2_z=angles_thor_EOS(2,3);
T3_z=angles_thor_EOS(3,3);
T4_z=angles_thor_EOS(4,3);
T5_z=angles_thor_EOS(5,3);
T6_z=angles_thor_EOS(6,3);
T7_z=angles_thor_EOS(7,3);
T8_z=angles_thor_EOS(8,3);
T9_z=angles_thor_EOS(9,3);
T10_z=angles_thor_EOS(10,3);
T11_z=angles_thor_EOS(11,3); 
T12_z=angles_thor_EOS(12,3);

%% calcul des coefficients


%% Integration des coefficient dans les contraintes
%Vertebres Lombaires  (A Musculoskeletal model for the lumbar spine, M. Christophy)
%Flexion-Extension
model.Model.ConstraintSet.objects.CoordinateCouplerConstraint(17).coupled_coordinates_xfunction.PiecewiseLinearXfunction.y=[-1 0 1]; %L4_L5_FE
model.Model.ConstraintSet.objects.CoordinateCouplerConstraint(20).coupled_coordinates_xfunction.PiecewiseLinearXfunction.y=[-1 0 1]; %L3_L4_FE
model.Model.ConstraintSet.objects.CoordinateCouplerConstraint(23).coupled_coordinates_xfunction.PiecewiseLinearXfunction.y=[-1 0 1]; %L2_L3_FE
model.Model.ConstraintSet.objects.CoordinateCouplerConstraint(26).coupled_coordinates_xfunction.PiecewiseLinearXfunction.y=[-1 0 1]; %L1_L2_FE
%Lateral Bending
model.Model.ConstraintSet.objects.CoordinateCouplerConstraint(19).coupled_coordinates_xfunction.PiecewiseLinearXfunction.y=[-1 0 1]; %L4_L5_LB
model.Model.ConstraintSet.objects.CoordinateCouplerConstraint(22).coupled_coordinates_xfunction.PiecewiseLinearXfunction.y=[-1 0 1]; %L3_L4_LB
model.Model.ConstraintSet.objects.CoordinateCouplerConstraint(25).coupled_coordinates_xfunction.PiecewiseLinearXfunction.y=[-1 0 1]; %L2_L3_LB
model.Model.ConstraintSet.objects.CoordinateCouplerConstraint(28).coupled_coordinates_xfunction.PiecewiseLinearXfunction.y=[-1 0 1]; %L1_L2_LB
%Axial Rotation
model.Model.ConstraintSet.objects.CoordinateCouplerConstraint(18).coupled_coordinates_xfunction.PiecewiseLinearXfunction.y=[-1 0 1]; %L4_L5_AR
model.Model.ConstraintSet.objects.CoordinateCouplerConstraint(21).coupled_coordinates_xfunction.PiecewiseLinearXfunction.y=[-1 0 1]; %L3_L4_AR
model.Model.ConstraintSet.objects.CoordinateCouplerConstraint(24).coupled_coordinates_xfunction.PiecewiseLinearXfunction.y=[-1 0 1]; %L2_L3_AR
model.Model.ConstraintSet.objects.CoordinateCouplerConstraint(27).coupled_coordinates_xfunction.PiecewiseLinearXfunction.y=[-1 0 1]; %L1_L2_AR

%Vertebres thoraciques
%Flexion Extension
model.Model.ConstraintSet.objects.CoordinateCouplerConstraint(32).coupled_coordinates_xfunction.PiecewiseLinearXfunction.y=[-1 0 1]; %T11_T12_FE
model.Model.ConstraintSet.objects.CoordinateCouplerConstraint(33).coupled_coordinates_xfunction.PiecewiseLinearXfunction.y=[-1 0 1]; %T10_T11_FE
model.Model.ConstraintSet.objects.CoordinateCouplerConstraint(34).coupled_coordinates_xfunction.PiecewiseLinearXfunction.y=[-1 0 1]; %T9_T10_FE
model.Model.ConstraintSet.objects.CoordinateCouplerConstraint(35).coupled_coordinates_xfunction.PiecewiseLinearXfunction.y=[-1 0 1]; %T8_T9_FE
model.Model.ConstraintSet.objects.CoordinateCouplerConstraint(36).coupled_coordinates_xfunction.PiecewiseLinearXfunction.y=[-1 0 1]; %T7_T8_FE
model.Model.ConstraintSet.objects.CoordinateCouplerConstraint(37).coupled_coordinates_xfunction.PiecewiseLinearXfunction.y=[-1 0 1]; %T6_T7_FE
model.Model.ConstraintSet.objects.CoordinateCouplerConstraint(38).coupled_coordinates_xfunction.PiecewiseLinearXfunction.y=[-1 0 1]; %T5_T6_FE
model.Model.ConstraintSet.objects.CoordinateCouplerConstraint(39).coupled_coordinates_xfunction.PiecewiseLinearXfunction.y=[-1 0 1]; %T4_T5_FE
model.Model.ConstraintSet.objects.CoordinateCouplerConstraint(40).coupled_coordinates_xfunction.PiecewiseLinearXfunction.y=[-1 0 1]; %T3_T4_FE
model.Model.ConstraintSet.objects.CoordinateCouplerConstraint(41).coupled_coordinates_xfunction.PiecewiseLinearXfunction.y=[-1 0 1]; %T2_T3_FE
model.Model.ConstraintSet.objects.CoordinateCouplerConstraint(42).coupled_coordinates_xfunction.PiecewiseLinearXfunction.y=[-1 0 1]; %T1_T2_FE
%Lateral Bending
model.Model.ConstraintSet.objects.CoordinateCouplerConstraint(43).coupled_coordinates_xfunction.PiecewiseLinearXfunction.y=[-1 0 1]; %T11_T12_LB
model.Model.ConstraintSet.objects.CoordinateCouplerConstraint(44).coupled_coordinates_xfunction.PiecewiseLinearXfunction.y=[-1 0 1]; %T10_T11_LB
model.Model.ConstraintSet.objects.CoordinateCouplerConstraint(45).coupled_coordinates_xfunction.PiecewiseLinearXfunction.y=[-1 0 1]; %T9_T10_LB
model.Model.ConstraintSet.objects.CoordinateCouplerConstraint(46).coupled_coordinates_xfunction.PiecewiseLinearXfunction.y=[-1 0 1]; %T8_T9_LB
model.Model.ConstraintSet.objects.CoordinateCouplerConstraint(47).coupled_coordinates_xfunction.PiecewiseLinearXfunction.y=[-1 0 1]; %T7_T8_LB
model.Model.ConstraintSet.objects.CoordinateCouplerConstraint(48).coupled_coordinates_xfunction.PiecewiseLinearXfunction.y=[-1 0 1]; %T6_T7_LB
model.Model.ConstraintSet.objects.CoordinateCouplerConstraint(49).coupled_coordinates_xfunction.PiecewiseLinearXfunction.y=[-1 0 1]; %T5_T6_LB
model.Model.ConstraintSet.objects.CoordinateCouplerConstraint(50).coupled_coordinates_xfunction.PiecewiseLinearXfunction.y=[-1 0 1]; %T4_T5_LB
model.Model.ConstraintSet.objects.CoordinateCouplerConstraint(51).coupled_coordinates_xfunction.PiecewiseLinearXfunction.y=[-1 0 1]; %T3_T4_LB
model.Model.ConstraintSet.objects.CoordinateCouplerConstraint(52).coupled_coordinates_xfunction.PiecewiseLinearXfunction.y=[-1 0 1]; %T2_T3_LB
model.Model.ConstraintSet.objects.CoordinateCouplerConstraint(53).coupled_coordinates_xfunction.PiecewiseLinearXfunction.y=[-1 0 1]; %T1_T2_LB
%Axial Rotation
model.Model.ConstraintSet.objects.CoordinateCouplerConstraint(54).coupled_coordinates_xfunction.PiecewiseLinearXfunction.y=[-1 0 1]; %T11_T12_AR
model.Model.ConstraintSet.objects.CoordinateCouplerConstraint(55).coupled_coordinates_xfunction.PiecewiseLinearXfunction.y=[-1 0 1]; %T10_T11_AR
model.Model.ConstraintSet.objects.CoordinateCouplerConstraint(56).coupled_coordinates_xfunction.PiecewiseLinearXfunction.y=[-1 0 1]; %T9_T10_AR
model.Model.ConstraintSet.objects.CoordinateCouplerConstraint(57).coupled_coordinates_xfunction.PiecewiseLinearXfunction.y=[-1 0 1]; %T8_T9_AR
model.Model.ConstraintSet.objects.CoordinateCouplerConstraint(58).coupled_coordinates_xfunction.PiecewiseLinearXfunction.y=[-1 0 1]; %T7_T8_AR
model.Model.ConstraintSet.objects.CoordinateCouplerConstraint(59).coupled_coordinates_xfunction.PiecewiseLinearXfunction.y=[-1 0 1]; %T6_T7_AR
model.Model.ConstraintSet.objects.CoordinateCouplerConstraint(60).coupled_coordinates_xfunction.PiecewiseLinearXfunction.y=[-1 0 1]; %T5_T6_AR
model.Model.ConstraintSet.objects.CoordinateCouplerConstraint(61).coupled_coordinates_xfunction.PiecewiseLinearXfunction.y=[-1 0 1]; %T4_T5_AR
model.Model.ConstraintSet.objects.CoordinateCouplerConstraint(62).coupled_coordinates_xfunction.PiecewiseLinearXfunction.y=[-1 0 1]; %T3_T4_AR
model.Model.ConstraintSet.objects.CoordinateCouplerConstraint(63).coupled_coordinates_xfunction.PiecewiseLinearXfunction.y=[-1 0 1]; %T2_T3_AR
model.Model.ConstraintSet.objects.CoordinateCouplerConstraint(64).coupled_coordinates_xfunction.PiecewiseLinearXfunction.y=[-1 0 1]; %T1_T2_AR


%% return
model_modif=model;

end
