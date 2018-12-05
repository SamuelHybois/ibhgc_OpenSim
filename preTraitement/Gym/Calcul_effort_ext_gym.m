function torseur_ROS=Calcul_effort_ext_gym(st_pied_main,st_pf,M_pass_Vicon_OS,pf_info,pf_data_pour_corner,appuis,xyz_force_location,CoM)
nb_frame=size(st_pied_main.FP,2);
list_effort_init=fieldnames(st_pf(1).channels);
nb_effort=size(list_effort_init,1);
torseur(nb_frame,nb_effort+3)=0;%+3 car on va ajouter la position après la force et le moment

%% savoir quelle colonne du tableau "appuis" regarder
if st_pied_main.nom == 'pied_D'
    row=1;
elseif st_pied_main.nom == 'pied_G'
    row=2;
elseif st_pied_main.nom == 'main_D'
    row=3;
elseif st_pied_main.nom == 'main_G'
    row=4;
end
  
%% Remplir le torseur 
for i_frame=1:nb_frame
    
    %Si on n'a qu'un seul appui sur la plateforme de force
    if length(find(appuis(i_frame,row)==appuis(i_frame,:)))==1 || appuis(i_frame,row)==0 || appuis(i_frame,row)==5
        if (st_pied_main.FP(i_frame)==1 && ~ismember(12,appuis(i_frame,:)) && ~ismember(61,appuis(i_frame,:)))...
                || (st_pied_main.FP(i_frame)==2 && ~ismember(12,appuis(i_frame,:)) && ~ismember(62,appuis(i_frame,:))) ...
                || (st_pied_main.FP(i_frame)==3 && ~ismember(63,appuis(i_frame,:)))...
                || (st_pied_main.FP(i_frame)==4 && ~ismember(64,appuis(i_frame,:)))
            list_effort=fieldnames(st_pf(st_pied_main.FP(i_frame)).channels);
            for i_effort=1:size(list_effort,1)
                torseur(i_frame,i_effort)=st_pf(st_pied_main.FP(i_frame)).channels.(list_effort{i_effort})(i_frame);
            end
            torseur(i_frame,7:9)=xyz_force_location.(['FP', num2str(st_pied_main.FP(i_frame))])(i_frame,:);
        %Si l'appui est entre les fp 1 et 2 et qu'il n'y a pas d'appui sur la 1 ni la 2
        elseif st_pied_main.FP(i_frame)==12 ...
                && ~ismember(1,appuis(i_frame,:)) && ~ismember(2,appuis(i_frame,:))
            for i_effort=1:3 % on somme les efforts et on ne traite pas les moments (pour l'instant)
                torseur(i_frame,i_effort)=st_pf(1).channels.([list_effort_init{i_effort}(1:end-1),'1'])(i_frame)+st_pf(2).channels.([list_effort_init{i_effort}(1:end-1),'2'])(i_frame);
            end
        end
        
    %Si on a plusieurs appuis sur une plateforme, même partiels
    elseif ~isnan(appuis(i_frame,row)) && contains(' 1 2 3 4 ',[' ',num2str(st_pied_main.FP(i_frame)),' '])
        torseur(i_frame,:)=repartition_efforts_multi_appuis_gym(appuis,st_pf,i_frame,row,xyz_force_location,CoM);
    end
end

%% Il faut passer les forces et moments dans le repère OpenSim
torseur_ROS=RPFF_2_ROS(st_pied_main,torseur,M_pass_Vicon_OS,pf_data_pour_corner);

%% On passe les moments de Nmm à Nm si besoin
cur_unit=pf_info(1).units.Moment_Mx1; %on considère que toutes les plateformes expriment les moments dans la même unité
if strcmp(cur_unit,'Nmm')
    torseur_ROS(:,4:6)=torseur_ROS(:,4:6)/1000;
end

end