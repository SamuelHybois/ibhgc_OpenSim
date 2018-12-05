function []=RemplaceMarkerSet(MarkerSet,modelOSIM)

[pathstr,name,ext]=fileparts(modelOSIM);
fid = fopen(char(modelOSIM),'r');
fid2 = fopen(MarkerSet,'r');
fid3 = fopen([pathstr,'\',name, 'NewMarkerSet',ext],'w+');

ligne1=fgetl(fid);
nbligne = 1;
fprintf(fid3,'%s\n',ligne1);

while ~feof(fid)
    ligne1=fgetl(fid);
    nbligne = nbligne +1 ;
    fprintf(fid3,'%s\n',ligne1);
    
    if ~isempty(strfind(ligne1,'		<MarkerSet>'))
        ligne2 = fgetl(fid2);
        ligne2 = fgetl(fid2);
        nbligne2 = 2;
        
        while ~feof(fid2)
            fprintf(fid3,'%s\n',ligne2);
            ligne2 = fgetl(fid2);
            nbligne2 = nbligne2+1;
        end
        fprintf(fid3,'%s\n',ligne2);
        while 1
            ligne1=fgetl(fid);
            nbligne = nbligne +1 ;
            if ~isempty(strfind(ligne1,'</MarkerSet>'))
                break
            end
        end
        while ~feof(fid)
            ligne1=fgetl(fid);
            nbligne = nbligne +1 ;
            fprintf(fid3,'%s\n',ligne1);
        end
    end
end

fclose(fid);
fclose(fid2);
fclose(fid3);

delete(char(modelOSIM))
movefile([pathstr,'\',name, 'NewMarkerSet',ext],modelOSIM);
end