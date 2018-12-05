function struct_avec_FP_et_CoM=determination_plateforme_force(i_frame,pf_data,new_pf_data,marker_data,struct_appui)
list_channels=fieldnames(new_pf_data(1).channels);

%Le CoM est placé au barycentre des marqueurs utilisés
if contains(struct_appui.nom,'pied_D') || contains(struct_appui.nom,'pied_G')
    struct_appui.CoM(i_frame,:)=(marker_data.(struct_appui.marqueurs{1})(i_frame,:)+marker_data.(struct_appui.marqueurs{2})(i_frame,:)+marker_data.(struct_appui.marqueurs{3})(i_frame,:))/3;
else
    %Pour la main on place le point d'appui entre MC2 et MC5
    struct_appui.CoM(i_frame,:)=(marker_data.(struct_appui.marqueurs{1})(i_frame,:)+marker_data.(struct_appui.marqueurs{2})(i_frame,:))/2;
end

% Si un marqueur est absent, on ne peut pas conclure
if isnan(marker_data.(struct_appui.marqueurs{1})(i_frame,1)) || ...
        isnan(marker_data.(struct_appui.marqueurs{2})(i_frame,1)) || ...
        isnan(marker_data.(struct_appui.marqueurs{3})(i_frame,1))
    struct_appui.FP(i_frame)=NaN;
else
    % Pied décollé si pas de force sur aucune plateforme
    %On compare la force en z avant le changement de repère, donc si elle est positive c'est qu'il n'y a pas d'appui.
    if new_pf_data(1).channels.([list_channels{3}(1:end-1),'1'])(i_frame)>=0 && new_pf_data(2).channels.([list_channels{3}(1:end-1),'2'])(i_frame)>=0 ...
            && new_pf_data(3).channels.([list_channels{3}(1:end-1),'3'])(i_frame)>=0 && new_pf_data(4).channels.([list_channels{3}(1:end-1),'4'])(i_frame)>=0
        struct_appui.FP(i_frame)=5;
    else
        % Test des différentes plateformes
        for i_fp=1:4
            m1=struct_appui.marker_data.(struct_appui.marqueurs{1})(i_frame,1:2);
            m2=struct_appui.marker_data.(struct_appui.marqueurs{2})(i_frame,1:2);
            m3=struct_appui.marker_data.(struct_appui.marqueurs{3})(i_frame,1:2);
            rect_fp=[pf_data(i_fp).corners(1:2,1)'; pf_data(i_fp).corners(1:2,2)'; pf_data(i_fp).corners(1:2,3)'; pf_data(i_fp).corners(1:2,4)'];
            if  inpoly(m1,rect_fp) && inpoly(m2,rect_fp) && inpoly(m3,rect_fp)
                if new_pf_data(i_fp).channels.([list_channels{3}(1:end-1),num2str(i_fp)])(i_frame)<0
                    struct_appui.FP(i_frame)=i_fp;
                else
                    struct_appui.FP(i_frame)=5;
                end
            %Si on détecte un appui partiel il faut le prendre en compte pour la suite!    
            elseif inpoly(m1,rect_fp) || inpoly(m2,rect_fp) || inpoly(m3,rect_fp)
                struct_appui.FP(i_frame)=str2double(['6',num2str(i_fp)]);
            end
        end
        if struct_appui.FP(i_frame)==0 || struct_appui.FP(i_frame)==61 || struct_appui.FP(i_frame)==62 ||... 
                struct_appui.FP(i_frame)==63 || struct_appui.FP(i_frame)==64
            rect_fp_12=[pf_data(1).corners(1:2,2)'; pf_data(1).corners(1:2,3)'; pf_data(2).corners(1:2,4)'; pf_data(2).corners(1:2,1)'];
            if inpoly(m1,rect_fp_12) && inpoly(m2,rect_fp_12) && inpoly(m3,rect_fp_12)
                %Si le pied est entre les plateformes 1 et 2 il ne peut pas
                %toucher de sol
                if new_pf_data(1).channels.([list_channels{3}(1:end-1),'1'])(i_frame)<0 && ...
                        new_pf_data(2).channels.([list_channels{3}(1:end-1),'2'])(i_frame)<0
                    struct_appui.FP(i_frame)=12;
                elseif new_pf_data(1).channels.([list_channels{3}(1:end-1),'1'])(i_frame)<0 && ...
                        new_pf_data(2).channels.([list_channels{3}(1:end-1),'2'])(i_frame)>=0
                    struct_appui.FP(i_frame)=1;
                elseif new_pf_data(1).channels.([list_channels{3}(1:end-1),'1'])(i_frame)>=0 && ...
                        new_pf_data(2).channels.([list_channels{3}(1:end-1),'2'])(i_frame)<0
                    struct_appui.FP(i_frame)=2;
                end
            end
        end
    end
end

struct_avec_FP_et_CoM=struct_appui;
end