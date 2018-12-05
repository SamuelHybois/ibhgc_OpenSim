function Crunch_factor=calcul_crunch_factor(marker_R0,vit_ang,freq,arg_plot,frame_impact,dossier_sortie,cur_acquisition)

if ~exist(fullfile(dossier_sortie,'Crunch_factor'),'dir')
    mkdir(fullfile(dossier_sortie,'Crunch_factor'))
end
Crunch_factor = struct;
pt_tronc_D = (marker_R0.ACD-(marker_R0.EASD+marker_R0.EPSD)/2)/2;
pt_tronc_G = (marker_R0.ACG-(marker_R0.EASG+marker_R0.EPSG)/2)/2;
vec_tronc = pt_tronc_D-pt_tronc_G;
nb_frame = size(marker_R0.EASG,1);
angles_tronc = zeros(nb_frame,3);
vit_thorax_pelvis = zeros(nb_frame,3);
omega_axial = zeros(nb_frame,1);
omega_flexion = zeros(nb_frame,1);
theta_flexion = zeros(nb_frame,1);
for i_frame = 1:nb_frame
    angles_tronc(i_frame,:)=[atand(vec_tronc(i_frame,3)/vec_tronc(i_frame,2));...
        atand(vec_tronc(i_frame,1)/vec_tronc(i_frame,3));...
        atand(vec_tronc(i_frame,2)/vec_tronc(i_frame,1))];
    vit_thorax_pelvis(i_frame,:)=vit_ang.thorax(i_frame,:)-vit_ang.pelvis(i_frame,:);
    omega_axial(i_frame)=vit_thorax_pelvis(i_frame,2);
    omega_flexion(i_frame)=vit_thorax_pelvis(i_frame,1);
    theta_flexion(i_frame)=angles_tronc(i_frame,2);
    
end

for i_frame=2:nb_frame % Pour corriger le gimbal lock si il y en a
    for i=1:3
        if abs(theta_flexion(i_frame)-theta_flexion(i_frame-1))>170
             theta_flexion(i_frame)=theta_flexion(i_frame)-180;
        end
    end
end

for i_frame=2:nb_frame
    for i=1:3
        if abs(theta_flexion(i_frame)-theta_flexion(i_frame-1))>170
             theta_flexion(i_frame)= theta_flexion(i_frame)-180;
        end
    end
end

Crunch_factor.Methode1=omega_axial.*theta_flexion;
Crunch_factor.Methode2=omega_flexion.*omega_axial;

if arg_plot==1
    
    nom_final=[];
    nom_sortie=strsplit(cur_acquisition(1:end-4),'_');
    for i=1:length(nom_sortie)-1
        nom_final=[nom_final,nom_sortie{i},' '];
    end
    nom_final=[nom_final,nom_sortie{end}];
    
    time=1/freq:1/freq:nb_frame/freq;
    time=time - (frame_impact)/200;
    fig1=figure('Name','Crunch Factor méthode 1','NumberTitle','off','visible','off');
    plot(time,Crunch_factor.Methode1)
    Y=ylim;
    line(repmat((frame_impact)/200,1,abs(Y(2)-Y(1))),(Y(1)+1):Y(2),'Color','black','LineStyle',':')
    legend('Crunch Factor','Location','Southwest')
    xlabel('Time (s)')
    ylabel('Crunch Factor (°²/s)')
    title(['Crunch Factor (Speed*Angle) for ',nom_final])
    fig2=figure('Name','Crunch Factor méthode 2','NumberTitle','off','visible','off');
    plot(time,Crunch_factor.Methode2)
    ylabel('Crunch Factor (°²/s²)')
    legend('Crunch Factor', 'Location','Southwest')
    title(['Crunch Factor (Speed*Speed) for ',nom_final])
    Y=ylim;
    line(repmat((frame_impact)/200,1,abs(Y(2)-Y(1))),(Y(1)+1):Y(2),'Color','black','LineStyle',':')
    %     filename_fig1=fullfile(dossier_sortie,'Crunch_factor',['Crunch_factor_methode_1',nom_final,'.fig']);
    filename_jpg1=fullfile(dossier_sortie,'Crunch_factor',['Crunch_factor_methode_1',nom_final,'.jpg']);
%     filename_fig2=fullfile(dossier_sortie,'Crunch_factor',['Crunch_factor_methode_2',nom_final,'.fig']);
    filename_jpg2=fullfile(dossier_sortie,'Crunch_factor',['Crunch_factor_methode_2',nom_final,'.jpg']);
    %     savefig(fig1,filename_fig1)
    saveas(fig1,filename_jpg1)
    %     savefig(fig2,filename_fig2)
    saveas(fig2,filename_jpg2)
end


end