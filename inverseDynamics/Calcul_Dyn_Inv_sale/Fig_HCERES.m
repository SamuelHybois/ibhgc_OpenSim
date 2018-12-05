rep_global = 'E:\FRM_Manip2017\modele_classique_seth' ;
my_sujet = 'AM01SD' ;
time_int = linspace(0,100,100) ;
[Moment_abduction,Moment_internalrotation,Moment_flexion] = Calcul_Dyn_Inv(rep_global,my_sujet,'Propulsion_Synchrone') ;
[Moment_abduction_SU,Moment_internalrotation_SU,Moment_flexion_SU] = Calcul_Dyn_Inv(rep_global,my_sujet,'Demarrage_Synchrone');

time_ini_seth = linspace(0,100,145);
Moment_flexion_norm = interp1(time_ini_seth(1:length(Moment_flexion)),Moment_flexion,time_int,'spline') ;
Moment_flexion_SU_norm = interp1(time_ini_seth(1:length(Moment_flexion_SU)),Moment_flexion_SU,time_int,'spline') ;

figure ;
plot(Moment_flexion_norm)
hold on
plot(Moment_flexion_SU_norm)
legend('Propulsion','Démarrage')
xlabel('Cycle de locomotion (%)')
ylabel('Moment de flexion de l''épaule (Nm)')