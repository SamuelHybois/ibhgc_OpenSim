function [res]= Norm3D(Array)
% Calcul de la norm pour toutes les composantes de la 3ème dimension
% Entrée :
%         * A 3D array (3,1,z)
% Sortie :
%         * A 3D array (1,1,z)
% Related function : calcul_position_CoR_dans_R0
%%%% Puchaud Pierre %%%

nb_3D=size(Array,3);
res=zeros(1,1,nb_3D);
for i =1:nb_3D
    res(1,1,i)=norm(Array(:,:,i));
end

end