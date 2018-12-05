function [Liste_Body]=Parcourir_branche_parent(Struct_Bodies,Body1,Info_Body1,Body2,Liste_Body,i_rec)

if ~isempty(i_rec)
    i_rec=i_rec+1;
    bodies = fieldnames(Struct_Bodies);
    
    if ~isempty(Info_Body1.Parent)
        %nb_parents = length(Info_Body1.Parent);
        nb_parents = 1;
        for i_p=1:nb_parents
            
            %             clear Liste_Body
            cur_p = Info_Body1.Parent(1:end);
            
            % On vérifie que si ses enfants son le body 2
            if strcmp(cur_p,Body2)
                
                if i_rec>1
                    Liste_Body{i_rec}=Body1;
                    Liste_Body{i_rec+1}=cur_p;
                    i_rec = [];
                    return
                else
                    %Liste_Body{i_rec+1}=cur_e;
                end
            else
                % On cherche les enfants de l'enfant RECURRENCE
                for i_b = 1:length(bodies)
                    cur_b = Struct_Bodies.(bodies{i_b});
                    if strcmp(bodies{i_b},cur_p)
                        Info_p = cur_b;
                    end
                end
                Liste_Body{i_rec}=Body1;
                
                if length(Info_p.Children)==1
                    Liste_Body = Parcourir_branche_parent(Struct_Bodies,cur_p,...
                    Info_p,Body2,Liste_Body,i_rec);
                else
                    Liste_Body = Parcourir_branche_enfant(Struct_Bodies,cur_p,...
                    Info_p,Body2,Liste_Body,i_rec);
                end
                
                if i_p == nb_parents && isempty(find(~cellfun(@isempty,strfind(Liste_Body,Body2)), 1))...
                        && length(Liste_Body)>1
                    
                    for iii=1:1:length(Liste_Body(1,1:end-nb_parents))
                        Listetemp{1,iii} = cell2mat(Liste_Body(1,iii));   %N'imp....
                    end
                    
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