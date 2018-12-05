function [Points_dans_Rw,Longueur,bool] =ContourneEllipsoid(Wrap,pt1,pt2)
%Puchaud Pierre 24/05/2017
% En entree:
%           *Un wrap (structure)
%           *Deux points dans Rw (vecteur colonne)
% En sortie :
%           *Points dans Rw
%           *booleen "l'objet est croisée"
%           *Longueur contournée
% reference : Obstacle set method, Garnder and Pandy for muscle path
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

warning('off','all')
%% 1- l'ellispoide : paramètres

R = Wrap.Geometry.Rayons ;
R1=R(1);
R2=R(2);
R3=R(3);

n=30; %maillage assumé.
nn=45; %nombre points en sortie assumé
[x,y,z]=ellipsoid(0,0,0,R1,R2,R3,n);
%surf(x,y,z)
%shading flat
%axis equal
%% 2-points qui sont autour de l'ellispoide
S=pt1;
P=pt2;
% scatter3(P(1),P(2),P(3),'r*')
% hold on
% scatter3(S(1),S(2),S(3),'ro')
% hold on
%         line( [S(1) P(1)],...
%         [S(2) P(2) ],...
%         [S(3) P(3)]);
%Calcul des points les plus proches sur l'ellipsoid sur la droite
%equation d'ellipsoide x^2/a^2+y^2/b^2+z^2/c^2=1
%equation de droite parametrique
%x = x0 +t*a_d
%y = y0 +t*b_d
%x = z0 +t*c_d
%N = S-P =PS
%P + t_sol*N = [x;y;z]
N = S-P;
% % on injecte l'equation parametrique de droite dans l'equation de
% % l'ellipsoide, en développant, on obtient les coefficient d'un polynome
% % d'ordre 2 : Alpha * t_sol^2 + Beta * t_sol + Gamma = 0
Alpha =  N(1)^2/R1^2 + N(2)^2/R2^2 + N(3)^2/R3^2 ;
Beta = 2*(  P(1)*N(1)/R1^2 +  P(2)*N(2)/R2^2  + P(3)*N(3)/R3^2   );
Gamma = P(1)^2/R1^2 + P(2)^2/R2^2 + P(3)^2/R3^2 - 1 ;

p = [Alpha Beta Gamma];
t_sol = roots(p);


Pt_ellipsoid = zeros(2,3);
for j=1:3
    for i=1:2
        Pt_ellipsoid(i,j) = P(j) +N(j)*t_sol(i);
    end
end
%scatter3(Pt_ellipsoid(1,1),Pt_ellipsoid(1,2),Pt_ellipsoid(1,3),'bo')
%hold on
%scatter3(Pt_ellipsoid(2,1),Pt_ellipsoid(2,2),Pt_ellipsoid(2,3),'b*')
%hold on

% Pourqu'il y ait au moins 1 points entre S et P qui coupe l'ellipsoid
bool1= ( (P(1)<Pt_ellipsoid(1,1) && Pt_ellipsoid(1,1)<S(1)) || (P(1)>Pt_ellipsoid(1,1) && Pt_ellipsoid(1,1)>S(1)) ) ||...
    ( (P(1)<Pt_ellipsoid(2,1) && Pt_ellipsoid(2,1)<S(1)) || (P(1)>Pt_ellipsoid(2,1) && Pt_ellipsoid(2,1)>S(1)) );
bool2= ( (P(2)<Pt_ellipsoid(1,2) && Pt_ellipsoid(1,2)<S(2)) || (P(2)>Pt_ellipsoid(1,2) && Pt_ellipsoid(1,2)>S(2)) )||...
    ( (P(2)<Pt_ellipsoid(2,2) && Pt_ellipsoid(2,2)<S(2)) || (P(2)>Pt_ellipsoid(2,2) && Pt_ellipsoid(2,2)>S(2)) );
bool3= ((P(3)<Pt_ellipsoid(1,3) && Pt_ellipsoid(1,3)<S(3)) || (P(3)>Pt_ellipsoid(1,3) && Pt_ellipsoid(1,3)>S(3)) )||...
    ((P(3)<Pt_ellipsoid(2,3) && Pt_ellipsoid(2,3)<S(3)) || (P(3)>Pt_ellipsoid(2,3) && Pt_ellipsoid(2,3)>S(3)) );

Cdt_pts_proches = abs(distance_points(Pt_ellipsoid(1,:),Pt_ellipsoid(2,:)))>10^-3;

if isreal(t_sol) && bool1 && bool2 && bool3 && Cdt_pts_proches %si les racines sont réelles, on continue.
    bool = 1;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Création du maillage du wraps Seulement si inexsitant
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    
%     %% reconcatenate points %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     xy(:,1)=x(:);
%     xy(:,2)=y(:);
%     xy(:,3)=z(:);
%     
%     xy=unique(xy,'rows'); % eliminate duplicate data points
%     
%     tri = delaunay(xy(:,1),xy(:,2),xy(:,3));% actually it gives tetahedron
%     TR = triangulation(tri,xy);
%     [tri,xy] = freeBoundary(TR); %now we only have triangles
%     %On écrit le movie object
%     Ellipsoid.Polygones=tri;
%     Ellipsoid.Noeuds=xy;
%     Ellipsoid_opt=optimisation_objet_movie(Ellipsoid,524,25); %Lisser le maillage
%     %     affiche_objet_movie(Ellipsoid_opt)
%     %             Wrap.Maillage=Ellipsoid_opt;
%     %%
%     %         Maillage=Ellipsoid_opt;
%     
%     %         Maillage=Wrap.Maillage;

    Ellipsoid_opt=Wrap.Maillage;
     
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % ajout les 2 noeuds au maillage
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     for i_pt=1:2
%         x=zeros(size(Ellipsoid_opt.Polygones,1),1);
%         for i_pol= 1:size(Ellipsoid_opt.Polygones,1)
%             for i_node=1:size(Ellipsoid_opt.Polygones(i_pol,:),2)
%                 cur_node = Ellipsoid_opt.Polygones(i_pol,i_node);
%                 x(i_pol)=x(i_pol)+Norm2(Ellipsoid_opt.Noeuds(cur_node,:)-Pt_ellipsoid(i_pt,:));
%             end
%         end
%         [~,ind]=sort(x); % C'est le deuxieme qui devrait être premier
%         
%         for i_hyp =1:6
%         vect_hyp(i_hyp,:) = Pt_ellipsoid(i_pt,:)-Ellipsoid_opt.Infos.Barycentre(ind(i_hyp),:);
%         vect_hyp(i_hyp,:)=vect_hyp(i_hyp,:)/Norm2(vect_hyp(i_hyp,:));
%         res(i_hyp) = dot(vect_hyp(i_hyp,:),Ellipsoid_opt.Infos.Normale(ind(i_hyp),:)/Norm2(Ellipsoid_opt.Infos.Normale(ind(i_hyp),:)));
%         end
%         [val_hyp,ind_hyp]=min(res) % C'est le deuxieme qui devrait être trouvé mais il trouve le troisième...
%         
%         
%         node1=Ellipsoid_opt.Polygones(ind(2),1)
%         node2=Ellipsoid_opt.Polygones(ind(2),2)
%         node3=Ellipsoid_opt.Polygones(ind(2),3)
%         scatter3(Ellipsoid_opt.Noeuds(node1,1),Ellipsoid_opt.Noeuds(node1,2),Ellipsoid_opt.Noeuds(node1,3),'o')
%         scatter3(Ellipsoid_opt.Noeuds(node2,1),Ellipsoid_opt.Noeuds(node2,2),Ellipsoid_opt.Noeuds(node2,3),'o')
%         scatter3(Ellipsoid_opt.Noeuds(node3,1),Ellipsoid_opt.Noeuds(node3,2),Ellipsoid_opt.Noeuds(node3,3),'o')
%     end
    
%     [Ellipsoid_opt.Infos,Ellipsoid_opt.Polygones]=analyse_geometrie_polygones(Ellipsoid_opt.Polygones,Ellipsoid_opt.Noeuds);
% %     distance_point_triangle(Ellipsoid_opt.Polygones,Pt_ellipsoid(i_pt,:))
%     Ellipsoid_opt.Arr = analyse_arretes(Ellipsoid_opt.Polygones);
%     
%     seg =zeros(2,3,length(Ellipsoid_opt.Arr.Polygones));
%     for i_arr=1:length(Ellipsoid_opt.Arr.Polygones)
%             N1=Ellipsoid_opt.Arr.Definition(i_arr,1);
%             N2=Ellipsoid_opt.Arr.Definition(i_arr,2);
%             seg(1,:,i_arr)=Ellipsoid_opt.Noeuds(N1,:);
%             seg(2,:,i_arr)=Ellipsoid_opt.Noeuds(N2,:);
%     end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Technique retenue
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
     
    
       
    
    for i_pt=1:2
        
        seg =zeros(2,3,length(Ellipsoid_opt.Arr.Polygones));
    for i_arr=1:length(Ellipsoid_opt.Arr.Polygones)
            N1=Ellipsoid_opt.Arr.Definition(i_arr,1);
            N2=Ellipsoid_opt.Arr.Definition(i_arr,2);
            seg(1,:,i_arr)=Ellipsoid_opt.Noeuds(N1,:);
            seg(2,:,i_arr)=Ellipsoid_opt.Noeuds(N2,:);
    end
        
        
         Plan =zeros(2,3,length(Ellipsoid_opt.Infos.Barycentre));
    for i_pol=1:length(Ellipsoid_opt.Infos.Barycentre)
            Plan(1,:,i_pol)=Ellipsoid_opt.Infos.Barycentre(i_pol,:);
            Plan(2,:,i_pol)=Ellipsoid_opt.Infos.Normale(i_pol,:);
    end
        
        
        % On trouve l'arrete la plus proche
        res_arr=zeros(length(Ellipsoid_opt.Arr.Definition),1);
        res_ma_fct=zeros(length(Ellipsoid_opt.Arr.Definition),1);
        pts=zeros(length(Ellipsoid_opt.Arr.Definition),3);
        pts_ma_fct=zeros(length(Ellipsoid_opt.Arr.Definition),3);
%         [ddd,Pts ]= distance_points_movie(Ellipsoid_opt.Noeuds,Ellipsoid_opt.Polygones,Pt_ellipsoid(i_pt,:));
%         find(find(Ellipsoid_opt.Infos.Barycentre==Pts)==1)
%         scatter3(Pts(1),Pts(2),Pts(3))
        for i_arr=1:length(Ellipsoid_opt.Arr.Definition)
            [res_arr(i_arr),pts(i_arr,:)]=distance_point_segment(seg(:,:,i_arr),Pt_ellipsoid(i_pt,:));
            pts_ma_fct(i_arr,:)=Pt_ellipsoid(i_pt,:) ...
            - calcul_point_plus_proche_CoR(seg(1,:,i_arr)',seg(2,:,i_arr)',Pt_ellipsoid(i_pt,:)')';
            res_ma_fct(i_arr)=norm(pts_ma_fct(i_arr));

        end
        [val_arr,ind_arr]=sort(res_arr);
        [val_ma_fct,ind_ma_fct]=sort(res_ma_fct);
        
        % On vérifie si les points d'intersection sont bien dans
        % l'intervalle du segemnts
        boolx = (pts(ind_arr(1),1)<seg(1,1,ind_arr(1)) && pts(ind_arr(1),1)>seg(2,1,ind_arr(1))) || (pts(ind_arr(1),1)>seg(1,1,ind_arr(1)) && pts(ind_arr(1),1)<seg(2,1,ind_arr(1)));
        booly = (pts(ind_arr(1),2)<seg(1,2,ind_arr(1)) && pts(ind_arr(1),2)>seg(2,2,ind_arr(1))) || (pts(ind_arr(1),2)>seg(1,2,ind_arr(1)) && pts(ind_arr(1),2)<seg(2,2,ind_arr(1)));
        boolz = (pts(ind_arr(1),3)<seg(1,3,ind_arr(1)) && pts(ind_arr(1),3)>seg(2,3,ind_arr(1))) || (pts(ind_arr(1),3)>seg(1,3,ind_arr(1)) && pts(ind_arr(1),3)<seg(2,3,ind_arr(1)));
        
%         scatter3(pts(ind_arr(1),1),pts(ind_arr(1),2),pts(ind_arr(1),3))
        cmpt=1;
        while ~boolx && ~booly && ~boolz
        cmpt=cmpt+1;
        boolx = (pts(ind_arr(cmpt),1)<seg(1,1,ind_arr(cmpt)) && pts(ind_arr(cmpt),1)>seg(2,1,ind_arr(cmpt))) || (pts(ind_arr(cmpt),1)>seg(1,1,ind_arr(cmpt)) && pts(ind_arr(cmpt),1)<seg(2,1,ind_arr(cmpt)));
        booly = (pts(ind_arr(cmpt),2)<seg(1,2,ind_arr(cmpt)) && pts(ind_arr(cmpt),2)>seg(2,2,ind_arr(cmpt))) || (pts(ind_arr(cmpt),2)>seg(1,2,ind_arr(cmpt)) && pts(ind_arr(cmpt),2)<seg(2,2,ind_arr(cmpt)));
        boolz = (pts(ind_arr(cmpt),3)<seg(1,3,ind_arr(cmpt)) && pts(ind_arr(cmpt),3)>seg(2,3,ind_arr(cmpt))) || (pts(ind_arr(cmpt),3)>seg(1,3,ind_arr(cmpt)) && pts(ind_arr(cmpt),3)<seg(2,3,ind_arr(cmpt)));
        
        end
    
        % On trouve les deux polygones possibles
        
%         N1=Ellipsoid_opt.Arr.Definition(ind_ma_fct(1),1);
%         N2=Ellipsoid_opt.Arr.Definition(ind_ma_fct(1),2);
%         
%         N1=Ellipsoid_opt.Arr.Definition(ind_arr(2),1);
%         N2=Ellipsoid_opt.Arr.Definition(ind_arr(2),2);
        
        N1=Ellipsoid_opt.Arr.Definition(ind_arr(cmpt),1);
        N2=Ellipsoid_opt.Arr.Definition(ind_arr(cmpt),2);
        
%         scatter3(Ellipsoid_opt.Noeuds(N1,1),Ellipsoid_opt.Noeuds(N1,2),Ellipsoid_opt.Noeuds(N1,3));
%         scatter3(Ellipsoid_opt.Noeuds(N2,1),Ellipsoid_opt.Noeuds(N2,2),Ellipsoid_opt.Noeuds(N2,3));
        
        add_cdt1 = double(Ellipsoid_opt.Polygones==N1);
        add_cdt2 = add_cdt1 + double(Ellipsoid_opt.Polygones==N2);
        add_cdt22 = add_cdt2(:,1)+add_cdt2(:,2)+add_cdt2(:,3);
        [val,~] = find(add_cdt22 == 2);
        
        
        % On trouve le polygone le plus proche 
        clear res
        res = zeros(length(val),1);
        for i_pol=1:length(val)
            res(i_pol)=distance_points_plan(Pt_ellipsoid(i_pt,:),Plan(:,:,val(i_pol)));
        end
        
        [~,ind_pol]=sort(res,'descend');
        
        N1_final=Ellipsoid_opt.Polygones(val(ind_pol(1)),1);
        N2_final=Ellipsoid_opt.Polygones(val(ind_pol(1)),2);
        N3_final=Ellipsoid_opt.Polygones(val(ind_pol(1)),3);
        
        %         scatter3(Ellipsoid_opt.Noeuds(N1_final,1),Ellipsoid_opt.Noeuds(N1_final,2),Ellipsoid_opt.Noeuds(N1_final,3))
        %         scatter3(Ellipsoid_opt.Noeuds(N2_final,1),Ellipsoid_opt.Noeuds(N2_final,2),Ellipsoid_opt.Noeuds(N2_final,3))
        %         scatter3(Ellipsoid_opt.Noeuds(N3_final,1),Ellipsoid_opt.Noeuds(N3_final,2),Ellipsoid_opt.Noeuds(N3_final,3))
        
        add_cdt1 = double(Ellipsoid_opt.Polygones==N1_final);
        add_cdt2 = add_cdt1 + double(Ellipsoid_opt.Polygones==N2_final);
        add_cdt3 = add_cdt2 + double(Ellipsoid_opt.Polygones==N3_final);
        add_cdt33 = add_cdt3(:,1)+add_cdt3(:,2)+add_cdt3(:,3);
        [val2,~] = find(add_cdt33 == 3);
        
        % indice du polygone trouvé.
        Noeuds = Ellipsoid_opt.Polygones(val2,:);
        Ellipsoid_opt.Polygones(val2,:)=[];
        
        %On ajoute le Noeuds
        Ellipsoid_opt.Noeuds(end+1,:)=Pt_ellipsoid(i_pt,:);
        %On créer 3 nouveaux éléments (polygones)
        Ellipsoid_opt.Polygones(end+1,:)=[length(Ellipsoid_opt.Noeuds), Noeuds(1),Noeuds(2)];
        Ellipsoid_opt.Polygones(end+1,:)=[length(Ellipsoid_opt.Noeuds), Noeuds(2),Noeuds(3)];
        Ellipsoid_opt.Polygones(end+1,:)=[length(Ellipsoid_opt.Noeuds), Noeuds(3),Noeuds(1)];
        
        % Bien maillé vérif ..
        [Ellipsoid_opt.Infos,Ellipsoid_opt.Polygones] = analyse_geometrie_polygones(Ellipsoid_opt.Polygones,Ellipsoid_opt.Noeuds);
        Ellipsoid_opt.Arr = analyse_arretes(Ellipsoid_opt.Polygones);
        
        
%         quiver3(Ellipsoid_opt.Infos.Barycentre(end-2,1),Ellipsoid_opt.Infos.Barycentre(end-2,2),Ellipsoid_opt.Infos.Barycentre(end-2,3),...
%         Ellipsoid_opt.Infos.Normale(end-2,1),Ellipsoid_opt.Infos.Normale(end-2,2),Ellipsoid_opt.Infos.Normale(end-2,3),0.1)
%         quiver3(Ellipsoid_opt.Infos.Barycentre(end-1,1),Ellipsoid_opt.Infos.Barycentre(end-1,2),Ellipsoid_opt.Infos.Barycentre(end-1,3),...
%         Ellipsoid_opt.Infos.Normale(end-1,1),Ellipsoid_opt.Infos.Normale(end-1,2),Ellipsoid_opt.Infos.Normale(end-1,3),0.1)
%         quiver3(Ellipsoid_opt.Infos.Barycentre(end,1),Ellipsoid_opt.Infos.Barycentre(end,2),Ellipsoid_opt.Infos.Barycentre(end,3),...
%         Ellipsoid_opt.Infos.Normale(end,1),Ellipsoid_opt.Infos.Normale(end,2),Ellipsoid_opt.Infos.Normale(end,3),0.1)
        
        cdt_mailles_1 = sign(Ellipsoid_opt.Infos.Normale(end-2,:)'./...
                        Ellipsoid_opt.Infos.Normale(end-1,:)') ;
        cdt_mailles_2 = sign(Ellipsoid_opt.Infos.Normale(end-1,:)'./...
                        Ellipsoid_opt.Infos.Normale(end,:)');
        cdt_mailles_3 = sign(Ellipsoid_opt.Infos.Normale(end-2,:)'./...
                        Ellipsoid_opt.Infos.Normale(end,:)') ;
        
        if size(find(cdt_mailles_1==-1),1)==3 || size(find(cdt_mailles_2==-1),1)==3 || size(find(cdt_mailles_3==-1),1)==3
        Ellipsoid_opt.Polygones(end,:)=[];
        Ellipsoid_opt.Polygones(end,:)=[];
        Ellipsoid_opt.Polygones(end,:)=[];
        
        Ellipsoid_opt.Polygones(end+1,:)=Noeuds;
        
        N1_final=Ellipsoid_opt.Polygones(val(ind_pol(2)),1);
        N2_final=Ellipsoid_opt.Polygones(val(ind_pol(2)),2);
        N3_final=Ellipsoid_opt.Polygones(val(ind_pol(2)),3);
        
        %         scatter3(Ellipsoid_opt.Noeuds(N1_final,1),Ellipsoid_opt.Noeuds(N1_final,2),Ellipsoid_opt.Noeuds(N1_final,3))
        %         scatter3(Ellipsoid_opt.Noeuds(N2_final,1),Ellipsoid_opt.Noeuds(N2_final,2),Ellipsoid_opt.Noeuds(N2_final,3))
        %         scatter3(Ellipsoid_opt.Noeuds(N3_final,1),Ellipsoid_opt.Noeuds(N3_final,2),Ellipsoid_opt.Noeuds(N3_final,3))
        
        add_cdt1 = double(Ellipsoid_opt.Polygones==N1_final);
        add_cdt2 = add_cdt1 + double(Ellipsoid_opt.Polygones==N2_final);
        add_cdt3 = add_cdt2 + double(Ellipsoid_opt.Polygones==N3_final);
        add_cdt33 = add_cdt3(:,1)+add_cdt3(:,2)+add_cdt3(:,3);
        [val2,~] = find(add_cdt33 == 3);
        
        % indice du polygone trouvé.
        Noeuds = Ellipsoid_opt.Polygones(val2,:);
        Ellipsoid_opt.Polygones(val2,:)=[];
        
        %On ajoute le Noeuds
%         Ellipsoid_opt.Noeuds(end+1,:)=Pt_ellipsoid(i_pt,:);
        %On créer 3 nouveaux éléments (polygones)
        Ellipsoid_opt.Polygones(end+1,:)=[length(Ellipsoid_opt.Noeuds), Noeuds(1),Noeuds(2)];
        Ellipsoid_opt.Polygones(end+1,:)=[length(Ellipsoid_opt.Noeuds), Noeuds(2),Noeuds(3)];
        Ellipsoid_opt.Polygones(end+1,:)=[length(Ellipsoid_opt.Noeuds), Noeuds(3),Noeuds(1)];
        
        end
    end
%      affiche_objet_movie(Ellipsoid_opt)
%hold on
%scatter3(Pt_ellipsoid(1,1),Pt_ellipsoid(1,2),Pt_ellipsoid(1,3),'b*')
%scatter3(Pt_ellipsoid(2,1),Pt_ellipsoid(2,2),Pt_ellipsoid(2,3),'b*')

    
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     for i_pt=1:2
%         xxx = Norm2( Ellipsoid_opt.Noeuds-Pt_ellipsoid(i_pt,:) );
%         if xxx(end,:)==0
%             xxx(end,:)=[];
%         end
%         [~,ind]=sort(xxx);
%         
%         %         scatter3(Ellipsoid_opt.Noeuds(ind(1),1),Ellipsoid_opt.Noeuds(ind(1),2),Ellipsoid_opt.Noeuds(ind(1),3))
%         %         hold on
%         %         scatter3(Ellipsoid_opt.Noeuds(ind(2),1),Ellipsoid_opt.Noeuds(ind(2),2),Ellipsoid_opt.Noeuds(ind(2),3))
%         %         scatter3(Ellipsoid_opt.Noeuds(ind(3),1),Ellipsoid_opt.Noeuds(ind(3),2),Ellipsoid_opt.Noeuds(ind(3),3))
%         %         scatter3(Ellipsoid_opt.Noeuds(ind(4),1),Ellipsoid_opt.Noeuds(ind(4),2),Ellipsoid_opt.Noeuds(ind(4),3))
%         %         scatter3(Ellipsoid_opt.Noeuds(ind(5),1),Ellipsoid_opt.Noeuds(ind(5),2),Ellipsoid_opt.Noeuds(ind(5),3))
%         %         scatter3(Ellipsoid_opt.Noeuds(ind(6),1),Ellipsoid_opt.Noeuds(ind(6),2),Ellipsoid_opt.Noeuds(ind(6),3))
%         %         scatter3(Ellipsoid_opt.Noeuds(ind(7),1),Ellipsoid_opt.Noeuds(ind(7),2),Ellipsoid_opt.Noeuds(ind(7),3))
%         
%         add_cdt1 = double(Ellipsoid_opt.Polygones==ind(1));
%         add_cdt2 = add_cdt1 + double(Ellipsoid_opt.Polygones==ind(2));
%         add_cdt3 = add_cdt2 + double(Ellipsoid_opt.Polygones==ind(3));
%         add_cdt33 = add_cdt3(:,1)+add_cdt3(:,2)+add_cdt3(:,3);
%         [val,~] = find(add_cdt33 == 3);
%         if isempty(val) % si le troisieme noeuds n'est pas n'est pas le sommet du polygone
%             add_cdt22 = add_cdt2(:,1)+add_cdt2(:,2)+add_cdt2(:,3);
%             [val,~] = find(add_cdt22 == 2);
%             if ~isempty(val)
%                 %deux polygones avec deux noeuds à tester (le troisième)
%                 P1 = Ellipsoid_opt.Polygones(val(1),:);
%                 P2 = Ellipsoid_opt.Polygones(val(2),:);
%                 %Supprimer les noeuds déjà considérer
%                 for ii=1:3
%                     if P1(ii)~=ind(1) && P1(ii)~=ind(2)
%                         N1 = P1(ii);
%                     end
%                     if P2(ii)~=ind(1) && P2(ii)~=ind(2)
%                         N2 = P2(ii);
%                     end
%                 end
%                 % on teste lequel est le plus prêt
%                 Node(1)=Norm2(Ellipsoid_opt.Noeuds(N1,:)-Pt_ellipsoid(i_pt,:));
%                 Node(2)=Norm2(Ellipsoid_opt.Noeuds(N2,:)-Pt_ellipsoid(i_pt,:));
%                 
%                 [~,ind2]=min(Node);
%                 if ind2 ==1
%                     ind_n = N1;
%                 elseif ind2 ==2
%                     ind_n = N2;
%                 end
%                 add_cdt3 = add_cdt2 + double(Ellipsoid_opt.Polygones==ind_n);
%                 add_cdt33 = add_cdt3(:,1)+add_cdt3(:,2)+add_cdt3(:,3);
%                 [val,~] = find(add_cdt33 == 3);
%             else 
%                 
%                 disp('probleme creation des polygones ellispoide')
%             end
%         end
%         % indice du polygone trouvé.
%         Noeuds = Ellipsoid_opt.Polygones(val,:);
%         Ellipsoid_opt.Polygones(val,:)=[];
%         
%         %On ajoute le Noeuds
%         Ellipsoid_opt.Noeuds(end+1,:)=Pt_ellipsoid(i_pt,:);
%         %On créer 3 nouveaux éléments (polygones)
%         Ellipsoid_opt.Polygones(end+1,:)=[length(Ellipsoid_opt.Noeuds), Noeuds(1),Noeuds(2)];
%         Ellipsoid_opt.Polygones(end+1,:)=[length(Ellipsoid_opt.Noeuds), Noeuds(2),Noeuds(3)];
%         Ellipsoid_opt.Polygones(end+1,:)=[length(Ellipsoid_opt.Noeuds), Noeuds(3),Noeuds(1)];
%         
%         %         affiche_objet_movie(Ellipsoid_opt)
%         %         hold on
%         %         scatter3(Pt_ellipsoid(i_pt,1),Pt_ellipsoid(i_pt,2),Pt_ellipsoid(i_pt,3),'b*')
%         %         hold on
%     end

    %% Triangulation %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %     trisurf(Ellipsoid_opt.Polygones,Ellipsoid_opt.Noeuds(:,1),Ellipsoid_opt.Noeuds(:,2),Ellipsoid_opt.Noeuds(:,3));hold on;axis equal;grid off;
    m = size(Ellipsoid_opt.Noeuds,1);
    AA = zeros(m);
    I = Ellipsoid_opt.Polygones(:); J = Ellipsoid_opt.Polygones(:,[2 3 1]); J = J(:);
    
    % no treshold needed now that we have cleaned the mesh. We just put 1 in
    % the matrix A where data are connected by an edge. A(i,j) = 1 means the
    % segment data i:data j is an edge of the mesh
    IJ = I + m*(J-1); AA(IJ) = 1;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %We look for the points on the line and the ellipsoid
    clear ind
    ind = find(Ellipsoid_opt.Noeuds(:,1)==Pt_ellipsoid(1,1));
    if size(ind)>1
        ind2 = Ellipsoid_opt.Noeuds(ind,2)==Pt_ellipsoid(1,2);
        ind=ind(ind2);
    end
    indd = find(Ellipsoid_opt.Noeuds(:,1)==Pt_ellipsoid(2,1));
    if size(indd)>1
        ind2 = Ellipsoid_opt.Noeuds(indd,2)==Pt_ellipsoid(2,2);
        indd=indd(ind2);
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Algorithme pour trouver le plus court chemin sur l'ellipsoide
    [~,path] = dijkstra(AA,Ellipsoid_opt.Noeuds,ind,indd);
    xy_sol=Ellipsoid_opt.Noeuds(path,:);
    %tetramesh(tri,xy,'FaceAlpha',0.2,'FaceColor','none'); hold on;
    %plot3(xy_sol(:,1),xy_sol(:,2),xy_sol(:,3),'ro-','LineWidth',2); hold on
    %title(sprintf('Distance = %1.3f',cost));axis equal
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Interpolation Spline de la courbe 3D
    %Approche choisi (il faudrait une approximation pour lisser)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    nn=45; % nombre de points assumé.
    newCurve = spline3dCurveInterpolation(xy_sol,nn-1);
    %     hold on
    %     plot3(newCurve(:,1),newCurve(:,2),newCurve(:,3),'bo-','LineWidth',2)
    
    %% On passe les points obtenu dans le paramétrage ellispoide
    [theta_s,phi_s]=Ellipsoid_Cartesian2Parameters(newCurve,R1,R2,R3);
    
    %On vérifie pour tout les points lequel respect le mieux la contraintes de
    %tangence entre le point à l'extérieur de l'ellispoide et les points de
    %contour pour P et S.
    
    pt_tangent = zeros(2,3);
    clear ind
    for ii = 1 : 2
        if ii==1
            pt = P;
        elseif ii==2
            pt = S;
        end
        clear Res
        Res=zeros(length(theta_s),1);
        for i=1:length(theta_s)
            Res(i) = pt(1)*cos(theta_s(i))*cos(phi_s(i))/R1 +...
                pt(2)*cos(theta_s(i))*sin(phi_s(i))/R2 +...
                pt(3)*sin(theta_s(i))/R3-1;
        end
        [~,ind(ii)]=min(abs(Res));
        
        pt_tangent(ii,:)=newCurve(ind(ii),:);
        %         line( [pt(1) pt_tangent(ii,1)],...
        %         [pt(2) pt_tangent(ii,2)],...
        %         [pt(3) pt_tangent(ii,3)]);
    end
    %         line( [S(1) pt_tangent(2,1)],...
    %         [S(2) pt_tangent(2,2)],...
    %         [S(3) pt_tangent(2,3)]);
    %         line( [P(1) pt_tangent(1,1)],...
    %         [P(2) pt_tangent(1,2)],...
    %         [P(3) pt_tangent(1,3)]);
    %
    t = ind(1):ind(2);
    if isempty(t)
        t= ind(2):ind(1);
    end
    
    if length(t)==1
        Points_dans_Rw(1:3,1:nn) = repmat(newCurve(t,:)',[1,nn]);
        Longueur = 0;
    else
        Points_dans_Rw = spline3dCurveInterpolation(newCurve(t,:),nn-1)';
        %     plot3(newCurve(t,1),newCurve(t,2),newCurve(t,3),'ro-','LineWidth',2)
        %     plot3(newCurve2(:,1),newCurve2(:,2),newCurve2(:,3),'ro-','LineWidth',2)
        %     plot3(Points_dans_Rw(1,:),Points_dans_Rw(2,:),Points_dans_Rw(3,:),'r--s','LineWidth',2)
        Longueur = sum( arrayfun(@(idx) norm(Points_dans_Rw(:,idx+1)-Points_dans_Rw(:,idx)), 1:nn-1) );
    end
else
    bool = 0;
    Points_dans_Rw(1:3,1:nn) = repmat([nan;nan;nan],[1,nn]);
    Longueur = nan;
end
warning('on','all')
%test_exemple_plot(Ellipsoid_opt,S,P,pt_tangent,Points_dans_Rw)
end

function test_exemple_plot(Ellipsoid_opt,S,P,pt_tangent,Points_dans_Rw)
affiche_objet_movie(Ellipsoid_opt)
hold on
line( [S(1) pt_tangent(2,1)],...
[S(2) pt_tangent(2,2)],...
[S(3) pt_tangent(2,3)]);
line( [P(1) pt_tangent(1,1)],...
[P(2) pt_tangent(1,2)],...
[P(3) pt_tangent(1,3)]);
plot3(Points_dans_Rw(1,:),Points_dans_Rw(2,:),Points_dans_Rw(3,:),'r--s','LineWidth',2)
axis off
end