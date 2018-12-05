[Moment_abduction_seth,Moment_internalrotation_seth,Moment_flexion_seth] = Calcul_Dyn_Inv(rep_global_seth,my_sujet,my_activity);
[Moment_abduction_holzbaur,Moment_internalrotation_holzbaur,Moment_flexion_holzbaur] = Calcul_Dyn_Inv(rep_global_holzbaur,my_sujet,my_activity);
[Moment_abduction_locked,Moment_internalrotation_locked,Moment_flexion_locked] = Calcul_Dyn_Inv(rep_global_locked,my_sujet,my_activity);

figure ;

subplot(1,2,1)
plot(Moment_flexion_seth)
hold on
plot(Moment_flexion_holzbaur)
plot(Moment_flexion_locked)
xlabel('Propulsion cycle (%)')
ylabel('Flexion moment (Nm)')

subplot(1,2,2)
plot(Moment_internalrotation_seth)
hold on
plot(Moment_internalrotation_holzbaur)
plot(Moment_internalrotation_locked)
xlabel('Propulsion cycle (%)')
ylabel('Endorotation moment (Nm)')