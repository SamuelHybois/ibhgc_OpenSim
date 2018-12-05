function X_factor=calcul_x_factor(Struct_mrk,nb_frame,freq,arg_plot,frame_impact,frame_down,dossier_sortie,cur_acquisition)
if ~exist(fullfile(dossier_sortie,'X_factor'),'dir')
    mkdir(fullfile(dossier_sortie,'X_factor'))
end
X_factor=struct;
for i_frame=1:nb_frame
    vec_epaules(i_frame,:)=Struct_mrk.ACD(i_frame,:)-Struct_mrk.ACG(i_frame,:);
    vec_pelvis(i_frame,:)=(Struct_mrk.EPSD(i_frame,:)+Struct_mrk.EASD(i_frame,:))/2-(Struct_mrk.EPSG(i_frame,:)+Struct_mrk.EASD(i_frame,:))/2;
    angle_pelvis(i_frame,1)=atand(vec_pelvis(i_frame,3)/vec_pelvis(i_frame,2));
    angle_pelvis(i_frame,2)=atand(vec_pelvis(i_frame,1)/vec_pelvis(i_frame,3));
    angle_pelvis(i_frame,3)=atand(vec_pelvis(i_frame,2)/vec_pelvis(i_frame,1));
    angle_epaules(i_frame,1)=atand(vec_epaules(i_frame,3)/vec_epaules(i_frame,2));
    angle_epaules(i_frame,2)=atand(vec_epaules(i_frame,1)/vec_epaules(i_frame,3));
    angle_epaules(i_frame,3)=atand(vec_epaules(i_frame,2)/vec_epaules(i_frame,1));
    X_factor.epaules_pelvis(i_frame,:)=angle_epaules(i_frame,:)-angle_pelvis(i_frame,:);

    pt_D_torse(i_frame,:)=(Struct_mrk.ACD(i_frame,:)+(Struct_mrk.EASD(i_frame,:)+Struct_mrk.EPSD(i_frame,:))/2)/2;
    pt_G_torse(i_frame,:)=(Struct_mrk.ACG(i_frame,:)+(Struct_mrk.EASG(i_frame,:)+Struct_mrk.EPSG(i_frame,:))/2)/2;
    vec_torse(i_frame,:)=pt_D_torse(i_frame,:)-pt_G_torse(i_frame,:);
    angle_torse(i_frame,1)=atand(vec_torse(i_frame,3)/vec_torse(i_frame,2));
    angle_torse(i_frame,2)=atand(vec_torse(i_frame,1)/vec_torse(i_frame,3));
    angle_torse(i_frame,3)=atand(vec_torse(i_frame,2)/vec_torse(i_frame,1));
    X_factor.torse_pelvis(i_frame,:)=angle_torse(i_frame,:)-angle_pelvis(i_frame,:);    

end
X_factor.debut.torse_pelvis=X_factor.torse_pelvis(1,:);
X_factor.debut.epaules_pelvis=X_factor.epaules_pelvis(1,:);
for i_frame=1:nb_frame
    X_factor.torse_pelvis(i_frame,:)=X_factor.torse_pelvis(i_frame,:)-X_factor.torse_pelvis(1,:);
    X_factor.epaules_pelvis(i_frame,:)=X_factor.epaules_pelvis(i_frame,:)-X_factor.epaules_pelvis(1,:);
end

for i_frame=2:nb_frame % Pour corriger le gimbal lock si il y en a
    for i=1:3
        if abs(X_factor.epaules_pelvis(i_frame,i)-X_factor.epaules_pelvis(i_frame-1,i))>170
             X_factor.epaules_pelvis(i_frame,i)= X_factor.epaules_pelvis(i_frame,i)-180;
        end
    end
end

for i_frame=2:nb_frame
    for i=1:3
        if abs(X_factor.torse_pelvis(i_frame,i)-X_factor.torse_pelvis(i_frame-1,i))>170
             X_factor.torse_pelvis(i_frame,i)= X_factor.torse_pelvis(i_frame,i)-180;
        end
    end
end

if arg_plot==1
    time=1/freq:1/freq:nb_frame/freq;
    time=time - (frame_impact)/200;
    nom_final=[];
    nom_sortie=strsplit(cur_acquisition(1:end-4),'_');
    for i=1:length(nom_sortie)-1
        nom_final=[nom_final,nom_sortie{i},' '];
    end
    nom_final=[nom_final,nom_sortie{end}];
    
    fig1=figure('Name','X-factor entre les épaules et le pelvis','NumberTitle','off','visible','off');
    hold on
    %         plot(time,X_factor.epaules_pelvis(:,1))
    plot(time,X_factor.epaules_pelvis(:,2))
    %         plot(time,X_factor.epaules_pelvis(:,3))
    %     plot(time,norm_X_factor1)
    xlabel('Time (s)')
    ylabel('X-factor (°)')
    legend('X-factor (Vertical)','location','NorthWest')
    Y=ylim;
    line(repmat((-frame_down)/200,1,abs(Y(2)-Y(1))),(Y(1)+1):Y(2),'Color','black','LineStyle',':')
    line(zeros(1,abs(Y(2)-Y(1))),(Y(1)+1):Y(2),'Color','black','LineStyle',':')
    title(['X-factor between the shoulders and the pelvis for ',nom_final])
    %     legend('X-factor selon X','X-factor selon Y','X-factor selon Z')
%     filename_fig=fullfile(dossier_sortie,'X_factor',['X_factor_epaules_pelvis_',nom_final,'.fig']);
    filename_jpg=fullfile(dossier_sortie,'X_factor',['X_factor_epaules_pelvis_',nom_final,'.jpg']);
%     savefig(fig1,filename_fig)
    saveas(fig1,filename_jpg)
    
    fig2=figure('Name','X-factor entre le torse et le pelvis','NumberTitle','off','visible','off');
    hold on
    %         plot(time,X_factor.torse_pelvis(:,1))
    plot(time,X_factor.torse_pelvis(:,2))
    %         plot(time,X_factor.torse_pelvis(:,3))
    %     plot(time,norm_X_factor2)
    xlabel('Time (s)')
    ylabel('X-factor (°)')
    legend('X-factor (Vertical)','location','NorthWest')
    title(['X-factor between the thorax and the pelvis for ',nom_final])
    Y=ylim;
    line(repmat((frame_impact)/200,1,abs(Y(2)-Y(1))),(Y(1)+1):Y(2),'Color','black','LineStyle',':')
%     text(frame_impact/200-0.05,-0.02*Y(2),'Impact')
    %     legend('X-factor selon X','X-factor selon Y','X-factor selon Z','location','NorthWest')
%     filename_fig=fullfile(dossier_sortie,'X_factor',['X_factor_torse_pelvis_',nom_final,'.fig']);
    filename_jpg=fullfile(dossier_sortie,'X_factor',['X_factor_torse_pelvis_',nom_final,'.jpg']);
%     savefig(fig2,filename_fig)
    saveas(fig2,filename_jpg)
    
    %     figure('Name','angles pelvis','NumberTitle','off')
    %     plot(time,angle_pelvis)
    %     figure('Name','angles epaules','NumberTitle','off')
    %     plot(time,angle_epaules)
    %     figure('Name','angles torse','NumberTitle','off')
    %     plot(time,angle_torse)
end
end
