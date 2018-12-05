function  [Err_Translation,Err_Axe_Angle,Err_Euler] = scapula_kinematics_errors(TRTH_test,TRTH_ref,size_interp,sign)
% This function allows to compute kinematics errors for different
% rotational parameters and translation
%                                                                  Diane H
%                                                                 29/03/18

nb_frame = size(TRTH_ref,3);
Err_Translation(nb_frame,1) = 0;
Err_Axe(nb_frame,3)         = 0;
Err_Angle(nb_frame,1)       = 0;
Err_Euler_YXZ(nb_frame,3)   = 0;

for iframe = 1:nb_frame
    % RT matrix from modelled to measured kinematics
    TR_Err = inv(TRTH_ref(:,:,iframe))*TRTH_test(:,:,iframe);    
 
    % Errors in translation from RT matrix
    Err_Translation(iframe) = norm(TRTH_test(1:3,4,iframe)-TRTH_ref(1:3,4,iframe));
    
    % Errors on Axis and Angle from quaternion
    q = mat2quat (TR_Err(1:3,1:3));
    Err_Angle(iframe) = 2*acosd(round(q(1),4));
    Err_Axe(iframe,:) = (q(2:4) / sqrt(1-q(4)*q(4))) / norm(q(2:4) / sqrt(1-q(4)*q(4)));
    
    % Errors on Euler angles from sequence YXZ
    Err_Euler_YXZ(iframe,1) = sign*atand(TR_Err(1,3)/TR_Err(3,3)); %Y
    Err_Euler_YXZ(iframe,2) = -pi/2*(sign-1)-sign*asind(TR_Err(2,3)); %X
    Err_Euler_YXZ(iframe,3) = atand(TR_Err(2,1)/TR_Err(2,2));        %Z                
end

    % Interpolation on 100 frames for comparison
    Err_Translation=interp1(linspace(0,size_interp,nb_frame),Err_Translation,0:1:size_interp-1,'spline');
    Err_Axe_Angle=interp1(linspace(0,size_interp,nb_frame),[Err_Axe unwrap(Err_Angle,90)],0:1:size_interp-1,'spline');
    Err_Euler=interp1(linspace(0,size_interp,nb_frame),unwrap(Err_Euler_YXZ,90),0:1:size_interp-1,'spline');

end