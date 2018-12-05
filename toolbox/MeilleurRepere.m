function BestMarkers = MeilleurRepere(Markers)
% Sauret Christophe - 04 juin 2018
% trouve le meilleur set de 3 ou 4 marqueurs permettant de former un repère quelconque

% Sortie: BestMarkers = [a,b,c] ou [a,b,c,d]; a,b,c,d sont les numéros des markers dans Markers. Les deux premiers marqueurs donnent le premier axe (X) et les deux derniers le second axe pour calculer Y orthogonal à ces 2 vecteurs et en déduire Z.
% Entrée : Markers = [Marker_1; Marker_2; Marker_3; Marker_4; ...]; Les coordonnées des marqueurs sont en lignes

%%
Nb_markers = size(Markers,1);
% On cherche le vecteur avec la plus grande normme

X = repmat(Markers(:,1),[1,4]);
Y = repmat(Markers(:,2),[1,4]);
Z = repmat(Markers(:,3),[1,4]);

N = ((X-X').^2 + (Y-Y').^2 + (Z-Z').^2);
[row,col] =find(triu(N)==max(max(triu(N))));
M1 = row;
M2 = col;

% On cherche le troisième marker qui permet d'avoir le produit vectoriel le plus important
% on teste toutes les combinaisons possibles
C = combnk([1,2,3,4],2);
nb_comb = size(C,1);

prod_vect_V1V2 = zeros(nb_comb,1);
V1 = Markers(M2,:)-Markers(M1,:);

for i_comb = 1:size(C,1)
    M3 = C(i_comb,1); % M3 peut être identique à M1 ou M2
    M4 = C(i_comb,2); % M4 peut être identique à M1 ou M2
    V2 = Markers(M4,:)-Markers(M3,:);
    
    prod_vect_V1V2(i_comb,1) = norm(cross(V1,V2));
end

% on cherche les marqueurs qui donnent le produit vectoriel dont la norme est la plus élevée
ind = find(prod_vect_V1V2==max(prod_vect_V1V2));
% on prend le premier

BestMarkers = [M1,M2, setdiff(C(ind(1),:),[M1,M2])];

end