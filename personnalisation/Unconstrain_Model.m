function NewModelfileOS = Unconstrain_Model(model)
% To disable constrained and create a new .osim file
% to launch OpenSim inverse dynamics trough matlab

OldModelfileOS = model;
NewModelfileOS = [model(1:end-5) '_unconstrained.osim'];

fid = fopen(OldModelfileOS,'r');
fid2 = fopen(NewModelfileOS,'w+');

ligne=fgetl(fid);
nbligne = 1;
fprintf(fid2,'%s\n',ligne);

while ~feof(fid)
    ligne=fgetl(fid);
    nbligne = nbligne +1 ;
    
    if ~isempty(strfind(ligne,'<ConstraintSet>'))
        fprintf(fid2,'%s\n',ligne);
        while isempty(strfind(ligne,'</ConstraintSet>'))
            ligne=fgetl(fid);
            nbligne = nbligne +1;
            if ~isempty(strfind(ligne,'<isDisabled>false</isDisabled>'))
                ligneNew = strrep(ligne,'false','true');
                fprintf(fid2,'%s\n',ligneNew);
            else
                fprintf(fid2,'%s\n',ligne);
            end
        end
        
    else
        fprintf(fid2,'%s\n',ligne);
        
    end
end

fclose(fid);
fclose(fid2);


end