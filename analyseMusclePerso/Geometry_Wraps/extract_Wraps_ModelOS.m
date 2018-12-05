function [Wraps] = extract_Wraps_ModelOS(st_model)

%% Puchaud Pierre,
% 24/05/2017
%
% Permet de resortir de la structure model d'OpenSim: Wraps
% Model: Structure contenant les données du model OpenSim
% Wraps est une structure contenant la liste des wraps et pour chacun d'eux :
%   Wraps.Nom
%   Wraps.Body : body/segment de rattachement
%   Wraps.location : Postion dans le repère du segments
%   Wraps.orientation : orientation dans le repère du segments (sequence
%   d'euler)

%% création des structures contenants les info relatives aux bodies et aux joints

Model_cin = st_model.Model.BodySet.objects.Body;
nb_bodies = length(Model_cin);

Wraps=struct;
Wraps.Nom = {};
Wraps.Body = {};
Wraps.location = {};
Wraps.orientation = {};
Wraps.type = {};
Wraps.Geometry = struct;
i_w_tot = 0;
% liste des bodies et des joints. Child & type sont aussi défini pour Joint
Wraptypes = {'WrapEllipsoid','WrapTorus','WrapCylinder','WrapSphere'};
nb_wt = length(Wraptypes);
axe=eye(3,3);
for i_body = 1:nb_bodies
    
    try
        bool_Wraps1 = ~isempty(Model_cin(i_body).WrapObjectSet);
        bool_Wraps2 = isfield(Model_cin(i_body).WrapObjectSet,'objects');
        bool_Wraps3 = ~isempty(Model_cin(i_body).WrapObjectSet.objects);
    catch
        bool_Wraps1 =0;
        bool_Wraps2 =0;
        bool_Wraps3 =0;
    end
    
    if bool_Wraps1 && bool_Wraps2 && bool_Wraps3
        for i_wt=1:nb_wt
            cur_wt = Wraptypes{i_wt};
            
            if isfield(Model_cin(i_body).WrapObjectSet.objects,cur_wt)
                nb_wraps = length(Model_cin(i_body).WrapObjectSet.objects.(cur_wt));
                
                for i_wraps=1:nb_wraps
                    cur_w = Model_cin(i_body).WrapObjectSet.objects.(cur_wt)(i_wraps);
                    i_w_tot = i_w_tot +1;
                    
                    Wraps(i_w_tot).Nom = cur_w.ATTRIBUTE.name;
                    Wraps(i_w_tot).Body = Model_cin(i_body).ATTRIBUTE.name;
                    Wraps(i_w_tot).OsOw_in_Rs = cur_w.translation;
                    Wraps(i_w_tot).orientation = cur_w.xyz_body_rotation;
                    Wraps(i_w_tot).type = cur_wt;
                    
                    if strcmp('WrapEllipsoid',cur_wt)
                        Wraps(i_w_tot).Geometry.Rayons = cur_w.dimensions;
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        % MESH %%%%%%%%%%%%%%%%%%%%%%%%%%
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        clear xy x y z tri TR Ellipsoid Ellipsoid_opt
                        %n=30;
                        n=40;
                        R1 = cur_w.dimensions(1);
                        R2 = cur_w.dimensions(2);
                        R3 = cur_w.dimensions(3);
                        [x,y,z]=ellipsoid(0,0,0,R1,R2,R3,n);
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        % Reconcatenate points %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        xy(:,1)=x(:);
                        xy(:,2)=y(:);
                        xy(:,3)=z(:);
                        % eliminate duplicate data points
                        xy=unique(xy,'rows'); 
                        % actually it gives tetahedron
                        tri = delaunay(xy(:,1),xy(:,2),xy(:,3));
                        TR = triangulation(tri,xy);
                        [tri,xy] = freeBoundary(TR); 
                        %now we only have triangles
                        %On écrit le movie object
                        Ellipsoid.Polygones=tri;
                        Ellipsoid.Noeuds=xy;
%                         Ellipsoid_opt=optimisation_objet_movie(Ellipsoid,524,25); %Lisser le maillage
                        Ellipsoid_opt=optimisation_objet_movie(Ellipsoid,1000,25); %Lisser le maillage
                        [Ellipsoid_opt.Infos,Ellipsoid_opt.Polygones]=analyse_geometrie_polygones(Ellipsoid_opt.Polygones,Ellipsoid_opt.Noeuds);
                        Ellipsoid_opt.Arr = analyse_arretes(Ellipsoid_opt.Polygones);
                        %     affiche_objet_movie(Ellipsoid_opt)
                        %     Wrap.Maillage=Ellipsoid_opt;
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        Wraps(i_w_tot).Maillage=Ellipsoid_opt;
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    elseif strcmp('WrapCylinder',cur_wt)
                        Wraps(i_w_tot).Geometry.Rayon = cur_w.radius;
                        Wraps(i_w_tot).Geometry.Longueur = cur_w.length;
                    elseif strcmp('WrapTorus',cur_wt)
                        Wraps(i_w_tot).Geometry.Rayonint = cur_w.inner_radius;
                        Wraps(i_w_tot).Geometry.Rayonext = cur_w.outer_radius;
                    elseif strcmp('WrapSphere',cur_wt)
                        Wraps(i_w_tot).Geometry.Rayon = cur_w.radius;
                    end
                    
                    %construction de la matrice homogene Rs vers Rw (repère
                    %wraps)
                    ax=cur_w.xyz_body_rotation(1);
                    ay=cur_w.xyz_body_rotation(2);
                    az=cur_w.xyz_body_rotation(3);
                    Angles = [ax ay az];
                    
                    M_rot = cell(1,3);
                    for i=1:3
                        M_rot{i}=Mrot_rotation_axe_angle(axe(:,i),Angles(i),'radians');
                    end
                    M_Rot_tot(1:3,1:3)=M_rot{1}*M_rot{2}*M_rot{3};
%                     M_Rot_tot(1:3,1:3)=M_rot{3}*M_rot{2}*M_rot{1}; % test christophe
                    Wraps(i_w_tot).MH_Rs_Rw = [M_Rot_tot, cur_w.translation';...
                                                 0 0 0               1    ];
                end
                
            end
        end
    end
    
    
end





end