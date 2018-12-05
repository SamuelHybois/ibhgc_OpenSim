function [Torseur_ROS]  = RPFF_2_ROS(st_pied_main,torseur,M_R0R1,forceplatesCorners)
%Code pour changer les repère d'expression des forces et moments mesurés. 
%M_R0R1 : matrice de rotation (3*3) de ROS dans RVicon

%On regarde quelles plateformes sont utilisees par cet appui
list_used_fp={};
for i=1:4
   if ismember(i,st_pied_main.FP)
       list_used_fp{end+1}=num2str(i);
   end
end

%% définition des repères plate-forme nécessaires dans RVicon
for i_list_fp=1:size(list_used_fp,2)
    numPFF=str2num(list_used_fp{i_list_fp});

    try
        Corners = forceplatesCorners(str2double(numPFF)).corners;
        Origin = forceplatesCorners(str2double(numPFF)).origin;
    catch
        Corners = forceplatesCorners(numPFF).corners;
        Origin = forceplatesCorners(numPFF).origin;
    end
    Centre_Corner = mean(Corners,2);
    X = Corners(:,1)-Corners(:,2); X=X/norm(X);
    Y = Corners(:,2)-Corners(:,3); Y=Y/norm(Y);
    Z = cross(X,Y);
    O = Centre_Corner - Origin;
    
    Nom_reperes={['PFF',num2str(numPFF)]};
    MH_RVicon_RPFF.(Nom_reperes{1}) = [X,Y,Z,O;0,0,0,1]; 
    MH_ROS_RPFF.(Nom_reperes{1}) = [M_R0R1,[0,0,0]';0,0,0,1]\MH_RVicon_RPFF.(Nom_reperes{1});

end

%% Passage dans repère OS
Force_PFF_ROS=[];
Moment_PFF_ROS=[];
i_frame=1;

while i_frame<size(torseur,1)+1 %On utilise un while pour pouvoir traiter plusieurs données en même temps et donner la valeur que l'on veut à i_frame en fin de boucle
    cur_fp=st_pied_main.FP(i_frame);
    if ~isnan(cur_fp)
        cur_repere={['PFF',num2str(cur_fp)]};
    end
    start_frame=i_frame;
    end_frame=i_frame;
    
    while (st_pied_main.FP(end_frame)==st_pied_main.FP(i_frame) && end_frame<size(torseur,1)) || (isnan(st_pied_main.FP(end_frame)) && isnan(st_pied_main.FP(i_frame)) && end_frame<size(torseur,1))
        end_frame=end_frame+1;
    end

    if end_frame==size(torseur,1) %Si on atteint la dernière frame il faut faire un ajustement dans les index 
        end_frame=end_frame+1;
    end
        
    if cur_fp==1 || cur_fp==2 || cur_fp==3 ||cur_fp==4
        force = (MH_ROS_RPFF.(cur_repere{1})(1:3,1:3)*[torseur(start_frame:end_frame-1,1),torseur(start_frame:end_frame-1,2),torseur(start_frame:end_frame-1,3)]')';

%         % on lisse les données
%         for i =1:3
%             force(start_frame:end_frame-1,i) = fct_moyenne_glissante(force(start_frame:end_frame-1,i),3);
%             end
%         end

        Force_PFF_ROS=cat(1,Force_PFF_ROS,force);
        
        % moment dans la base de ROS mais pas de changement d'origine
        moment = (MH_ROS_RPFF.(cur_repere{1})(1:3,1:3)*[torseur(start_frame:end_frame-1,4),torseur(start_frame:end_frame-1,5),torseur(start_frame:end_frame-1,6)]')';
        Moment_PFF_ROS=cat(1,Moment_PFF_ROS,moment);
        
%         % on lisse les données
%             moment(start_frame:end_frame-1,i) = fct_moyenne_glissante(moment(start_frame:end_frame-1,i),3);
%             end
%         end

        % expression des moments à l'origine de ROS et dans la base de ROS
%         O_OS = MH_ROS_RPFF.(cur_repere{1})(1:3,4);
%         Mskew = [0, -O_OS(3), O_OS(2); O_OS(3),0,-O_OS(1); -O_OS(2), O_OS(1),0];
%         Moment_PFF_ROS = cat(1,Moment_PFF_ROS ,(moment' + Mskew * Force_PFF_ROS(start_frame:end,:)')');
        
        elseif cur_fp==12 %Si on est entre la 1 et la 2 on passe la force dans le bon repère (le moment n'est pas calculé pour l'instant)
        force = (MH_ROS_RPFF.PFF1(1:3,1:3)*[torseur(start_frame:end_frame-1,1),torseur(start_frame:end_frame-1,2),torseur(start_frame:end_frame-1,3)]')';
        Force_PFF_ROS=cat(1,Force_PFF_ROS,force);
        Moment_PFF_ROS = cat(1,Moment_PFF_ROS,torseur(start_frame:end_frame-1,4:6));
        
    else %Si le pied ou la main n'est pas sur une plateforme
        Force_PFF_ROS = cat(1,Force_PFF_ROS,torseur(start_frame:end_frame-1,1:3));
        Moment_PFF_ROS = cat(1,Moment_PFF_ROS,torseur(start_frame:end_frame-1,4:6));

        
    end
    if i_frame==end_frame
        i_frame=end_frame+1;
    else
        i_frame=end_frame;
    end
end

Torseur_ROS = [Force_PFF_ROS, Moment_PFF_ROS, torseur(:,7:9)];
end