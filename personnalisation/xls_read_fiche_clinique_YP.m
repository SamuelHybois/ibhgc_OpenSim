function [param,rota]=xls_read_fiche_clinique_YP(xlsfile)
%Fonction qui va chercher des infos dans la fiche clinique 
%Attention au format de la fiche clinique qui doit �tre toujours le m�me
version_pelvienne=xlsread(xlsfile, 'Param�tres pelviens', 'C2');
incidence_pelvienne=xlsread(xlsfile, 'Param�tres pelviens', 'C3');
pente_sacree=xlsread(xlsfile, 'Param�tres pelviens', 'C4');
longueur_totale=xlsread(xlsfile, 'Taille', 'C3');
param=[version_pelvienne, incidence_pelvienne, longueur_totale, pente_sacree];
rota=zeros(21,3);
rota_frontale=xlsread(xlsfile,'Rotations inter-vert�brales','C2:C22'); %Rotation frontale
rota_laterale=xlsread(xlsfile,'Rotations inter-vert�brales','D2:D22'); %Rotation lat�rale
rota_axiale=xlsread(xlsfile,'Rotations inter-vert�brales','E2:E22'); %Rotation axiale
rota(:,1)=rota_frontale;
rota(:,2)=rota_laterale;
rota(:,3)=rota_axiale;
end