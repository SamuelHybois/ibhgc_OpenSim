%% 2D
close all;clear
      n = 100; A = zeros(n); xy = 1*rand(n,2);
      tri = delaunay(xy(:,1),xy(:,2));
      I = tri(:); J = tri(:,[2 3 1]); J = J(:);
      D = sqrt(sum((xy(I,:)-xy(J,:)).^2,2));
      I(D > 0.75,:) = []; J(D > 0.75,:) = [];
      IJ = I + n*(J-1); A(IJ) = 1;
      [cost,path] = dijkstra(A,xy,1,n);
      gplot(A,xy); hold on;
      plot(xy(path,1),xy(path,2),'ro-','LineWidth',2); hold off
      title(sprintf('Distance from 1 to 1000 = %1.3f',cost))

%% 3D 
      n = 10; A = zeros(n); xy = 1*rand(n,3);
      tri = delaunay(xy(:,1),xy(:,2),xy(:,3));
      I = [tri tri(:,[3 1])];I=I(:); J = [tri(:,[3 4 2 1]) tri(:,[4 2])]; J = J(:);
      D = sqrt(sum((xy(I,:)-xy(J,:)).^2,2));
      I(D > 0.75,:) = []; J(D > 0.75,:) = [];
      IJ = I + n*(J-1); A(IJ) = 1;
      [cost,path] = dijkstra(A,xy,1,n);
      tetramesh(tri,xy,'FaceAlpha',0.2); hold on;
      plot3(xy(path,1),xy(path,2),xy(path,3),'ro-','LineWidth',2); hold off
      title(sprintf('Distance from 1 to 1000 = %1.3f',cost))
      
%% Ellipsoid
%% Ellipsoid
clear xy
clear A
n=10;
[x,y,z]=ellipsoid(0,0,0,3,4,5,n);

xy(:,1)=x(:);
xy(:,2)=y(:);
xy(:,3)=z(:);
N=size(xy,1);
A = zeros(N);

tri = delaunay(xy(:,1),xy(:,2),xy(:,3));
I = [tri tri(:,[3 1])];I=I(:); J = [tri(:,[3 4 2 1]) tri(:,[4 2])]; J = J(:);
%D = sqrt(sum((xy(I,:)-xy(J,:)).^2,2));
%I(D > 0.75,:) = []; J(D > 0.75,:) = []; %% Attention, ici 0.75 était un seuil adapté à l’exemple du fichier original. Il sera à adapter selon tes besoins.
IJ = I + N*(J-1); A(IJ) = 1;
[cost,path] = dijkstra(A,xy,4,20);

tetramesh(tri,xy,'FaceAlpha',0.2); hold on;
plot3(xy(path,1),xy(path,2),xy(path,3),'ro-','LineWidth',2); hold off
title(sprintf('Distance from 1 to 1000 = %1.3f',cost))

 