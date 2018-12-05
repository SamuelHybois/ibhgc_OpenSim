function donnees_derivees = derive_colonne(donnees,freq)

% Traitement des donn�es
nb_pts = size(donnees,1);
donnees_derivees(nb_pts)=0 ;

% D�riv�s au degr� 3: prise en compte des 4 points temporels entourant le
% point consid�r�
for i = 3:nb_pts-2
    donnees_derivees(i)     =   (-donnees(i+2)+8*donnees(i+1)-8*donnees(i-1)+donnees(i-2))/(12*(1/freq));
end

% Traitement des points aux extremes temporels: d�riv�s � un degr� moindre
donnees_derivees(1)         =   (donnees(2)-donnees(1))/(1/freq);
donnees_derivees(2)         =   (donnees(3)-donnees(1))/(2*(1/freq));
donnees_derivees(nb_pts-1)  =   (donnees(end)-donnees(end-2))/(2*(1/freq));
donnees_derivees(nb_pts)    =   (donnees(end)-donnees(end-1))/((1/freq));

    
end

    
    