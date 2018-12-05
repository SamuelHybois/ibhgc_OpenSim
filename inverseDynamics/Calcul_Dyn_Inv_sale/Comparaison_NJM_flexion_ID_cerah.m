rep_global_seth  = 'E:\FRM_Manip2017\modele_classique_seth' ;
rep_global_holzbaur  = 'E:\FRM_Manip2017\modele_holzbaur' ;
rep_global_locked = 'E:\FRM_Manip2017\modele_locked_scapula' ;

liste_sujets = {'AM01SD','AM02SH','SA04BD','SA14AM','SA19AF','SA20MC','SP01SM','SP02DB','SP03AD','SP04CD'} ;
n_sujets = length(liste_sujets) ;
mat_res_dem(n_sujets,12)=0 ;
mat_res_prop(n_sujets,12)=0 ;

for i_suj = 1:n_sujets
    
my_sujet = liste_sujets{i_suj} ;

%% 
my_activity = 'Demarrage_Synchrone' ;

[Moment_abduction_seth,Moment_internalrotation_seth,Moment_flexion_seth] = Calcul_Dyn_Inv(rep_global_seth,my_sujet,my_activity);
[Moment_abduction_holzbaur,Moment_internalrotation_holzbaur,Moment_flexion_holzbaur] = Calcul_Dyn_Inv(rep_global_holzbaur,my_sujet,my_activity);
[Moment_abduction_locked,Moment_internalrotation_locked,Moment_flexion_locked] = Calcul_Dyn_Inv(rep_global_locked,my_sujet,my_activity);

Norm_NJM_seth = sqrt(Moment_abduction_seth.^2+Moment_internalrotation_seth.^2+Moment_flexion_seth.^2) ;
Norm_NJM_holzbaur = sqrt(Moment_abduction_holzbaur.^2+Moment_internalrotation_holzbaur.^2+Moment_flexion_holzbaur.^2) ;
Norm_NJM_locked = sqrt(Moment_abduction_locked.^2+Moment_internalrotation_locked.^2+Moment_flexion_locked.^2) ;

mat_res_dem(i_suj,1:3) = [min(Moment_flexion_seth),min(Moment_flexion_holzbaur),min(Moment_flexion_locked)];
mat_res_dem(i_suj,4:6) = [max(Moment_internalrotation_seth),max(Moment_internalrotation_holzbaur),max(Moment_internalrotation_locked)];
mat_res_dem(i_suj,7:9) = [max(Norm_NJM_seth),max(Norm_NJM_holzbaur),max(Norm_NJM_locked)] ;
mat_res_dem(i_suj,10:12) = [mean(Norm_NJM_seth),mean(Norm_NJM_holzbaur),mean(Norm_NJM_locked)] ;

% figure ;
% subplot(1,3,1)
% plot(Moment_flexion_seth,'LineWidth',2);
% hold on
% plot(Moment_flexion_holzbaur,'LineWidth',2)
% hold on
% plot(Moment_flexion_locked,'LineWidth',2)
% ylabel('Shoulder flexion moment (Nm)')
% xlabel('Timeframes')
% subplot(1,3,2)
% plot(Moment_abduction_seth,'LineWidth',2);
% hold on
% plot(Moment_abduction_holzbaur,'LineWidth',2)
% hold on
% plot(Moment_abduction_locked,'LineWidth',2)
% ylabel('Shoulder abduction moment (Nm)')
% xlabel('Timeframes')
% subplot(1,3,3)
% plot(Moment_internalrotation_seth,'LineWidth',2);
% hold on
% plot(Moment_internalrotation_holzbaur,'LineWidth',2)
% hold on
% plot(Moment_internalrotation_locked,'LineWidth',2)
% ylabel('Shoulder internal rotation moment (Nm)')
% xlabel('Timeframes')
% 
% t=suptitle('Dynamique à l''epaule - Start-up')
% h=legend('M_1','M_2','M_3','Location','SouthWest');
% set(h,'FontSize',14)
% 
% rep_fig = 'Z:\Travaux_Recherche\MMS\Publis\Article_ShoulderJoint\Fig_Shoulder_Moment' ;
% nom_fig = [my_sujet,'_',my_activity,'_CompID'] ;
% set(gcf, 'PaperUnits', 'centimeters');
% set(gcf, 'PaperPosition', [0 0 50 20]); %x_width=10cm y_width=15cm
% print(fullfile(rep_fig,nom_fig),'-dpng','-r300')
% 
% close all

%%
my_activity = 'Propulsion_Synchrone' ;

[Moment_abduction_seth,Moment_internalrotation_seth,Moment_flexion_seth] = Calcul_Dyn_Inv(rep_global_seth,my_sujet,my_activity);
[Moment_abduction_holzbaur,Moment_internalrotation_holzbaur,Moment_flexion_holzbaur] = Calcul_Dyn_Inv(rep_global_holzbaur,my_sujet,my_activity);
[Moment_abduction_locked,Moment_internalrotation_locked,Moment_flexion_locked] = Calcul_Dyn_Inv(rep_global_locked,my_sujet,my_activity);

Norm_NJM_seth = sqrt(Moment_abduction_seth.^2+Moment_internalrotation_seth.^2+Moment_flexion_seth.^2) ;
Norm_NJM_holzbaur = sqrt(Moment_abduction_holzbaur.^2+Moment_internalrotation_holzbaur.^2+Moment_flexion_holzbaur.^2) ;
Norm_NJM_locked = sqrt(Moment_abduction_locked.^2+Moment_internalrotation_locked.^2+Moment_flexion_locked.^2) ;

mat_res_prop(i_suj,1:3) = [min(Moment_flexion_seth),min(Moment_flexion_holzbaur),min(Moment_flexion_locked)];
mat_res_prop(i_suj,4:6) = [max(Moment_internalrotation_seth),max(Moment_internalrotation_holzbaur),max(Moment_internalrotation_locked)];
mat_res_prop(i_suj,7:9) = [max(Norm_NJM_seth),max(Norm_NJM_holzbaur),max(Norm_NJM_locked)] ;
mat_res_prop(i_suj,10:12) = [mean(Norm_NJM_seth),mean(Norm_NJM_holzbaur),mean(Norm_NJM_locked)] ;

% figure ;
% subplot(1,3,1)
% plot(Moment_flexion_seth,'LineWidth',2);
% hold on
% plot(Moment_flexion_holzbaur,'LineWidth',2)
% hold on
% plot(Moment_flexion_locked,'LineWidth',2)
% ylabel('Shoulder flexion moment (Nm)')
% xlabel('Timeframes')
% subplot(1,3,2)
% plot(Moment_abduction_seth,'LineWidth',2);
% hold on
% plot(Moment_abduction_holzbaur,'LineWidth',2)
% hold on
% plot(Moment_abduction_locked,'LineWidth',2)
% ylabel('Shoulder abduction moment (Nm)')
% xlabel('Timeframes')
% subplot(1,3,3)
% plot(Moment_internalrotation_seth,'LineWidth',2);
% hold on
% plot(Moment_internalrotation_holzbaur,'LineWidth',2)
% hold on
% plot(Moment_internalrotation_locked,'LineWidth',2)
% ylabel('Shoulder internal rotation moment (Nm)')
% xlabel('Timeframes')
% 
% t=suptitle('Dynamique à l''epaule - Propulsion')
% h=legend('M_1','M_2','M_3','Location','SouthWest');
% set(h,'FontSize',14)
% 
% rep_fig = 'Z:\Travaux_Recherche\MMS\Publis\Article_ShoulderJoint\Fig_Shoulder_Moment' ;
% nom_fig = [my_sujet,'_',my_activity,'_CompID'] ;
% set(gcf, 'PaperUnits', 'centimeters');
% set(gcf, 'PaperPosition', [0 0 50 20]); %x_width=10cm y_width=15cm
% print(fullfile(rep_fig,nom_fig),'-dpng','-r300')
% 
% close all


end


filename = 'E:\RESULTATS_Moments_Epaule_2.xlsx ';
sheet = 'Propulsion_Synchrone' ;
range = 'B3:M11' ;
xlswrite(filename,mat_res_prop,sheet,range)

