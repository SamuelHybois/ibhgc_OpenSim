function [Wrench_ROS]  = PFF_Wrench_ROS(Analogs, forceplatesInfo,numPFF,M_R0R1)

%M_R0R1 : matrice de rotation (3*3) de ROS dans RVicon


Champs= fieldnames(Analogs);
if sum(strcmp(Champs,'Force_Fx1'))==1
    Labels_Analogs = {['Force_Fx',num2str(numPFF)],['Force_Fy',num2str(numPFF)],['Force_Fz',num2str(numPFF)],['Moment_Mx',num2str(numPFF)],['Moment_My',num2str(numPFF)],['Moment_Mz',num2str(numPFF)]};
else
    Labels_Analogs = {['Fx',num2str(numPFF)],['Fy',num2str(numPFF)],['Fz',num2str(numPFF)],['Mx',num2str(numPFF)],['My',num2str(numPFF)],['Mz',num2str(numPFF)]};
end

%Wrench_ROS = zeros(size(Analogs.( Labels_Analogs{1}),1),6);

% définition du repère plate-forme dans RVicon

% PFF 1
try
    Corners = forceplatesInfo(str2double(numPFF)).corners;
    Origin = forceplatesInfo(str2double(numPFF)).origin;
catch
    Corners = forceplatesInfo(numPFF).corners;
    Origin = forceplatesInfo(numPFF).origin;
end
Centre_Corner = mean(Corners,2);
X = Corners(:,1)-Corners(:,2); X=X/norm(X);
Y = Corners(:,2)-Corners(:,3); Y=Y/norm(Y);
Z = cross(X,Y);
O = Centre_Corner - Origin;

MH_RVicon_RPFF.PFF = [X,Y,Z,O;0,0,0,1];
MH_ROS_RPFF.PFF = [M_R0R1,[0,0,0]';0,0,0,1] \ MH_RVicon_RPFF.PFF;



Force_PFF_ROS = (MH_ROS_RPFF.PFF(1:3,1:3)*[Analogs.(Labels_Analogs{1}),Analogs.(Labels_Analogs{2}),Analogs.(Labels_Analogs{3})]')';
% on remplace les 0 (erreurs) par interpolation et on lisse les
% données
for i =1:3
    try
        time = (1:1:size(Force_PFF_ROS,1))';
        time2 = time(Force_PFF_ROS(:,i)~=0);
        Force_PFF_ROS(:,i) = interp1(time2,Force_PFF_ROS(time2,i),time,'linear');
        % lissage
        Force_PFF_ROS(:,i) = fct_moyenne_glissante(Force_PFF_ROS(:,i),5);
    catch
    end
end


% moment dans la base de ROS mais par de changement d'origine
Moment_PFF_ROS = (MH_ROS_RPFF.PFF(1:3,1:3)*[Analogs.(Labels_Analogs{4}),Analogs.(Labels_Analogs{5}),Analogs.(Labels_Analogs{6})]')';
% on remplace les 0 (erreurs) par interpolation et on lisse les
% données
for i =1:3
    try
        time = (1:1:size(Force_PFF_ROS,1))';
        time2 = time(Force_PFF_ROS(:,i)~=0);
        Moment_PFF_ROS(:,i) = interp1(time2,Moment_PFF_ROS(time2,i),time,'linear');
        % lissage
        Moment_PFF_ROS(:,i) = fct_moyenne_glissante(Moment_PFF_ROS(:,i),5);
    catch
    end
end

% expression des moments à l'origine de ROS et dans la base de ROS
O_OS = MH_ROS_RPFF.PFF(1:3,4);
Mskew = [0, -O_OS(3), O_OS(2); O_OS(3),0,-O_OS(1); -O_OS(2), O_OS(1),0];
Moment_PFF_ROS = (Moment_PFF_ROS' + Mskew * Force_PFF_ROS')';

Wrench_ROS = [Force_PFF_ROS, Moment_PFF_ROS];
end