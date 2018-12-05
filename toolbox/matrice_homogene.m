function RT = matrice_homogene(angle,origin,seq)

a = angle;
t = origin;

if nargin<3, seq='xyz'; end %default

c1=cos(a(1));
c2=cos(a(2));
c3=cos(a(3));
s1=sin(a(1));
s2=sin(a(2));
s3=sin(a(3));

switch seq
    
    case 'xyz'
    RT = [c2*c3             -c2*s3              s2      -t(1);...                
          s1*s2*c3+c1*s3    -s1*s2*s3+c1*c3     -c2*s1  -t(2);...
          -c1*s2*c3+s1*s3   c1*s2*s3+s1*c3      c1*c2   -t(3);...
          0                 0                   0           1];
  
    case 'yzx'
    RT = [c2*c3     -c1*c2*s3+s1*s2     s1*c2*s3+c1*s2  t(1);...
          s3        c1*c3               -s1*c3          t(2);...
          -s2*c3    s1*c2+c1*s2*s3      -s1*s2*s3+c1*c2 t(3);...
          0         0                   0                  1];
    
    case 'xzy'
        RT = 'undefined angle sequence';
        
    case 'yxz'
        RT = 'undefined angle sequence';
        
    case 'zxy'
        RT = 'undefined angle sequence';
        
    case 'zyx'
        RT = 'undefined angle sequence';
        
end
  
end