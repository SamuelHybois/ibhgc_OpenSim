%%
function affichage_muscles_wraps(frame,Struct_muscles_points,struct_muscle_wraps,Struct_wraps_pts)
%Affichage des muscles et des wraps pour une frame
%
f=frame;
%% 4) Relier les points
muscles = fieldnames(Struct_muscles_points);
grp_plots = struct;
grp_plots_w = struct;
for i_muscles = 1:length(muscles)
    cur_muscle = muscles{i_muscles};
    pts_muscle = Struct_muscles_points.(cur_muscle);
    clear cmpt_plot
    cmpt_plot=1;
    cmpt_plot2=1;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Affichage des wraps correspondant au muscle (i_muscles)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if isfield(struct_muscle_wraps,cur_muscle) % S'il y a des wraps pour ce muscle
        % On les affiches
        cur_wraps = struct_muscle_wraps.(cur_muscle);
        % On cache ceux qui ne concerne pas le muscle
        CacherTout(grp_plots_w);
        
        for i_ww=1:length(cur_wraps)
            clear xyz xyz_inR0
            clear XX YY ZZ
            clear s
            clear X Y Z
            clear R L
            if strcmp(cur_wraps(i_ww).type,'WrapEllipsoid')
                R=cur_wraps(i_ww).Geometry.Rayons;
                [X,Y,Z]=ellipsoid(0,0,0,R(1),R(2),R(3),30);
                [s]=size(X);
                xyz(:,1)=X(:);
                xyz(:,2)=Y(:);
                xyz(:,3)=Z(:);
                xyz(:,4)=1;
                
                xyz_inR0=(cur_wraps(i_ww).MH_R0_Rw(:,:,1)* xyz')';
                [I,J]=ind2sub(s,1:length(xyz(:,1)));
                for ij=1:length(xyz(:,1))
                    XX(I(ij),J(ij))=xyz_inR0(ij,1);
                    YY(I(ij),J(ij))=xyz_inR0(ij,2);
                    ZZ(I(ij),J(ij))=xyz_inR0(ij,3);
                end
                grp_plots_w.(cur_wraps(i_ww).Nom){cmpt_plot2,1}=surf(XX,YY,ZZ,'FaceAlpha',0.5);
                grp_plots_w.(cur_wraps(i_ww).Nom){cmpt_plot2,1}.EdgeColor = 'none';
                grp_plots_w.(cur_wraps(i_ww).Nom){cmpt_plot2,1}.FaceColor = 'c';
                
                
                % hold way to plot: only nodes%
%                 grp_plots_w.(cur_wraps(i_ww).Nom){cmpt_plot2,1}=...
%                 scatter3(xyz_inR0(:,1), xyz_inR0(:,2), xyz_inR0(:,3),'c.');
                hold on
                cmpt_plot2=cmpt_plot2+1;
            elseif strcmp(cur_wraps(i_ww).type,'WrapSphere')
                R=cur_wraps(i_ww).Geometry.Rayon;
                [X,Y,Z]=sphere(30);
                [s]=size(X);
                
                xyz(:,1)=X(:)*R;
                xyz(:,2)=Y(:)*R;
                xyz(:,3)=Z(:)*R;
                xyz(:,4)=1;
                
                xyz_inR0=(cur_wraps(i_ww).MH_R0_Rw(:,:,1)* xyz')';
                [I,J]=ind2sub(s,1:length(xyz(:,1)));
                for ij=1:length(xyz(:,1))
                    XX(I(ij),J(ij))=xyz_inR0(ij,1);
                    YY(I(ij),J(ij))=xyz_inR0(ij,2);
                    ZZ(I(ij),J(ij))=xyz_inR0(ij,3);
                end
                grp_plots_w.(cur_wraps(i_ww).Nom){cmpt_plot2,1}=surf(XX,YY,ZZ,'FaceAlpha',0.5);
                grp_plots_w.(cur_wraps(i_ww).Nom){cmpt_plot2,1}.EdgeColor = 'none';
                grp_plots_w.(cur_wraps(i_ww).Nom){cmpt_plot2,1}.FaceColor = 'c';
                % hold way to plot: only nodes%
%                 grp_plots_w.(cur_wraps(i_ww).Nom){cmpt_plot2,1}=...
%                 scatter3(xyz_inR0(:,1), xyz_inR0(:,2), xyz_inR0(:,3),'c.');
                hold on
                cmpt_plot2=cmpt_plot2+1;
            elseif strcmp(cur_wraps(i_ww).type,'WrapCylinder')
                R=cur_wraps(i_ww).Geometry.Rayon;
                L=cur_wraps(i_ww).Geometry.Longueur;
                [X,Y,Z]=cylinder(R,30);
                [s]=size(X);
                
                xyz(:,1)=X(:);
                xyz(:,2)=Y(:);
                xyz(:,3)=(Z(:)-0.5)*L;
                xyz(:,4)=1;
                
                xyz_inR0=(cur_wraps(i_ww).MH_R0_Rw(:,:,1)* xyz')';
                [I,J]=ind2sub(s,1:length(xyz(:,1)));
                for ij=1:length(xyz(:,1))
                    XX(I(ij),J(ij))=xyz_inR0(ij,1);
                    YY(I(ij),J(ij))=xyz_inR0(ij,2);
                    ZZ(I(ij),J(ij))=xyz_inR0(ij,3);
                end
                grp_plots_w.(cur_wraps(i_ww).Nom){cmpt_plot2,1}=surf(XX,YY,ZZ,'FaceAlpha',0.5);
                grp_plots_w.(cur_wraps(i_ww).Nom){cmpt_plot2,1}.EdgeColor = 'none';
                grp_plots_w.(cur_wraps(i_ww).Nom){cmpt_plot2,1}.FaceColor = 'c';
                % hold way to plot: only nodes%
%                 grp_plots_w.(cur_wraps(i_ww).Nom){cmpt_plot2,1}=...
%                 scatter3(xyz_inR0(:,1), xyz_inR0(:,2), xyz_inR0(:,3),'c.');
                hold on
                cmpt_plot2=cmpt_plot2+1;                
            end
        end
    else
        cur_wraps=struct;
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % boucle sur les points de définition du muscle
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for i_pts = 1 : length(pts_muscle)
        
        cur_pt = Struct_muscles_points.(cur_muscle)(i_pts).location_in_R0 ;
        
        if ~isnan(cur_pt(1,1,f))
            grp_plots.(cur_muscle){cmpt_plot,1}=scatter3(cur_pt(1,1,f),cur_pt(2,1,f),...
                cur_pt(3,1,f),'r.');
            cmpt_plot=cmpt_plot+1;
            hold on
            
            if i_pts>1
                
                prev_pt = Struct_muscles_points.(cur_muscle)(i_pts-1).location_in_R0;
                if isnan(prev_pt(1,1,f))
                    i_pts_prev = i_pts-1;
                    while isnan(prev_pt(1,1,f))
                        i_pts_prev = i_pts_prev-1;
                        prev_pt = Struct_muscles_points.(cur_muscle)(i_pts_prev).location_in_R0;
                    end
                end
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %boolean wrapping
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                bool1=0;
                bool2=0;
                bool0=0;
                if isfield(struct_muscle_wraps,cur_muscle) % le muscle a-t'il des wraps ?
                    n_w_m=length(cur_wraps);
                    bool1=zeros(n_w_m,1);
                    bool2=zeros(n_w_m,1);
                    bool0=zeros(n_w_m,1);
                    
                    for i_w=1:n_w_m
                        cur_w = cur_wraps(i_w).Nom;
                        bool0(i_w)=isfield(Struct_wraps_pts.(cur_muscle),cur_w);
                        try
                            bool1(i_w)=~isempty(Struct_wraps_pts.(cur_muscle)(i_pts-1).(cur_w));
                            bool2(i_w)=isempty(...
                                find( isnan(Struct_wraps_pts.(cur_muscle)(i_pts-1).(cur_w).Pts_in_R0(:,:,f)) ==1, 1) );
                        catch
                            bool1(i_w)=0;
                            bool2(i_w)=0;
                        end
                    end
                end
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                if isempty(find(bool2==1, 1))
                    grp_plots.(cur_muscle){cmpt_plot,1}=line([cur_pt(1,1,f) prev_pt(1,1,f)],...
                        [cur_pt(2,1,f) prev_pt(2,1,f)],...
                        [cur_pt(3,1,f) prev_pt(3,1,f)]);
                    grp_plots.(cur_muscle){cmpt_plot,1}.Color = 'r';
                    cmpt_plot=cmpt_plot+1;
                    hold on
                elseif ~isempty(find(bool2==1, 1)) % affiche trajectoire muscle wraps
                    w=find(bool2==1, 1);
                    for ii=1:length(w)
                        cur_w = cur_wraps(w(ii)).Nom;
                        if ~isempty(Struct_wraps_pts.(cur_muscle)(i_pts-1).(cur_w))
                            Pts_affiches = Struct_wraps_pts.(cur_muscle)(i_pts-1).(cur_w).Pts_in_R0(:,:,f);
                            if isempty(find( isnan(Pts_affiches)==1, 1) )
                                for i_pts_w = 1 : length(Pts_affiches)
                                    cur_pt_w = Pts_affiches(:,i_pts_w,f) ;
                                    grp_plots.(cur_muscle){cmpt_plot,1} = scatter3(cur_pt_w (1,1,f),cur_pt_w (2,1,f),...
                                        cur_pt_w (3,1,f),'r.');
                                    cmpt_plot=cmpt_plot+1;
                                    hold on
                                    
                                    if i_pts_w==1
                                        prev_pt_w=prev_pt;
                                    else
                                        iii=i_pts_w-1;
                                        prev_pt_w = Pts_affiches(:,iii,f);
                                    end
                                    grp_plots.(cur_muscle){cmpt_plot,1}=line([cur_pt_w(1,1,f) prev_pt_w(1,1,f)],...
                                        [cur_pt_w(2,1,f) prev_pt_w(2,1,f)],...
                                        [cur_pt_w(3,1,f) prev_pt_w(3,1,f)]);
                                    grp_plots.(cur_muscle){cmpt_plot,1}.Color = 'r';
                                    cmpt_plot=cmpt_plot+1;
                                    hold on
                                end
                            end
                        end
                    end
                    grp_plots.(cur_muscle){cmpt_plot,1}=line([cur_pt_w(1,1,f) cur_pt(1,1,f)],...
                        [cur_pt_w(2,1,f) cur_pt(2,1,f)],...
                        [cur_pt_w(3,1,f) cur_pt(3,1,f)]);
                    grp_plots.(cur_muscle){cmpt_plot,1}.Color = 'r';
                    cmpt_plot=cmpt_plot+1;
                    hold on
                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            end % fin condition si numero du point >1
        end
    end
    MontrerUnique(grp_plots,cur_muscle)
    cur_muscle
%     MontrerUnique(grp_plots_w,cur_wraps(i_ww).Nom)
end

% cacher des muscles

% CacherPlot(grp_plots,cur_muscle)
%MontrerMuscle(grp_plots,muscle_name)

end
%%
function []=CacherPlot(grp_plots,field_name)
%Entrée : un groupe (struct) de plot (wraps ou muscles)
%         le champs de la structure à cacher    
for i=1:length(grp_plots.(field_name))
    set(grp_plots.(field_name){i,1},'Visible','off')
end
end
%%
function []=MontrerMuscle(grp_plots,muscle_name)
%Entrée : un groupe (struct) de plot (wraps ou muscles)
%         le champs de la structure à montrer 
for i=1:length(grp_plots.(muscle_name))
    set(grp_plots.(muscle_name){i,1},'Visible','on')
end
end
%%
function []=CacherTout(grp_plots)
%Entrée : un groupe (struct) de plot (wraps ou muscles)

list_fields = fieldnames(grp_plots);
for ii=1:length(list_fields)
    cur_m=(list_fields{ii});
    for i=1:length(grp_plots.(cur_m))
        set(grp_plots.(cur_m){i,1},'Visible','off')
    end
end
end
%%
function []=MontrerUnique(grp_plots,field_name)
%Entrée : un groupe (struct) de plot (wraps ou muscles)
%         le champs de la structure à montrer      
%Sortie : cache tous les autres groupes
list_muscles = fieldnames(grp_plots);
for ii=1:length(list_muscles)
    cur_m=(list_muscles{ii});
    for i=1:length(grp_plots.(cur_m))
        set(grp_plots.(cur_m){i,1},'Visible','off')
    end
end
for i=1:length(grp_plots.(field_name))
    set(grp_plots.(field_name){i,1},'Visible','on')
end
end