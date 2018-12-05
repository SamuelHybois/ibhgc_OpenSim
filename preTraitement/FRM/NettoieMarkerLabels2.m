function [markers] = NettoieMarkerLabels2(markers)
% fonction de Christophe Sauret 
% mise à jour par Maxime Bourgain le 30 aout 2016 : prise en compte du fait
% que le nom des marqueurs ne peut pas être constitué uniquement de
% numéros.
% 
Champs = fieldnames(markers); markers2=[];
        for i=1:size(Champs,1)
            if ~isempty(strfind(Champs{i},'C_'))==1 % on enlève les marqueurs non labélisés
            elseif ~isempty(strfind(Champs{i},'_1'))==1 % pour enveler les double trajectoire (HEEL, HEEL_1, HEEL_2... on ne garde que la première)
            elseif ~isempty(strfind(Champs{i},'_2'))==1
            elseif ~isempty(strfind(Champs{i},'_3'))==1
            elseif ~isempty(strfind(Champs{i},'_4'))==1
            elseif ~isempty(strfind(Champs{i},'_5'))==1
            elseif ~isempty(strfind(Champs{i},'_6'))==1
            elseif ~isempty(strfind(Champs{i},'_7'))==1
            elseif ~isempty(strfind(Champs{i},'_8'))==1
            elseif ~isempty(strfind(Champs{i},'_9'))==1
            elseif isempty(strfind(Champs{i},'_'))==1 % on garde directement s'il n'y a pas de nom de sujet avant nom de marker (séparateur : '_')
                markers2.(Champs{i})=markers.(Champs{i});
            else
                a =strfind(Champs{i},'_');
                cur_nom=Champs{i}(a(end)+1:end); %prise en compte du cas où le nom du marqueur n'est constitué que de numéros : cela n'est pas possible, donc changement du nom courant
                k0=strfind(cur_nom,'0');
                k1=strfind(cur_nom,'1');
                k2=strfind(cur_nom,'2');
                k3=strfind(cur_nom,'3');
                k4=strfind(cur_nom,'4');
                k5=strfind(cur_nom,'5');
                k6=strfind(cur_nom,'6');
                k7=strfind(cur_nom,'7');
                k8=strfind(cur_nom,'8');
                k9=strfind(cur_nom,'9');
                ktotal=length(k0)+length(k1)+length(k2)+length(k3)+length(k4)+...
                    length(k5)+length(k6)+length(k7)+length(k8)+length(k9);
                if ktotal==length(cur_nom)
                    cur_nom2=Champs{i}(a(end-1)+1:end);
                    markers2.(cur_nom2)=markers.(Champs{i});
                else
                    markers2.(cur_nom)=markers.(Champs{i});
                end
            end
        end
        markers=markers2; clear markers2
        
end