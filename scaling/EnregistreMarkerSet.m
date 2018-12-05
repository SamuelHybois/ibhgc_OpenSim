function [MarkerSetName]=EnregistreMarkerSet(modelOSIM)

[pathstr,name,~]=fileparts(modelOSIM);

fid = fopen(char(modelOSIM),'r');
MarkerSetName = [pathstr,'\',name,'MarkerSet.txt'];
fid2 = fopen(MarkerSetName,'w+');

ligne=fgetl(fid);
nbligne = 1;

while ~feof(fid)
    ligne=fgetl(fid);
    nbligne = nbligne +1 ;
    
    if ~isempty(strfind(ligne,'<MarkerSet>'))
        fprintf(fid2,'%s\n',ligne);
        while 1
            ligne=fgetl(fid);
            nbligne = nbligne +1 ;
            fprintf(fid2,'%s\n',ligne);
            if ~isempty(strfind(ligne,'</MarkerSet>'))
                break
            end
        end
    end
end

fclose(fid);
fclose(fid2);


end