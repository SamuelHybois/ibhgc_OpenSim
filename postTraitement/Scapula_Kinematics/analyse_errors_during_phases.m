function analyse_errors_during_phases(cur_activity,Err_Axe,Err_Angle,Err_Translation,Err_Euler,euler_seq)
                    
% Phase identification
if strfind(cur_activity,'Prop'), phase_leg = {'Push','Recovery'};
elseif strfind(cur_activity,'Basket'), phase_leg = {'Arm','Throw'};
elseif strfind(cur_activity,'Basket'), phase_leg = {'Arm','Throw','Follow'};
end, nb_phase = length(phase_leg);

% Translation (homogeneous matrix)
if ~isempty(Err_Translation), figure, 
    for iphase=1:nb_phase
       
    end 
end

% Euler angles (homogeneous matrix)
if ~isempty(Err_Euler), figure, isubplot=0;
    try euler_seq; catch euler_seq = 'YXZ'; end
    nb_angle = length(euler_seq);
    for iang = 1:nb_angle
        for iphase = 1:nb_phase
           
        end
    end
end 

% Angle (quaternion)
if ~isempty(Err_Angle), figure,
    for iphase=1:nb_phase
       
    end
end

% Axis coordinates (quaternion)
if ~isempty(Err_Axe), figure, isubplot=0;
axe_seq = 'XYZ';
nb_axes = length(axe_seq);
    for iang = 1:nb_axes
        for iphase = 1:nb_phase
            
        end
    end
end 

end %function