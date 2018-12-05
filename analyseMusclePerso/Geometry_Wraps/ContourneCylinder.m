function [Points_dans_Rw,Longueur,bool] =ContourneCylinder (Wrap,pt1,pt2)
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
%% 1- Compute locations of obstacle via points
R = Wrap.Geometry.Rayon  ;
h = Wrap.Geometry.Longueur  ;

%  [X1,Y1,Z1] = cylinder(R,30) ;
 
%   figure
%   surf(X1,Y1,(Z1-0.5)*h)
%   hold on

%nombre de PoinTS en SorTie
n=45;
% P Bounding-fixed via PoinTS STarT of PaTh
P = pt1(1:3,1);
% S Bounding-fixed via PoinTS END of PaTh
S = pt2(1:3,1);
O = [0;0;0];
% OS = (S-O)/norm(S-O) ;
% OP = (P-O)/norm(P-O) ;
%   scatter3(O(1),O(2),O(3),'bo')
%   scatter3(P(1),P(2),P(3),'ro')
%  hold on
%   axis equal
%   grid off
%   scatter3(S(1),S(2),S(3),'ro')
%  line([S(1),P(1)],[S(2),P(2),], [S(3),P(3)])
%
%quiver3(O(1),O(2),O(3),OS(1),OS(2),OS(3))
%quiver3(O(1),O(2),O(3),OP(1),OP(2),OP(3))
%% 2-on vérifie S'il y'a inTerSecTion de la droiTe danS avec le cercle danS le Plan XY

% %eQuaTion de cercle : x^2+y^2=R^2
% %eQuaTion de droiTe : y = a*x+b avec :
% a = (S(2)-P(2))/(S(1)-P(1));
% b = P(2)-a*P(1);
% % on injecTe danS l'éQuaTion de cercle y
% %x^2 + (a*x+b)^2=R^2
% %x^2 + a^2*x^2+ 2*a*b*x + b^2=R^2
% %  (a^2+1)*x^2+ 2*a*b*x + b^2-R^2 =0
% % On calcule le déTerminanT
% DD = (2*a*b)^2-4*(a^2+1)*(b^2-R^2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Erreur cylindre.
%eQuaTion de cercle : x^2+y^2=R^2
%eQuaTino de droiTe ParameTriQue:
%x = x0 +T*a_d
%y = y0 +T*b_d
%x = z0 +T*c_d
%N = S-P =PS
%P + T_Sol*N = [x;y;z]
N = S-P;
% on injecTe danS l'éQuaTion de cercle x,y
%(x0 +T*a_d)^2 + (y0 +T*b_d)^2=R^2
%(a_d^2+b_d^2) * T^2 + 2*(x0*a_d+y0*b_d) * T + (y0^2 + x0^2) - R^2 = 0
AlPha=N(1)^2+N(2)^2;
BeTa=2*(P(1)*N(1)+P(2)*N(2));
Gamma=(P(1)^2+P(2)^2-R^2);
DD2 = BeTa^2-4*AlPha*Gamma;

if DD2>0 % le cercle est croisé
    p = [AlPha BeTa Gamma];
    t_int = roots(p);
    
    pt_int(:,1)= P(1:3) +N(1:3).*t_int(1);
    pt_int(:,2)= P(1:3) +N(1:3).*t_int(2);
    
    %     scatter3(pt_int(1,1),pt_int(2,1),pt_int(3,1),'g*')
    %     scatter3(pt_int(1,2),pt_int(2,2),pt_int(3,2),'go')
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    val(1)=norm(P-pt_int(:,1));
    val(2)=norm(P-pt_int(:,2));
    [~,ind]=min(val);
    pt_int_Proche_P = pt_int(:,ind);
    
    val(1)=norm(S-pt_int(:,1));
    val(2)=norm(S-pt_int(:,2));
    [~,ind]=min(val);
    pt_int_Proche_S = pt_int(:,ind);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    cdt1=(-0.5*h<pt_int_Proche_S(3) && pt_int_Proche_S(3)<0.5*h);
    cdt2=(-0.5*h<pt_int_Proche_P(3) && pt_int_Proche_P(3)<0.5*h);
    cdt3 = ~isequal( sign(P(3)), sign(S(3)) );
    % On PourSuiT, Sinon on ne conTourne PaS.
    
    bool1= ( (P(1)<pt_int_Proche_S(1) && pt_int_Proche_S(1)<S(1)) || (P(1)>pt_int_Proche_S(1) && pt_int_Proche_S(1)>S(1)) ) ||...
    ( (P(1)<pt_int_Proche_P(1) && pt_int_Proche_P(1)<S(1)) || (P(1)>pt_int_Proche_P(1) && pt_int_Proche_P(1)>S(1)) );
    bool2= ( (P(2)<pt_int_Proche_S(2) && pt_int_Proche_S(2)<S(2)) || (P(2)>pt_int_Proche_S(2) && pt_int_Proche_S(2)>S(2)) )||...
    ( (P(2)<pt_int_Proche_P(2) && pt_int_Proche_P(2)<S(2)) || (P(2)>pt_int_Proche_P(2) && pt_int_Proche_P(2)>S(2)) );
    bool3= ((P(3)<pt_int_Proche_S(3) && pt_int_Proche_S(3)<S(3)) || (P(3)>pt_int_Proche_S(3) && pt_int_Proche_S(3)>S(3)) )||...
    ((P(3)<pt_int_Proche_P(3) && pt_int_Proche_P(3)<S(3)) || (P(3)>pt_int_Proche_P(3) && pt_int_Proche_P(3)>S(3)) );
    
    
    if ( (cdt1 || cdt2) || (~cdt1 && ~cdt2 && cdt3) ) && (bool1 && bool2 && bool3)
        bool=1;
        %% Circle tangency
        % Q possibilité 1
        Q(1,1)= ( P(1)*R^2 - R*P(2)*sqrt(P(1)^2 + P(2)^2 - R^2) )/( P(1)^2 + P(2)^2 );
        Q(2,1)= ( P(2)*R^2 + R*P(1)*sqrt(P(1)^2 + P(2)^2 - R^2) )/( P(1)^2 + P(2)^2 );
        % Q possibilité 2
        Q(1,2)= ( P(1)*R^2 + R*P(2)*sqrt(P(1)^2 + P(2)^2 - R^2) )/( P(1)^2 + P(2)^2 );
        Q(2,2)= ( P(2)*R^2 - R*P(1)*sqrt(P(1)^2 + P(2)^2 - R^2) )/( P(1)^2 + P(2)^2 );
        
        % T possibilité 1
        T(1,1)= ( S(1)*R^2 + R*S(2)*sqrt(S(1)^2 + S(2)^2 - R^2) )/( S(1)^2 + S(2)^2 );
        T(2,1)= ( S(2)*R^2 - R*S(1)*sqrt(S(1)^2 + S(2)^2 - R^2) )/( S(1)^2 + S(2)^2 );
        % T possibilité 2
        T(1,2)= ( S(1)*R^2 - R*S(2)*sqrt(S(1)^2 + S(2)^2 - R^2) )/( S(1)^2 + S(2)^2 );
        T(2,2)= ( S(2)*R^2 + R*S(1)*sqrt(S(1)^2 + S(2)^2 - R^2) )/( S(1)^2 + S(2)^2 );
        
        %         scatter3(Q(1,1),Q(2,1),0,'c*')
        %         scatter3(Q(1,2),Q(2,2),0,'co')
        
        %         scatter3(T(1,1),T(2,1),0,'c*')
        %         scatter3(T(1,2),T(2,2),0,'co')
        
%         line([T(1,1),Q(1,1)],[T(2,1),Q(2,1)], [0,0])
%         line([T(1,2),Q(1,2)],[T(2,2),Q(2,2)], [0,0])
 
        A1=[Q(1:2,1),T(1:2,1)];
        A2=[Q(1:2,2),T(1:2,2)];
        %%% Det ???%%%
        if -det(A1)>0 && -det(A2)<0
            Q_fin(1:2,1)=Q(1:2,1);
            T_fin(1:2,1)=T(1:2,1);
        elseif -det(A2)>0 && -det(A1)<0
            Q_fin(1:2,1)=Q(1:2,2);
            T_fin(1:2,1)=T(1:2,2);
        elseif -det(A1)>0 && -det(A2)>0 % cas très particulier (les deux cas sont inferieurs à 180° de rotation)
            
            if dot(Q(:,1),T(:,1))>0
                Q_fin(1:2,1)=Q(1:2,1);
                T_fin(1:2,1)=T(1:2,1);
            elseif dot(Q(:,2),T(:,2))>0
                Q_fin(1:2,1)=Q(1:2,2);
                T_fin(1:2,1)=T(1:2,2);
            else ~exist('Q_fin')
                
                alpha2=acosd(dot(Q(:,2),T(:,2))/norm(Q(:,2))/norm(T(:,2)));
                alpha1=acosd(dot(Q(:,1),T(:,1))/norm(Q(:,1))/norm(T(:,1)));
                
                if alpha1<alpha2
                    Q_fin(1:2,1)=Q(1:2,1);
                    T_fin(1:2,1)=T(1:2,1);
                elseif alpha1>alpha2
                    Q_fin(1:2,1)=Q(1:2,2);
                    T_fin(1:2,1)=T(1:2,2);
                end
                
            end
            
        else
            bool=0;
            Q_fin(1:2,1)=[nan,nan]';
            T_fin(1:2,1)=[nan,nan]';
        end
%         line([Q_fin(1),P(1)],[Q_fin(2),P(2),], [0,0])
%         line([T_fin(1),S(1)],[T_fin(2),S(2),], [0,0])
        
        QT = abs( R* acos(1.0 - ( (Q_fin(1)-T_fin(1) )^2 +(Q_fin(2)-T_fin(2) )^2 )/ (2*R^2) ) );
        PQ = (Q_fin(1)-P(1))^2+(Q_fin(2)-P(2))^2;
        TS = (S(1)-T_fin(1))^2+(S(2)-T_fin(2))^2;
        
        Q_fin(3)=P(3)+( (S(3)-P(3))*PQ ) / (PQ+QT+TS);
        T_fin(3)=S(3)-( (S(3)-P(3))*TS ) / (PQ+QT+TS);
        %%% ou %%%
        Q_fin_hy=[Q_fin(1:2);pt_int_Proche_P(3)];
        T_fin_hy=[T_fin(1:2);pt_int_Proche_S(3)];
        Q_fin=Q_fin_hy;
        T_fin=T_fin_hy;
        %         norm([Q_fin(1:2);pt_int_Proche_P(3)]-P)+norm([T_fin(1:2);pt_int_Proche_S(3)]-S)
        %         norm([T_fin(1:2);pt_int_Proche_S(3)]-S)
        
        t_z=(Q_fin(2)- P(2))/N(2);
        Q_fin_calc= P(3)+N(3)*t_z;
%                  scatter3(Q_fin(1),Q_fin(2),Q_fin_calc,'cs')
        
        t_z=(T_fin(2)- P(2))/N(2);
        T_fin_calc= P(3)+N(3)*t_z;
%                  scatter3(T_fin(1),T_fin(2),T_fin_calc,'c*')
        
        
        Q_fin(3)=Q_fin_calc;
        T_fin(3)=T_fin_calc;
        
        if Q_fin(3)>0.5*h
            Q_fin(3) = 0.5*h;
        elseif Q_fin(3)<-0.5*h
            Q_fin(3) = -0.5*h;
        end
        
        if T_fin(3)>0.5*h
            T_fin(3) = 0.5*h;
        elseif T_fin(3)<-0.5*h
            T_fin(3) = -0.5*h;
        end
        
        if T_fin(3)==Q_fin(3)
            if cdt1==1
                Q_fin=T_fin;
            elseif cdt2==1
                T_fin=Q_fin;
            end
        end
        %         scatter3(Q_fin(1),Q_fin(2),Q_fin(3),'cs')
        %         scatter3(T_fin(1),T_fin(2),T_fin(3),'c*')
        
        %         scatter3(Q_fin(1),Q_fin(2),pt_int_Proche_P(3),'cs')
        %         scatter3(T_fin(1),T_fin(2),pt_int_Proche_S(3),'c*')
        
        
        %         line([Q_fin(1),P(1)],[Q_fin(2),P(2),], [Q_fin(3),P(3)])
        %         line([T_fin(1),S(1)],[T_fin(2),S(2),], [T_fin(3),S(3)])
        
%                  line([Q_fin(1),P(1)],[Q_fin(2),P(2),], [Q_fin_calc,P(3)])
%                  line([T_fin(1),S(1)],[T_fin(2),S(2),], [T_fin_calc,S(3)])
        
        theta1 = 2*atand(Q_fin(2)/ (Q_fin(1) + sqrt( Q_fin(1)^2 + Q_fin(2)^2 ) ));
        theta2 = 2*atand(T_fin(2)/ (T_fin(1) + sqrt( T_fin(1)^2 + T_fin(2)^2 ) ));
        
        %n= round(abs(theta1-theta2)/3,0);
        %On choiSiT conSTanT Pour Que la maTrice SoiT de même Taille Pour
        %chaQue frame...
        n=45;
        theta = linspace(theta1,theta2,n);
        z_T = linspace(Q_fin(3),T_fin(3),n);
        x = R*cosd(theta);
        y = R*sind(theta);
        z = z_T;
        
        M=zeros(3,n);
        for i=1:n
            M(1:3,i) = [x(i);y(i);z(i)];
%              scatter3(M(1,i),M(2,i),M(3,i),'k*')
        end
        Points_dans_Rw = M;
        
        %diSTance PoinT à PoinT Pour la longueur ToT
        Longueur = sum( arrayfun(@(idx) norm(M(:,idx+1)-M(:,idx)), 1:n-1) );
        
        
    else
        bool = 0;
        Points_dans_Rw(1:3,1:n) = repmat([nan;nan;nan],[1,n]);
        Longueur = nan;
    end
else
    bool = 0;
    Points_dans_Rw(1:3,1:n) = repmat([nan;nan;nan],[1,n]);
    Longueur = nan;
    
    
end
end