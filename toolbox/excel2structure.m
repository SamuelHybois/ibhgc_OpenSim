function [st_excel]=excel2structure(fichier_excel)
% créé une structure à partier d'un fichier excel : les noms champs de la
% structure sont dans la première colonne, les champs de second ordre sont
% les en-tete de chaque colonne.

[~,~,data_xls]=xlsread(fichier_excel);

 colonne1=data_xls(:,1);
 ligne1=data_xls(1,:);
 st_excel=struct;
 for i_ligne=2:size(data_xls,1)
     cur_ligne=colonne1{i_ligne};
     for i_colonne=2:size(data_xls,2)
         cur_colonne=ligne1{i_colonne};
         if max(isnan(cur_colonne))~=1 && max(isnan(cur_ligne))~=1 
             st_excel.(cur_ligne).(cur_colonne)=data_xls(i_ligne,i_colonne);
         end
     end
 end
 
 


end