function [Wrench_PFF]=StructureWrenchTest(myc3d_file_path,M_R0R1,num_plat)
% matrice de transformation globale entre les donn�es Vicon et les donn�es
% de sortie
% exemples :
% M_R0R1=eye(3,3);
% M_R0R1 = [[-1,0,0]',[0,0,1]',[0,1,0]'];  %matrice de passage entre rep�re Vicon et rep�re OpenSim
% num_plat{1}='3';
% num_plat{2}='4';
% % hypoth�se
% on fait l'hypoth�se que les unit�s sont identiques sur les trois composantes


% On r�cup�re les donn�es plate forme
[acq, ~, ~] = btkReadAcquisition( myc3d_file_path);
[Analogs, ~]= btkGetAnalogs(acq);
[forceplates, forceplatesInfo] = btkGetForcePlatforms(acq); % on ne prend pas les plate-forme ici car on a modifi� les analogs pour offset (est-ce pris en compte dans forceplate ?)


for i_plat=1:size(num_plat,2)
    numPFF=num_plat{i_plat};
    cur_PFF=['PFF' num2str(numPFF)];
    [Wrench]  = PFF_Wrench_ROS(Analogs,forceplates,numPFF,M_R0R1);
    
    list_info=fieldnames(forceplatesInfo(i_plat).units);
    cur_unit=forceplatesInfo(i_plat).units.(list_info{end});
%     cur_unit=forceplatesInfo(i_plat).units.(['Mx' num2str(i_plat)]); % on fait l'hypoth�se que les unit�s sont identiques sur les trois composantes
    if strcmp(cur_unit,'Nmm')
    % faire test si unnit� =mm
    Wrench(:,4:6)=Wrench(:,4:6)/1000;
    end
    Wrench_PFF.(cur_PFF) = Wrench;
end



end

