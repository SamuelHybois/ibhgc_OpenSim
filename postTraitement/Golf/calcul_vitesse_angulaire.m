function vit_ang = calcul_vitesse_angulaire(Struct_MH,freq,arg_plot)

nb_frame=size(Struct_MH.pelvis.MH,3);
noms_segments=fieldnames(Struct_MH);
MH_derive=struct;
Omega=zeros(3,3,nb_frame);
vit_ang=struct;
% Détermination de l'échelle du temps en fonction du nombre d'images et de
% la fréquence
time=1/freq:1/freq:nb_frame/freq;

for i_seg=1:size(noms_segments,1)
    nom_seg=noms_segments(i_seg);
    nom_seg=nom_seg{1};
    
    MH_derive.(nom_seg)=derive_MH(Struct_MH.(nom_seg).MH(1:3,1:3,:),freq); % Calcul de la dérivée de la matrice homogène
    
    for i_frame=1:nb_frame
        % Omega =skew matrix de la vitesse de rotation d'un segment.
        % Omega= dA/dt*At. Cette matrice est égale à la dérivée de la
        % matrice homogène multipliée par la transposée de cette même
        % matrice homogène.
        Omega(:,:,i_frame)=MH_derive.(nom_seg)(:,:,i_frame) * Struct_MH.(nom_seg).MH(1:3,1:3,i_frame)';
        % Matrice des vitesses de rotation
        % Omega=[   0    -omegaZ   omegaY]
        %       [ omegaZ    0     -omegaX]
        %       [-omegaY omegaX      0   ]
        vit_ang.(nom_seg)(i_frame,1)=1/2*(Omega(3,2,i_frame)-Omega(2,3,i_frame))*180/pi; % On identifie terme à terme
        vit_ang.(nom_seg)(i_frame,2)=1/2*(Omega(1,3,i_frame)-Omega(3,1,i_frame))*180/pi; % Et on change en degrés
        vit_ang.(nom_seg)(i_frame,3)=1/2*(Omega(2,1,i_frame)-Omega(1,2,i_frame))*180/pi;
    end
    for i=1:3
        vit_ang.(nom_seg)(:,i)=fct_moyenne_glissante(vit_ang.(nom_seg)(:,i),11);
    end
    
    if arg_plot==1 % Affichage des courbes
        str=['Vitesse angulaire de ',nom_seg];
        figure('Name',str,'NumberTitle','off') 
        hold on

        plot(time,vit_ang.(nom_seg)(:,1),time,vit_ang.(nom_seg)(:,2),time,vit_ang.(nom_seg)(:,3))

        xlabel('Time (s)')
        ylabel('Vitesse de rotation (°/s)')
        strcat
        legend(['Vitesse de Rotation de ',nom_seg,' autour de X'],['Vitesse de Rotation de ',nom_seg,' autour de Y'],['Vitesse de Rotation de ',nom_seg,' autour de Z'],'Location','northwest')
        hold off
    end
end
