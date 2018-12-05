function plot_errors_during_phases(cur_activity,phase_leg,Err_Axe,Err_Angle,Err_Translation,Err_Euler,euler_seq)
                    
% Phase identification
nb_phase = length(phase_leg);

% Translation (homogeneous matrix)
if ~isempty(Err_Translation), figure, 
    for iphase=1:nb_phase
        subplot(1,nb_phase,iphase),
        plot(squeeze(Err_Translation(:,1,iphase:nb_phase:end))), 
        title(['Translation' cur_activity(1:end-8) phase_leg(iphase)])
        axis([0 100 0 0.03])
    end
end

% Euler angles (homogeneous matrix)
if ~isempty(Err_Euler), figure, isubplot=0;
    try euler_seq; catch euler_seq = 'YXZ'; end
    angle_leg = {euler_seq(1),euler_seq(2),euler_seq(3)}; nb_angle = length(angle_leg);
    for iang = 1:nb_angle
        for iphase = 1:nb_phase
            isubplot=isubplot+1;
            subplot(nb_angle,nb_phase,isubplot), 
                plot(squeeze(Err_Euler(:,iang,iphase:nb_phase:end))), 
                title(['Euler ' angle_leg(iang) ' ' phase_leg(iphase)])
                axis([0 100 -10 10])
        end
    end
end 

% Angle (quaternion)
if ~isempty(Err_Angle), figure,
    for iphase=1:nb_phase
        subplot(1,nb_phase,iphase),
        plot(squeeze(Err_Angle(:,iphase:nb_phase:end))), 
        title(['Angle' cur_activity(1:end-8) phase_leg(iphase)])
        axis([0 100 0 20])
    end
end

% Axis coordinates (quaternion)
if ~isempty(Err_Axe), figure, hold on, isubplot=0;
    Err_Axe_contrib = zeros(size(Err_Axe));
    Err_Axe_contrib (:,1,:) = Err_Axe(:,1,:).*Err_Axe(:,1,:) *100 ;
    Err_Axe_contrib (:,2,:) = Err_Axe(:,2,:).*Err_Axe(:,2,:)* 100 + Err_Axe_contrib (:,1,:);
    Err_Axe_contrib (:,3,:) = Err_Axe(:,3,:).*Err_Axe(:,3,:)* 100 + Err_Axe_contrib (:,2,:);
    col=[1 0 0;0 1 0;0 0 1];
    axe_seq = 'XYZ';
    axe_label = {axe_seq(1),axe_seq(2),axe_seq(3)}; 
    nb_axes = length(axe_seq);
    for iphase = 1:nb_phase
        for iaxe=1:nb_axes
            subplot(1,nb_phase,iphase), hold on
            plot(squeeze(Err_Axe_contrib(:,iaxe,iphase:nb_phase:end)),'Color',col(iaxe,:)), 
        end
        title(['Axis ' phase_leg(iphase)])
        legend(axe_label);
        axis([0 100 0 100])
    end
end 

end %function