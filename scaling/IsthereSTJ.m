function bool = IsthereSTJ(modele_gen_path)
% To know if there is a scapulothoracic joint in the model

OldModelfileOS = modele_gen_path;

fid = fopen(char(OldModelfileOS),'r');

ligne=fgetl(fid);
nbligne = 1;
bool=0;

while ~feof(fid) && bool == 0
    ligne=fgetl(fid);
    nbligne = nbligne +1 ;
    
    if ~isempty(strfind(ligne,'<ScapulothoracicJoint name='))
        bool =1;
    end
end

fclose(fid);

end

