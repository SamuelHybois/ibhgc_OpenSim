function angles=axemobile(M,sequence)

switch sequence
    case 'xyz'
        angles = axemobile_xyz(M);
    case 'xzy'
        angles = axemobile_xzy(M);
    case 'yxz'
        angles = axemobile_yxz(M);
    case 'yzx'
        angles = axemobile_yzx(M);
    case 'zxy'
        angles = axemobile_zxy(M);
    case 'zyx'
        angles = axemobile_zyx(M);
end