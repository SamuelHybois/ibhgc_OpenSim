function [model_new]=change_scale_et_visu_geo_model_OS(model_old, body_number, body_visu)
% Maxime Bourgain 21/01/2016
% changement du scale factor et du nom des fichier géométries
% plusieurs cas possibles si le nombre déléments de visualisation est
% modifié : par exemple, les trois éléments constituant le pelvis OS ne
% sont qu'une seule géométrie dans EOS. A contrario, on veut donner les
% géométries EOS du tibia et de la fibula pour la visualisation du segment
% entre le genou et la cheville.

model_new=model_old;
model_new.Model.BodySet.objects.Body(body_number).VisibleObject.scale_factors=[];
model_new.Model.BodySet.objects.Body(body_number).VisibleObject.scale_factors=[1 1 1];


% old_size=size({model_new.Model.BodySet.objects.Body(body_number).VisibleObject.GeometrySet.objects.DisplayGeometry.geometry_file},2);
if isfield(model_new.Model.BodySet.objects.Body(body_number).VisibleObject,'GeometrySet')
    old_size=size(model_new.Model.BodySet.objects.Body(body_number).VisibleObject.GeometrySet.objects.DisplayGeometry,2);
    
    nb_element=size(body_visu,1);
    if old_size<=size(body_visu,1),
        if size(body_visu,1)==1,
            model_new.Model.BodySet.objects.Body(body_number).VisibleObject.GeometrySet.objects.DisplayGeometry.geometry_file=[];
            model_new.Model.BodySet.objects.Body(body_number).VisibleObject.GeometrySet.objects.DisplayGeometry.geometry_file=body_visu;%'bassin.stl';
            model_new.Model.BodySet.objects.Body(body_number).VisibleObject.GeometrySet.objects.DisplayGeometry.scale_factors=[1 1 1];
        else % cas où plusieurs géométries sont nécessaires pour un élément, par exemple tibia+fibula.
            
            for i=1:nb_element
                
                model_new.Model.BodySet.objects.Body(body_number).VisibleObject.GeometrySet.objects.DisplayGeometry(i).geometry_file=body_visu{i};
                
                model_new.Model.BodySet.objects.Body(body_number).VisibleObject.GeometrySet.objects.DisplayGeometry(i).scale_factors=[];
                model_new.Model.BodySet.objects.Body(body_number).VisibleObject.GeometrySet.objects.DisplayGeometry(i).scale_factors=[1 1 1];
            end
        end
    else
        for i=1:nb_element
            if size(body_visu,1)==1
                model_new.Model.BodySet.objects.Body(body_number).VisibleObject.GeometrySet.objects.DisplayGeometry(i).geometry_file=body_visu;
            else
                model_new.Model.BodySet.objects.Body(body_number).VisibleObject.GeometrySet.objects.DisplayGeometry(i).geometry_file=body_visu{i};
            end
            model_new.Model.BodySet.objects.Body(body_number).VisibleObject.GeometrySet.objects.DisplayGeometry(i).scale_factors=[];
            model_new.Model.BodySet.objects.Body(body_number).VisibleObject.GeometrySet.objects.DisplayGeometry(i).scale_factors=[1 1 1];
        end
        for i=(nb_element+1):old_size
            %         model_new.Model.BodySet.objects.Body(body_number).VisibleObject.GeometrySet.objects.DisplayGeometry(i).geometry_file=[];
            %
            %         model_new.Model.BodySet.objects.Body(body_number).VisibleObject.GeometrySet.objects.DisplayGeometry(i).scale_factors=[];
            model_new.Model.BodySet.objects.Body(body_number).VisibleObject.GeometrySet.objects.DisplayGeometry(2)=[];
            
        end
    end
    
end

end