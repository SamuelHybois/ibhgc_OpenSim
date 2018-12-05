% #########################################################################
%
% Fonction de calcul de RMSE
% En entrée, les coordonnées réelles et calculées ainsi que le nombre de
% frame
% En sortie, un struct avec le RMSE par marqueur, par frame, et total
%
% ##########################################################################

function [RMSE_global,diff_norm_car]=calcul_RMSE_dual(coord_reel,coord_virt)

RMSE_global=struct;
nom_marqueurs_RMSE_virt=fieldnames(coord_virt);
nom_marqueurs_RMSE_reel=fieldnames(coord_reel);
mark_commun=ismember(nom_marqueurs_RMSE_virt,nom_marqueurs_RMSE_reel);
mark_commun=nom_marqueurs_RMSE_virt(mark_commun);
nb_frame=size(coord_virt.(mark_commun{1}),1);
nb_marqueurs=size(mark_commun,1);

%% Calcul de la distance entre tous les marqueurs pour chaque frame
diff_norm_car=zeros(nb_frame,nb_marqueurs);
for i_frame=1:nb_frame
    for i_marker=1:length(mark_commun)
        nom_mrk_RMSE=mark_commun{i_marker};
        diff_norm_car(i_frame,i_marker)=norm(coord_reel.(nom_mrk_RMSE)(i_frame,:)-coord_virt.(nom_mrk_RMSE)(i_frame,:));
        diff_norm_car(i_frame,i_marker)=diff_norm_car(i_frame,i_marker).^2;
        RMSE_global.Marker.(nom_mrk_RMSE)=sqrt(nanmean(diff_norm_car(:,i_marker)));
        RMSE_global.Frame(1,i_frame)=sqrt(nanmean(diff_norm_car(i_frame,:)));
    end
end

RMSE_global.Total.Methode1=sqrt(nanmean(nanmean(diff_norm_car,1))); % Méthode 1 : moyenne sur chaque frame pour tous les marqueurs puis sur tous les marqueurs
RMSE_global.Total.Methode2=sqrt(nanmean(nanmean(diff_norm_car,2))); % Méthode 2 : moyenne sur chaque marqueur pour toutes les frames puis sur toutes les frames

end
