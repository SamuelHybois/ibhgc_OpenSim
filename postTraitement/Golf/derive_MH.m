function donnees_derivees = derive_MH(donnees,freq)

% ***************************************
% Modif J. Bascou le 10/12/2009 : optimisation du temps de traitement en
% supprimant les conditions "if"
% ****************************************

%% en entr�e
%   - Matrice de donn�es, avec le temps en 3e dimension
%   - frequ: fr�quence de mesure

%% en sortie
%     - Matrice d�riv�e, avec le temps en 3e dimension

%% Traitement des donn�es
nb_pts = size(donnees,3);
donnees_derivees=zeros(size(donnees,1),size(donnees,2),nb_pts);
% D�riv�s au degr� 3: prise en compte des 4 points temporels entourant le
% point consid�r�
for i = 3:nb_pts-2
    donnees_derivees(:,:,i)     =   (-donnees(:,:,i+2)+8*donnees(:,:,i+1)-8*donnees(:,:,i-1)+donnees(:,:,i-2))/(12*(1/freq));
end

% Traitement des points aux extremes temporels: d�riv�s � un degr� moindre
    donnees_derivees(:,:,1)         =   (donnees(:,:,2)-donnees(:,:,1))/(1/freq);
    donnees_derivees(:,:,2)         =   (donnees(:,:,3)-donnees(:,:,1))/(2*(1/freq));
    donnees_derivees(:,:,nb_pts-1)  =   (donnees(:,:,end)-donnees(:,:,end-2))/(2*(1/freq));
    donnees_derivees(:,:,nb_pts)    =   (donnees(:,:,end)-donnees(:,:,end-1))/((1/freq));

    
    

% Version:     9.2 (2007)
% Langage:     Matlab    Version: 7.0
% Plate-forme: PC 

% Auteurs : H. Goujon X. Bonnet
% Date de cr�ation : 06-04-07

% Cr�� dans le cadre de : Th�se
% Professeur responsable : F. Lavaste
% ______________________________________________________________________
%
% Laboratoire de Biom�canique LBM
% ENSAM C.E.R. de PARIS                          email: lbm@paris.ensam.fr
% 151, bld de l'H�pital                          tel:   01.44.24.63.63
% 75013 PARIS                                    fax:   01.44.24.63.66
%___________________________________________________________________________
%
% Toutes copies ou diffusions de cette fonction ne peut �tre r�alis�e sans
% l'accord du LBM
%___________________________________________________________________________
%