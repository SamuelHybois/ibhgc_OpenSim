% __________________________________________________________________________________________
%
% function [I,J] = find2(A,B,rech) 
% ou       Liste = find2(A,B,rech)
%
% Extension de la fonction find permettant de rechercher des �quivalence entre tableau :
%
% A : tableau dans lequel on recherche les �l�ments de B
% B : liste des valeurs � rechercher dans le tableau A
% rech : type de recherche '==' ou '~=' (d�faut : '==') ;
%
% Liste : emplacement des donn�es de B dans A suivant rech
% [I,J] : donne les lignes et les colonnes 
%
%____________________________________________________________________________________________
%
function [I,J] = find2(A,B,rech) ;
%
% 0. traitement des variables d'entr�es
%
% a) Pour le type de comparaison
%
if nargin == 2 ;
    rech = '==' ;
end
%
% b) mise en forme de vecteur ligne pour B
%
[n,m] = size(B) ; % ---> Deminsion du vecteur B
B = reshape(B,1,n*m) ;
%
% 1. Initialisation des variables de sortie
%
I = [] ; J = [] ;
%
% 2. Recherche des valeurs de B dans A
%
for tx = 1:length(B) ;
    % -------------------------------------------------
    % ___ Pour la valeur donn�e ___
    if (nargout == 2)&strcmp(rech,'==') ;
        % ---> Deux variables demand�es en sortie :
        [listex,listey] = find(A == B(tx)) ;
        I = [I;listex] ; J = [J;listey] ;
        % ---------------------------------------------
    elseif (nargout <= 1)|((nargout == 2)&strcmp(rech,'~=')) ;
        % ---> Deux variables demand�es en sortie :
        listex = find(A == B(tx)) ;
        I = [I;listex] ;
    end
    % ---------------------------------------------
end
%
% 3. Traitement du cas '~='
%
if strcmp(rech,'==') ;
    % ---> Il n'y a pas de modifications � apporter
elseif strcmp(rech,'~=') ;
    A(I) = NaN ;
    if nargout == 2 ;
        [I,J] = find(isnan(A)==0) ;
    elseif nargout <= 1 ;
        I = find(isnan(A)==0) ;
    end
else
    error('Comparaison im�possible') ;
end
%
% _ Fin de la fonction _