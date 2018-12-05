% #########################################################################
%
% Fonction de calcul de RMSE
% En entrée, les coordonnées réelles et calculées ainsi que le nombre de
% frame
% En sortie, un struct avec le RMSE par marqueur, par frame, et total
%
% ##########################################################################

function [RMSE_global,Table_RMSE,RMSE_partiel]=calcul_RMSE_dual_par_body(coord_reel,coord_virt,bodies,st_protocole)

RMSE_global=struct;
nom_marqueurs_RMSE_virt=fieldnames(coord_virt);
nom_marqueurs_RMSE_reel=fieldnames(coord_reel);
mark_commun=ismember(nom_marqueurs_RMSE_virt,nom_marqueurs_RMSE_reel);
mark_commun=nom_marqueurs_RMSE_virt(mark_commun);
nb_frame=size(coord_virt.(mark_commun{1}),1);
nb_marqueurs=size(mark_commun,1);

%% Calcul de la distance entre tous les marqueurs pour chaque frame
diff_norm_car(nb_frame,nb_marqueurs)=0;

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

b = fieldnames(bodies);
nb_b = length(b);
Table_RMSE = struct;
for i_body =1:nb_b
    cur_b = b{i_body};
    clear diff_norm_car
    Table_RMSE.Frame{1,i_body} =cur_b;
    Table_RMSE.Total{i_body,1} =cur_b;
    
    if ~isempty(bodies.(cur_b))
        list_mrk_body=fieldnames(bodies.(cur_b));
        mark_body=ismember(mark_commun,list_mrk_body);
        mark_body=mark_commun(mark_body);
        
        for i_frame=1:nb_frame
            for i_marker=1:length(mark_body)
                %%%%RMSE tot%%%
                nom_mrk_RMSE=mark_body{i_marker};
                diff_norm_car(i_frame,i_marker)=norm(coord_reel.(nom_mrk_RMSE)(i_frame,:)-coord_virt.(nom_mrk_RMSE)(i_frame,:)) ;
                diff_norm_car(i_frame,i_marker)=diff_norm_car(i_frame,i_marker).^2;
                if i_frame==nb_frame
                    RMSE_global.(cur_b).Marker.(nom_mrk_RMSE)=sqrt(nanmean(diff_norm_car(:,i_marker)));
                    
                    %                 %%%%RMSE 25% par 25% %%%
                    if ~isnan(RMSE_global.(cur_b).Marker.(nom_mrk_RMSE))
                    Vq = interp1(1:nb_frame,diff_norm_car(:,i_marker),1:nb_frame/200:nb_frame+1,'pchip');
                    
                    RMSE_partiel.(cur_b).Marker.(nom_mrk_RMSE).seq_0_25 = sqrt(nanmean(Vq(1:51)));
                    RMSE_partiel.(cur_b).Marker.(nom_mrk_RMSE).seq_25_50 = sqrt(nanmean(Vq(51:101)));
                    RMSE_partiel.(cur_b).Marker.(nom_mrk_RMSE).seq_50_75 = sqrt(nanmean(Vq(101:151)));
                    RMSE_partiel.(cur_b).Marker.(nom_mrk_RMSE).seq_75_100 = sqrt(nanmean(Vq(151:201)));
                    
                    else
                    RMSE_partiel.(cur_b).Marker.(nom_mrk_RMSE).seq_0_25 = nan;
                    RMSE_partiel.(cur_b).Marker.(nom_mrk_RMSE).seq_25_50 = nan;
                    RMSE_partiel.(cur_b).Marker.(nom_mrk_RMSE).seq_50_75 = nan;
                    RMSE_partiel.(cur_b).Marker.(nom_mrk_RMSE).seq_75_100 = nan;
                    end
                end
            end
            
            % RMSE par body pour chaque frame
            RMSE_tot =0;
            poids_mrk_tot = 0;
            for i_m = 1:length(mark_body)
                nom_mrk_RMSE=mark_body{i_m};
                poids_mrk =str2double(st_protocole.POIDS.(nom_mrk_RMSE){1,2});
                RMSE_tot = RMSE_tot + sqrt(diff_norm_car(i_frame,i_m))*poids_mrk;  % Méthode 1 : moyenne sur chaque frame pour tous les marqueurs puis sur tous les marqueurs
                poids_mrk_tot = poids_mrk_tot + poids_mrk;
            end
            RMSE_global.(cur_b).Frame{i_frame,1} = RMSE_tot/poids_mrk_tot;
            Table_RMSE.Frame{i_frame+1,i_body} = RMSE_tot/poids_mrk_tot;
            
        end
        
        
        
        % RMSE par body pour toutes les frames
        RMSE_tot =0;
        poids_mrk_tot = 0;
        for i_m = 1:length(mark_body)
            nom_mrk_RMSE=mark_body{i_m};
            if  ~isnan(RMSE_global.(cur_b).Marker.(nom_mrk_RMSE))
            poids_mrk =str2double(st_protocole.POIDS.(nom_mrk_RMSE){1,2});
            RMSE_tot = RMSE_tot + RMSE_global.(cur_b).Marker.(nom_mrk_RMSE)*poids_mrk;  % Méthode 1 : moyenne sur chaque frame pour tous les marqueurs puis sur tous les marqueurs
            poids_mrk_tot = poids_mrk_tot + poids_mrk;
            end
        end
        RMSE_global.(cur_b).Total.Methode1 = RMSE_tot/poids_mrk_tot;
        Table_RMSE.Total{i_body,2} =RMSE_tot/poids_mrk_tot;
        
        
        seq={'seq_0_25','seq_25_50','seq_50_75','seq_75_100'};
        for i_seq = 1:length(seq)
            cur_seq=seq{i_seq};
            RMSE_tot =0;
            poids_mrk_tot = 0;
            for i_m = 1:length(mark_body)
                nom_mrk_RMSE=mark_body{i_m};
                if  ~isnan(RMSE_partiel.(cur_b).Marker.(nom_mrk_RMSE).(cur_seq))
                poids_mrk =str2double(st_protocole.POIDS.(nom_mrk_RMSE){1,2});
                RMSE_tot = RMSE_tot + RMSE_partiel.(cur_b).Marker.(nom_mrk_RMSE).(cur_seq)*poids_mrk;  % Méthode 1 : moyenne sur chaque frame pour tous les marqueurs puis sur tous les marqueurs
                poids_mrk_tot = poids_mrk_tot + poids_mrk;
                end
            end
            RMSE_partiel.(cur_b).Total.(cur_seq) = RMSE_tot/poids_mrk_tot;
        end
        
    end
end


end
