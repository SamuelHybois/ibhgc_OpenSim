function [seq]=trouver_seq(axe1,axe2,axe3)
seq=[];
if find(axe1)==1
    seq='x';
elseif find(axe1)==2
    seq='y';
elseif find(axe1)==3
    seq='z';
else
    disp('erreur de récupération de séquence')
end

if find(axe2)==1
    seq=[seq 'x'];
elseif find(axe2)==2
    seq=[seq 'y'];
elseif find(axe2)==3
    seq=[seq 'z'];
else
    disp('erreur de récupération de séquence')
end

if find(axe3)==1
    seq=[seq 'x'];
elseif find(axe3)==2
    seq=[seq 'y'];
elseif find(axe3)==3
    seq=[seq 'z'];
else
    disp('erreur de récupération de séquence')
end



end
