function [Liste_Body]=Parcourir_branche_enfant(Struct_Bodies,Body1,Info_Body1,Body2,Liste_Body,i_rec)

if ~isempty(i_rec)
    i_rec=i_rec+1;
    bodies = fieldnames(Struct_Bodies);
    
    if ~isempty(Info_Body1.Children)
        nb_enfants = length(Info_Body1.Children);
        
        for i_e=1:nb_enfants
            
            %             clear Liste_Body
            cur_e = Info_Body1.Children{i_e};
            
            % On vérifie que si ses enfants son le body 2
            if strcmp(cur_e,Body2) && ~isempty(cur_e)
                
                if i_rec>1
                    Liste_Body{i_rec}=Body1;
                    Liste_Body{i_rec+1}=cur_e;
                    i_rec = [];
                    return
                else
                    %Liste_Body{i_rec+1}=cur_e;
                end
            elseif ~isempty(cur_e)
                % On cherche les enfants de l'enfant RECURRENCE
                for i_b = 1:length(bodies)
                    cur_b = Struct_Bodies.(bodies{i_b});
                    if strcmp(bodies{i_b},cur_e)
                        Info_e = cur_b;
                    end
                end
                Liste_Body{i_rec}=Body1;
                Liste_Body = Parcourir_branche_enfant(Struct_Bodies,cur_e,...
                Info_e,Body2,Liste_Body,i_rec);
                
                if i_e == nb_enfants && isempty(find(~cellfun(@isempty,strfind(Liste_Body,Body2)), 1))...
                        && length(Liste_Body)>1
                    
                    for iii=1:1:length(Liste_Body(1,1:end-nb_enfants))
                        Listetemp{1,iii} = cell2mat(Liste_Body(1,iii));   %N'imp....
                    end
                    
%                     if length(Listetemp)>2 && length(find(cellfun(@isempty,strfind(Listetemp,'clavicle') )==1))>1
%                         break
%                     end
                    
                    clear Liste_Body;
                    Liste_Body = Listetemp;
                    clear Listetemp
                elseif ~isempty(find(~cellfun(@isempty,strfind(Liste_Body,Body2)), 1))
                    break
                end
                
            end
        end
        
    else
        Liste_Body{end+1}=Body1;
    end
else
    return
end
end