function A = lire_fichier_vtp(nom_fich)

A.N_Obj = 1; % 1 seul objet par fichier 
% Lecture du fichier
fid = fopen(nom_fich,'r') ;

while feof(fid)~=1 
    ligne=fgetl(fid);
    
    if ~isempty(strfind(ligne,'<Piece'))
        %Initialisation des variables Noeuds et Normales
        a=strfind(ligne,'NumberOfPoints="');
        b=strfind(ligne(a+16:end),'"');
        A.Normales=zeros(str2double(ligne(a+16:a+16+(b-2))),3);
        A.Noeuds=zeros(str2double(ligne(a+16:a+16+(b-2))),3);
        
        %Initialisation de la variable Noeuds
        a=strfind(ligne,'NumberOfPolys="');
        b=strfind(ligne(a+15:end),'"');
        A.Polygones=zeros(str2double(ligne(a+15:a+15+(b-2))),3);
        
    elseif ~isempty(strfind(ligne,'<PointData Normals="Normals">'))
        type = 'Normales'; i=0;
    elseif ~isempty(strfind(ligne,'<Points>'))
        type = 'Noeuds'; i=0;
    elseif ~isempty(strfind(ligne,'<Polys>'))
        type = 'Polygones'; i=0;
    elseif ~isempty(strfind(ligne,'Name="offsets"'))
        clear type
    elseif ~isempty(strfind(ligne,'<'))
    else %Coordonnées ou numéros de noeuds
        if exist('type','var')
            i=i+1;
            tmp = str2num(ligne);
            
            if strcmp(type,'Polygones');
                if size(tmp,2)> size(A.Polygones,2)
                    Mat = zeros(size(A.Polygones,1),size(tmp,2));
                    Mat(1:i-1,1:size(A.Polygones,2)) = A.Polygones(1:i-1,:);
                    diff = size(tmp,2) - size(A.Polygones,2);
                    % on replique le dernier noeuds autant de fois que
                    % nécessaire
                    Mat(1:i-1,size(A.Polygones,2)+1:end)=repmat(A.Polygones(1:i-1,end),[1,diff]);
                    A.Polygones = Mat;
                elseif size(tmp,2)<size(A.Polygones,2)
                    % on réplique le dernier point n fois
                    diff = size(A.Polygones,2) - size(tmp,2);
                    tmp = [tmp, repmat(tmp(1,end),[1,diff])];
                end

            else
            end
            A.(type)(i,:)=tmp;
        end
    end
    
    
end
fclose(fid) ;