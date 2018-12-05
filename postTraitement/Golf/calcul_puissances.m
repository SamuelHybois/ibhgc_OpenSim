function calcul_puissances(tree,vit_ang,file_effort,Nq,dossier_sortie,cur_acquisition,freq,arg_plot,frame_impact,frame_down)

if ~exist(fullfile(dossier_sortie,'Puissances'),'dir')
    mkdir(fullfile(dossier_sortie,'Puissances'))
end

%% Chargement du fichier mot ik
List_Coordinates = fieldnames(vit_ang);
nb_frame = size(vit_ang.(List_Coordinates{1}),1);

%% Chargement du fichier mot id

efforts = load_sto_file(file_effort);
liste_efforts=fieldnames(efforts);
nb_effort=size(liste_efforts,1);

for i_effort=1:nb_effort
    nom_effort=liste_efforts(i_effort);
    if ~strcmp(nom_effort,'time')
        efforts.(char(nom_effort)) = fct_moyenne_glissante(efforts.(char(nom_effort)),11);
        
    end
end



%% Calcul puissances
[bodies,~]=extract_KinChainData_ModelOS(tree);
list_seg=fieldnames(bodies);
nb_segments=size(list_seg,1);
for i_seg=1:nb_segments
    if ~isempty(tree.Model.BodySet.objects.Body(i_seg).Joint)
        cur_moment=zeros(nb_frame,3);
        cur_seg=list_seg{i_seg};
        cur_articulation=determination_articulation_courante(tree,cur_seg);
        TypeJoint=fieldnames(tree.Model.BodySet.objects.Body(i_seg).Joint);
        if strcmpi(TypeJoint,'CustomJoint')
            for i_coord=1:3
                nom_coordinate{i_coord}=tree.Model.BodySet.objects.Body(i_seg).Joint.(char(TypeJoint)).SpatialTransform.TransformAxis(i_coord).coordinates;
                axis_coordinate{i_coord}=tree.Model.BodySet.objects.Body(i_seg).Joint.(char(TypeJoint)).SpatialTransform.TransformAxis(i_coord).axis;
                if ~isempty(nom_coordinate{i_coord})
                    nom_moment{i_coord}=[char(nom_coordinate{i_coord}),'_moment'];
                    cur_moment=cur_moment+efforts.(char(nom_moment{i_coord}))*axis_coordinate{i_coord};
                end
            end
        end
        moment.(cur_articulation.nom)=cur_moment;
        
        for i_frame=1:nb_frame
            if strcmpi(cur_articulation,'ground')
                vit_ang.(cur_articulation.parent)(i_frame,:)=[0,0,0];
            else
                vit_art.(cur_articulation.nom)(i_frame,:)=vit_ang.(cur_articulation.parent)(i_frame,:)-vit_ang.(cur_articulation.enfant)(i_frame,:);
%                 vit_art.(cur_articulation.nom)(i_frame,:)=M_Euler_R0*vit_art.(cur_articulation.nom);
            end
            Puissance.(cur_articulation.nom)(i_frame,:)=-vit_art.(cur_articulation.nom)(i_frame,:)*pi/180*moment.(cur_articulation.nom)(i_frame,:)';
            vit_proj.(cur_articulation.nom)(i_frame,:)=Nq.(cur_articulation.enfant)(:,:,i_frame)\vit_art.(cur_articulation.nom)(i_frame,:)'*pi/180;
            moment_proj.(cur_articulation.nom)(i_frame,:)=Nq.(cur_articulation.enfant)(:,:,i_frame)\moment.(cur_articulation.nom)(i_frame,:)';
            Puissance_proj.(cur_articulation.nom)(i_frame,:)=-vit_proj.(cur_articulation.nom)(i_frame,:)*moment_proj.(cur_articulation.nom)(i_frame,:)';

        end
        
    end
end
somme_jambe_g=Puissance.hip_l+Puissance.knee_l+Puissance.ankle_l;
somme_jambe_d=Puissance.hip_r+Puissance.knee_r+Puissance.ankle_r;

if arg_plot==1
    nom_final=[];
    nom_sortie=strsplit(cur_acquisition(1:end-4),'_');
    for i=1:length(nom_sortie)-1
        nom_final=[nom_final,nom_sortie{i},' '];
    end
    nom_final=[nom_final,nom_sortie{end}];
    
    time=0:1/freq:(nb_frame-1)/freq;
    time=time - (frame_impact)/200;
    fig=figure('Name',['Mechanical power of the legs for ',nom_final],'NumberTitle','off','visible','off');
    hold on
    plot(time,Puissance.hip_r,'black')
    plot(time,Puissance.knee_r,'blue')
    plot(time,Puissance.ankle_r,'red')
    plot(time,Puissance.hip_l,':black')
    plot(time,Puissance.knee_l,':blue')
    plot(time,Puissance.ankle_l,':red')
    xlabel('Time (s)')
    ylabel('Mechanical Power (W)')
    legend('Right Hip','Right Knee','Right Angkle','Left Hip','Left Knee','Left Ankle','Location','NorthWest')
    title(['Mechanical Power of the legs for ',nom_final])
    Y=ylim;
    line(zeros(1,abs(Y(2)-Y(1))),(Y(1)+1):Y(2),'Color','black','LineStyle',':')
    saveas(fig,fullfile(dossier_sortie,'Puissances',['Mechanical Power of the legs for ',nom_final,'.jpg']),'jpg')
    
        fig=figure('Name',['Mechanical power of the legs for ',nom_final],'NumberTitle','off','visible','off');
    hold on
    plot(time,somme_jambe_g,'black')
    plot(time,somme_jambe_d,':black')
    xlabel('Time (s)')
    ylabel('Sum of Mechanical Power (W)')
    legend('Left Leg','Right Leg','Location','NorthWest')
    title(['Mechanical Power of the legs for ',nom_final])
    Y=ylim;
    line(zeros(1,abs(Y(2)-Y(1))),(Y(1)+1):Y(2),'Color','black','LineStyle',':')
    saveas(fig,fullfile(dossier_sortie,'Puissances',['Sum of the Mechanical Power of the legs for ',nom_final,'.jpg']),'jpg')
    
%     figure('Name','Moments')
%     hold on
%     plot(time,moment.hip_r(:,1),'black')
%     plot(time,moment.hip_r(:,2),'blue')
%     plot(time,moment.hip_r(:,3),'red')
%     plot(time,moment.hip_l(:,1),':black')
%     plot(time,moment.hip_l(:,2),':blue')
%     plot(time,moment.hip_l(:,3),':red')
%     xlabel('Time (s)')
%     ylabel('Moment (N.m)')
%     Y=ylim;
%     line(repmat((frame_impact)/200,1,abs(Y(2)-Y(1))),(Y(1)+1):Y(2),'Color','black','LineStyle',':')
%     legend('Hanche droite X','Hanche droite Y','Hanche droite Z','Hanche gauche X','Hanche gauche Y','Hanche gauche Z')
%     
%     figure('Name','Vitesses')
%     hold on
%     plot(time,vit_art.hip_r(:,1),'black')
%     plot(time,vit_art.hip_r(:,2),'blue')
%     plot(time,vit_art.hip_r(:,3),'red')
%     plot(time,vit_art.hip_l(:,1),':black')
%     plot(time,vit_art.hip_l(:,2),':blue')
%     plot(time,vit_art.hip_l(:,3),':red')
%     xlabel('Time (s)')
%     ylabel('Vitesses (°/s)')
%     Y=ylim;
%     line(repmat((frame_impact)/200,1,abs(Y(2)-Y(1))),(Y(1)+1):Y(2),'Color','black','LineStyle',':')
%     legend('Hanche droite X','Hanche droite Y','Hanche droite Z','Hanche gauche X','Hanche gauche Y','Hanche gauche Z')


    
end
end


