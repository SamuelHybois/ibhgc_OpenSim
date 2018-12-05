
function [objet_red] = ISOLE_SURF_MAILLAGE(type,tag,obj)

%
% fonction qui isole les elements d'un maillage 
%

%
% identification a quelle type de donnée on a faire
%
if isfield(obj,'Elem') %type mef
    switch type
        case 'Noeuds'
            % on selection les elements qui sont composées par les tag des
            % noeuds indiqué en entrée
            tag_E = [] ;
            for P = 1 : size(obj.Elem.elem,2)
                I = find2(obj.Elem.elem(:,P),tag) ;
                if P == 1
                    tag_E = I ;
                else%if ~isempty(tag_E)
                    tag_E = intersect(tag_E,I) ;
                end
            end
            %
            % construction du mef reduit
            %
            tag_E = obj.Elem.tag(tag_E) ;
            objet_red.Noeuds.coord = obj.Noeuds.coord(find2(obj.Noeuds.tag,tag),:) ;
            objet_red.Noeuds.tag = obj.Noeuds.tag(find2(obj.Noeuds.tag,tag),:) ;
            objet_red.Elem.elem = obj.Elem.elem(find2(obj.Elem.tag,tag_E),:) ;
            objet_red.Elem.tag = tag_E ;
            %
        case 'Elem'
            %
            objet_red.Elem.elem = obj.Elem.elem(find2(obj.Elem.tag,tag),:) ;
            objet_red.Elem.tag = obj.Elem.tag(find2(obj.Elem.tag,tag),:) ; ;
            objet_red.Noeuds.tag = unique(objet_red.Elem.elem(:)) ;
            objet_red.Noeuds.coord = obj.Noeuds.coord(find2(obj.Noeuds.tag,objet_red.Noeuds.tag),:) ;
    end









elseif isfield(obj,'Polygones') %type movie
    switch type
        case 'Noeuds'
            %
            %
            %
            % on selection les elements qui sont composées par les tag des
            % noeuds indiqué en entrée
            tag_E = [] ;
            for P = 1 : size(obj.Polygones,2)
                I = find2(obj.Polygones(:,P),tag) ;
                if P == 1
                    tag_E = I ;
                else
                    tag_E = intersect(tag_E,I) ;
                end
            end
            %
            % construction du movie reduit
            %
            tmp.Noeuds.coord = obj.Noeuds ;
            tmp.Noeuds.tag = [1 : size(obj.Noeuds,1)]' ;
            
            tmp.Elem.elem = obj.Polygones(tag_E,:) ;
            tmp.Elem.tag = [1 : length(tag_E)] ;
            %
            tmp.Noeuds.coord = tmp.Noeuds.coord(unique(tmp.Elem.elem(:)),:) ;
            tmp.Noeuds.tag = tmp.Noeuds.tag(unique(tmp.Elem.elem(:)),:) ;
            objet_red = mef2mov(tmp) ;

        case 'Polygones'
            
            tmp.Noeuds.coord = obj.Noeuds ;
            tmp.Noeuds.tag = [1 : size(obj.Noeuds,1)]' ;
            
            %
            tmp.Elem.elem = obj.Polygones(tag,:) ;
%             tmp.Elem.elem(tag,:) = [] ;
            tmp.Elem.tag = [1 : size(tmp.Elem.elem,1)] ;
            %
            tmp.Noeuds.coord = tmp.Noeuds.coord(unique(tmp.Elem.elem(:)),:) ;
            tmp.Noeuds.tag = tmp.Noeuds.tag(unique(tmp.Elem.elem(:)),:) ;
            objet_red = mef2mov(tmp) ;
        
            

    end
end
