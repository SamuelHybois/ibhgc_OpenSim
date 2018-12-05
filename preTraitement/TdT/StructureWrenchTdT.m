function [Wrench_PFF]=StructureWrenchTdT(myc3d_file_path,M_R0R1,num_plat)
% matrice de transformation globale entre les données Vicon et les données
% de sortie
% exemples :
% % hypothèse
% on fait l'hypothèse que les unités sont identiques sur les trois composantes


% On récupère les données plate forme
[acq, ~, ~] = btkReadAcquisition( myc3d_file_path);
[Analogs, ~]= btkGetAnalogs(acq);
[forceplates, forceplatesInfo] = btkGetForcePlatforms(acq); % on ne prend pas les plate-forme ici car on a modifié les analogs pour offset (est-ce pris en compte dans forceplate ?)


for i_plat=1:size(num_plat,2)
    numPFF=num_plat{i_plat};
    cur_PFF=['PFF' num2str(numPFF)];
    [Wrench]  = PFF_Wrench_ROS(Analogs,forceplates,numPFF,M_R0R1);
    
    list_info=fieldnames(forceplatesInfo(i_plat).units);
    cur_unit=forceplatesInfo(i_plat).units.(list_info{1});
%     cur_unit=forceplatesInfo(i_plat).units.(['Mx' num2str(i_plat)]); % on fait l'hypothèse que les unités sont identiques sur les trois composantes
    if strcmp(cur_unit,'Nmm')
    % faire test si unnité =mm
    Wrench(:,4:6)=Wrench(:,4:6)/1000;
    end
    Wrench_PFF.(cur_PFF) = Wrench;
end



end

