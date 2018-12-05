function [M1,M2,M3] = Rotations2Matrix(ax,ay,az,sequence)

% Décompose en axes mobiles vers matrixe de rotation

switch sequence
    case 'xyz'
        [R1,R2,R3]=Rotations2Matrix_xyz(ax,ay,az);
        %Not coded
        %     case 'xzy'
        %         [rx,ry,rz]=axe_mobile_xzy(M);
        %     case 'yxz'
        %         [rx,ry,rz]=axe_mobile_yxz(M);
        %     case 'yzx'
        %         [rx,ry,rz]=axe_mobile_yzx(M);
        %     case 'zxy'
        %         [rx,ry,rz]=axe_mobile_zxy(M);
        %     case 'zyx'
        %         [rx,ry,rz]=axe_mobile_zyx(M);
end

if nargout==1
    M1 = R1*R2*R3;
else
    M1=R1;
    M2=R2;
    M3=R3;
end

end

