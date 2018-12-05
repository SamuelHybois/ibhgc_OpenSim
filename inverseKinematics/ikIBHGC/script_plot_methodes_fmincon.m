figure ;
subplot(2,2,1)
plot(coordGeneralisee(1:100,7))
hold on
% plot(RES_MATLAB.coordGeneralisee(1:300,7))
plot((pi/180)*RES_OS.hip_flexion_r(1:100))
plot(RES_dqe3.coordGeneralisee(1:100,7))
legend('NOW','OpenSim','10e-3')
title('hip flexion')

subplot(2,2,2)
plot(coordGeneralisee(:,8))
hold on
% plot(RES_MATLAB.coordGeneralisee(1:300,8))
plot((pi/180)*RES_OS.hip_adduction_r(1:300))
title('hip adduction')

subplot(2,2,3)
plot(coordGeneralisee(1:300,9))
hold on
% plot(RES_MATLAB.coordGeneralisee(1:300,9))
plot((pi/180)*RES_OS.hip_rotation_r(1:300))
title('hip rotation')

subplot(2,2,4)
plot(coordGeneralisee(1:300,11))
hold on
% plot(RES_MATLAB.coordGeneralisee(1:300,11))
plot((pi/180)*RES_OS.knee_angle_r(1:300))
title('knee angle')
