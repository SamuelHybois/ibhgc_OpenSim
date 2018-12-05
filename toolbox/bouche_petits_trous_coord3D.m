function Data_output = bouche_petits_trous_coord3D(Data,n_mg,taille_trou,nb_min_points)

%% ############################################################################################################################################
% Sauret Christophe, IBHGC
% 05/05/2017

% Data: vecteur (n*3) contenant les coordonn�es 3D
% n_mg : taille de la fen�tre pour le lissage pr�alable des donn�es par moyenne glissante (doit �tre impair, mettre � 1 pour ne pas lisser)
% taille_trou : taille maximale des trous � boucher
% nb_min_points : nb minimal de points � connaitre pour faire l'interpolation.
% ############################################################################################################################################

%%
% 1) lissage
for i_col = 1:3
    Data(:,i_col)=fct_moyenne_glissante(Data(:,i_col),n_mg);
end

% 2) interpolation si le trou est inf�rieur � taille_trou et si le nombre de points connus est sup�rieur ou �gal � nb_min_trous
Data= permute(Data,[3,2,1]);
Data_interp =  interpol_mkrs_NaN_t_V2(Data,nb_min_points,taille_trou);
Data_output = permute(Data_interp,[3,2,1]);
end


