function tree_out=application_scale_factor_fonctions(tree,scaling_factors)
tree_out=tree;
list_bodies=extract_KinChainData_ModelOS(tree);
list_bodies=fieldnames(list_bodies);
nb_bodies=size(list_bodies,1);
for i_body=1:nb_bodies
    cur_body=list_bodies{i_body};
    if ~strcmp(cur_body,'ground')
        TypeJoint=fieldnames(tree.Model.BodySet.objects.Body(i_body).Joint);
        TypeJoint=TypeJoint{1};
        if ~strcmpi(TypeJoint,'WeldJoint') && isfield(scaling_factors,cur_body)
            if ~strcmpi(TypeJoint,'ScapulothoracicJoint')
                nb_ddl=size(tree.Model.BodySet.objects.Body(i_body).Joint.(TypeJoint).SpatialTransform.TransformAxis,2);
                for i_ddl=1:nb_ddl
                    cur_axis=tree.Model.BodySet.objects.Body(i_body).Joint.(TypeJoint).SpatialTransform.TransformAxis(i_ddl).axis;
                    fonction=fieldnames(tree.Model.BodySet.objects.Body(i_body).Joint.(TypeJoint).SpatialTransform.TransformAxis(i_ddl).xfunction);
                    cur_factor=abs(cur_axis)*scaling_factors.(cur_body)';
                    if strcmpi(fonction,'LinearXfunction')
                        tree_out.Model.BodySet.objects.Body(i_body).Joint.(TypeJoint).SpatialTransform.TransformAxis(i_ddl).xfunction.LinearXfunction.coefficients=...
                            tree.Model.BodySet.objects.Body(i_body).Joint.(TypeJoint).SpatialTransform.TransformAxis(i_ddl).xfunction.LinearXfunction.coefficients*cur_factor;
                    elseif strcmpi(fonction,'Constant')
                        tree_out.Model.BodySet.objects.Body(i_body).Joint.(TypeJoint).SpatialTransform.TransformAxis(i_ddl).xfunction.Constant.value=...
                            tree.Model.BodySet.objects.Body(i_body).Joint.(TypeJoint).SpatialTransform.TransformAxis(i_ddl).xfunction.Constant.value*cur_factor;
                    elseif strcmpi(fonction,'SimmSpline')
                        if ~isempty(strfind(tree.Model.BodySet.objects.Body(i_body).Joint.(TypeJoint).ATTRIBUTE.name,'knee'))
                            cur_parent=tree.Model.BodySet.objects.Body(i_body).Joint.(TypeJoint).parent_body;
                            cur_factor=abs(cur_axis)*scaling_factors.(cur_parent)';
                        end
                        tree_out.Model.BodySet.objects.Body(i_body).Joint.(TypeJoint).SpatialTransform.TransformAxis(i_ddl).xfunction.SimmSpline.y=...
                            tree.Model.BodySet.objects.Body(i_body).Joint.(TypeJoint).SpatialTransform.TransformAxis(i_ddl).xfunction.SimmSpline.y*cur_factor;
                    elseif strcmpi(fonction,'MulitplierXfunction')
                        tree_out.Model.BodySet.objects.Body(i_body).Joint.(TypeJoint).SpatialTransform.TransformAxis(i_ddl).MultiplierXfunction.scale=...
                            tree.Model.BodySet.objects.Body(i_body).Joint.(TypeJoint).SpatialTransform.TransformAxis(i_ddl).MultiplierXfunction.scale*cur_factor;
                    elseif strcmpi(fonction,'PiecewiseLinearXfunction')
                        disp('Scaling de la fonction PiecewiseLinearXfunction non fait')
                    end
                end
            else % Scapulothoracic joint
                % A faire
                disp('Scaling du scaphulothoracicJoint non fait')
            end
        end
        
    end
end
end