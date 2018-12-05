function visualisation_plan( N,P,ampl,increment )
% fonction permettant de visualiser un plan dans Matlab.
% le plan est défini par sa normale et un point.

if isempty(increment)
    increment=1/50;
end

% équation cartésienne du type : ax+by+cz+d=0
% avec N=[a;b;c]

d=-dot(N,P);

x=-ampl/2:increment*ampl:ampl/2;
x=x';
y=-ampl/2:increment*ampl:ampl/2;
y=y';

z=zeros(size(x,1),size(y,1));
for i=1:size(x,1)
    cur_x=x(i);
    for j=1:size(y,1)
        cur_y=y(i);
        z(i,j)=1/N(3)*(-d-N(1)*cur_x-N(2)*cur_y);
    end
end

mesh(x,y,z,'edgecolor','k');

end

