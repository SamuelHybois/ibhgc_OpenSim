function plot_meanerror_during_phases(cur_activity,Err_Axe,Err_Angle,Err_Translation,Err_Euler,legend_compare,euler_seq)
                    
% Paramètres figures
alpha=0.2;
nb_model=size(Err_Angle,4);
col=hsv(nb_model);
X=0:100;
    
% Phase identification
if strfind(cur_activity,'Prop'), phase_leg = {'Push','Recovery'};
elseif strfind(cur_activity,'Basket'), phase_leg = {'Arm','Throw'};
elseif strfind(cur_activity,'Basket'), phase_leg = {'Arm','Throw','Follow'};
end, nb_phase = length(phase_leg);

% Angle (quaternion)
if ~isempty(Err_Angle), figure,
    for iphase=1:nb_phase
        for imodel=1:nb_model
            Err_Angle_mean=squeeze(nanmean(Err_Angle(:,:,iphase:nb_phase:end,imodel),3));
            Err_Angle_std=squeeze(nanstd(Err_Angle(:,:,iphase:nb_phase:end,imodel),1,3));           
            subplot(1,nb_phase,iphase),
            boundedline(X,Err_Angle_mean',Err_Angle_std','transparency',alpha,'cmap',col(imodel,:)),
        end
    end
    legend(legend_compare)
    title(['Angle' cur_activity(1:end-8) phase_leg(iphase)])
end

% Axis coordinates (quaternion)
if ~isempty(Err_Axe), figure, isubplot=1;
    axe_seq = 'XYZ';
    axe_leg = {axe_seq(1),axe_seq(2),axe_seq(3)}; 
    nb_axes = length(axe_leg);
    for iaxis = 1:nb_axes
        for iphase = 1:nb_phase
            for imodel=1:nb_model
                Err_Axe_mean=squeeze(nanmean(Err_Axe(:,iaxis,iphase:nb_phase:end,imodel),3));
                Err_Axe_std=squeeze(nanstd(Err_Axe(:,iaxis,iphase:nb_phase:end,imodel),1,3));
                subplot(nb_axes,nb_phase,isubplot), 
                boundedline(X,Err_Axe_mean',Err_Axe_std','transparency',alpha,'cmap',col(imodel,:)), 
            end
        legend(legend_compare)
        title(['Euler ' axe_leg(iaxis) ' ' phase_leg(iphase)])
        isubplot=isubplot+1;
        end
    end
end

% Translation (homogeneous matrix)
if ~isempty(Err_Translation), figure,
    for iphase=1:nb_phase
        for imodel=1:nb_model
           Err_Trans_mean=squeeze(nanmean(Err_Translation(:,:,iphase:nb_phase:end,imodel),3));
           Err_Trans_std=squeeze(nanstd(Err_Translation(:,:,iphase:nb_phase:end,imodel),1,3));
           subplot(1,nb_phase,iphase),
           boundedline(X,Err_Trans_mean',Err_Trans_std','transparency',alpha,'cmap',col(imodel,:)), 
        end   
    end
    legend(legend_compare)
    title(['Translation' cur_activity(1:end-8) phase_leg(iphase)])
end

% Euler angles (homogeneous matrix)
if ~isempty(Err_Euler), figure, isubplot=1;
    if ~exist('euler_seq','var'),euler_seq = 'YXZ'; end
    angle_leg = {euler_seq(1),euler_seq(2),euler_seq(3)}; nb_angle = length(angle_leg);
    for iang = 1:nb_angle
        for iphase = 1:nb_phase
            for imodel=1:nb_model
                Err_Euler_mean=squeeze(nanmean(Err_Euler(:,iang,iphase:nb_phase:end,imodel),3));
                Err_Euler_std=squeeze(nanstd(Err_Euler(:,iang,iphase:nb_phase:end,imodel),1,3));
                subplot(nb_angle,nb_phase,isubplot), 
                boundedline(X,Err_Euler_mean',Err_Euler_std','transparency',alpha,'cmap',col(imodel,:)), 
            end
        legend(legend_compare)
        title(['Euler ' angle_leg(iang) ' ' phase_leg(iphase)])
        isubplot=isubplot+1;
        end
    end
end 

end %function