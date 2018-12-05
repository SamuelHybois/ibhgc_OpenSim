figure ;
hold on
axis equal

% Repère thorax
quiver3(0,0,0,1,0,0,'Color','r')
quiver3(0,0,0,0,1,0,'Color','y')
quiver3(0,0,0,0,0,1,'Color','g')
text(0,0,0,'Rthorax')

% Repère centre de l'ellipsoide 
Or_Scap_Thorax =  [[0.6448, 0, -0.7643];...
     [0, 1, 0];...
     [-0.7643, 0, 0.6448]] ;
Tr_Scap_Thorax = [-0.0218, -0.0189, 0.0764] ;


quiver3(Tr_Scap_Thorax(1),Tr_Scap_Thorax(2),Tr_Scap_Thorax(3),Or_Scap_Thorax(1,1),Or_Scap_Thorax(2,1),Or_Scap_Thorax(3,1),'Color','r')
quiver3(Tr_Scap_Thorax(1),Tr_Scap_Thorax(2),Tr_Scap_Thorax(3),Or_Scap_Thorax(1,2),Or_Scap_Thorax(2,2),Or_Scap_Thorax(3,2),'Color','y')
quiver3(Tr_Scap_Thorax(1),Tr_Scap_Thorax(2),Tr_Scap_Thorax(3),Or_Scap_Thorax(1,3),Or_Scap_Thorax(2,3),Or_Scap_Thorax(3,3),'Color','g')
text(Tr_Scap_Thorax(1),Tr_Scap_Thorax(2),Tr_Scap_Thorax(3),'R_ellipsoid')

% Scapulothoracic ellipsoid

rX = 0.0764 ;
rY = 0.1637 ;
rZ = 0.0764 ;
ellipsoid(Tr_Scap_Thorax(1),Tr_Scap_Thorax(2),Tr_Scap_Thorax(3),rX,rY,rZ) ;