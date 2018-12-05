function seq=calcul_sequence_cine(vit_ang,list_seg,frame_impact,frame_down,arg_plot,dossier_sortie,cur_acquisition)

if ~exist(fullfile(dossier_sortie,'Sequence'),'dir')
    mkdir(fullfile(dossier_sortie,'Sequence'))
end

vit_max=struct;
norm_vit_ang=struct;
frame_impact=round(frame_impact);
frame_down=round(frame_down);
for i_seg=1:size(list_seg,2)
    for i_frame=frame_down:frame_impact
        norm_vit_ang.(list_seg{i_seg})(i_frame-frame_down+1)=norm(vit_ang.(list_seg{i_seg})(i_frame,:));
    end
    max_seg = (1:size(norm_vit_ang.(list_seg{i_seg}),2));
    max_seg = max_seg(norm_vit_ang.(list_seg{i_seg})==max(norm_vit_ang.(list_seg{i_seg})));
    vit_max.(list_seg{i_seg})=max_seg;
end

maximums=struct2cell(vit_max);
[~,ordre]=sort([maximums{1:size(maximums,1)}]);
seq{1,1}='Les segments sont rangés par ordre croissant de maximum de vitesse';

for i_segment=1:size(list_seg,2)
    seq{2,i_segment}=list_seg{ordre(i_segment)};
end

if arg_plot==1
    fig=figure('Name','Vitesses pour les séquences cinématiques','NumberTitle','off','visible','off');
    hold on
    time=frame_down/200:1/200:(frame_impact)/200;
    time=time - (frame_down)/200;
    
    nom_final=[];
    nom_sortie=strsplit(cur_acquisition(1:end-4),'_');
    for i=1:length(nom_sortie)-1
        nom_final=[nom_final,nom_sortie{i},' '];
    end
    nom_final=[nom_final,nom_sortie{end}];
    
    for i_seg=1:size(list_seg,2)
        plot(time,norm_vit_ang.(list_seg{i_seg}))
    end
    xlabel('Time (s)')
    ylabel('Norm of the Rotational Speed (°/s)')
    title(['Kinematic sequence for ',nom_final])
    Y=ylim;
    X=xlim;
    line(repmat((frame_impact-1-frame_down)/200,1,Y(2)),(Y(1)+1):Y(2),'Color','black','LineStyle',':')
    text(frame_impact/200-0.05,-0.02*Y(2),'Impact')
    legend(list_seg,'location','NorthWest')
    sequence='Séquence : ';
    for i_seq=1:size(seq,2)-1
        sequence=strcat(sequence,seq{2,i_seq},' > ');
    end
    sequence=strcat(sequence,seq{2,end});
    text(-0.1*X(1),-0.1*Y(2),sequence)

%     filename_fig=fullfile(dossier_sortie,'Sequence',['Sequence_cinematique_',nom_final,'.fig']);
    filename_jpg=fullfile(dossier_sortie,'Sequence',['Sequence_cinematique_',nom_final,'.jpg']);
%     savefig(fig,filename_fig);
    saveas(fig,filename_jpg)
end
end
