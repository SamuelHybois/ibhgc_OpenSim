function [theta,phi]=Ellipsoid_Cartesian2Parameters(xyz,a,b,c)
%En entrée :
%           * une matrice xyz avec les coordoonées des points [X , Y, Z]
%En sortie :
%           * un vecteur avec les theta correspondants
%           * un vecteur avec les phi correspondants

%%equation d'ellipsoide x^2/a^2+y^2/b^2+z^2/c^2=1
%%equation d'ellipsoide parametrique
% x= a c(theta)c(phi)
% x= b c(theta)s(phi)
% x= c s(theta)
nb=size(xyz,1);
phi=zeros(nb,1);
theta=zeros(nb,1);
x=xyz(:,1);
y=xyz(:,2);
z=xyz(:,3);

%Attention on supprime les points qui sont au sommet z. car valable pour
%tout phi.
ii=0;

for i=1:nb
    xi=x(i);
    yi=y(i);
    zi=z(i);
    
    if xi~=0 && yi~=0 && zi~=0
        
        theta(i-ii,1)=asin(zi/c);
        phi(i-ii,1)=atan(yi/xi*a/b);
        
    elseif xi==0 && yi~=0 && zi~=0
        theta(i-ii,1)=asin(zi/c);
        phi(i-ii,1)=asin( yi/b/cos(theta(i-ii,1)) );
    elseif xi~=0 && yi==0 && zi~=0
        theta(i-ii,1)=asin(zi/c);
        phi(i-ii,1)=acos( xi/a/cos(theta(i-ii,1)) );
    elseif xi~=0 && yi~=0  && zi==0
        phi(i-ii,1)=atan(yi/xi*a/b);
        theta(i-ii,1)=acos( xi/a/cos(phi(i-ii,1)) );
    elseif xi==0 && yi==0 && zi~=0
        ii=ii+1;
        % Pas de phi possible ...
        %         break
        %         if z==c
        %             theta(i,1)=pi/2;
        %         else
        %             theta(i,1)=-pi/2;
        %         end
    elseif xi~=0 && yi==0 && zi==0
        if x==a
            phi(i-ii,1)=0;
            theta(i-ii,1)=acos( xi/a/cos(phi(i-ii,1)) );
        else
            phi(i-ii,1)=-pi;
            theta(i-ii,1)=acos( xi/a/cos(phi(i-ii,1)) );
        end
    elseif xi==0 && yi~=0 && zi==0
        if y==b
            phi(i-ii,1)=pi/2;
            theta(i-ii,1)=acos( xi/a/cos(phi(i-ii,1)) );
        else
            phi(i-ii,1)=-pi/2;
            theta(i-ii,1)=acos( xi/a/cos(phi(i-ii,1)) );
        end
    end
end

for i_del=1:ii
    phi(end,1)=[];
    theta(end,1)=[];
end
end