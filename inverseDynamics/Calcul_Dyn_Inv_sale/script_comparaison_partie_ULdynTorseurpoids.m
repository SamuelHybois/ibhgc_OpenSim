% Comparaison accélérations modèle Seth / Holzbaur
% figure ;
% plot(Dyn_UL_Rthorax_col(:,6)); hold on ; plot(Torseur_Poids_UL_Rthorax_col(:,6)) ; plot(Torseur_Effort_MC_Rthorax_col(:,6))
% legend('Dynamique segments','Poids','Transport')

DYN_main = Mat2D_2_MH(Dyn_main_Rthorax,'dynamique',-1);
DYN_ulna = Mat2D_2_MH(Dyn_ulna_Rthorax,'dynamique',-1);
DYN_radius = Mat2D_2_MH(Dyn_radius_Rthorax,'dynamique',-1);
DYN_humerus = Mat2D_2_MH(Dyn_humerus_Rthorax,'dynamique',-1);

figure ;
plot(DYN_main(:,6))
hold on
plot(DYN_ulna(:,6))
plot(DYN_radius(:,6))
plot(DYN_humerus(:,6))
legend('Main','Ulna','Radius','Humerus')
title('Dynamique')

PDS_main = Mat2D_2_MH(Torseur_Poids_main_Rthorax,'dynamique',-1);
PDS_ulna = Mat2D_2_MH(Torseur_Poids_ulna_Rthorax,'dynamique',-1);
PDS_radius = Mat2D_2_MH(Torseur_Poids_radius_Rthorax,'dynamique',-1);
PDS_humerus = Mat2D_2_MH(Torseur_Poids_humerus_Rthorax,'dynamique',-1);

figure ;
plot(PDS_main(:,6))
hold on
plot(PDS_ulna(:,6))
hold on
plot(PDS_radius(:,6))
hold on
plot(PDS_humerus(:,6))
legend('Main','Ulna','Radius','Humerus')
title('Torseur poids')