function tree_out=application_scale_factor_muscles(tree,scaling_factors)

tree_out=tree;
if isfield(tree.Model.ForceSet,'objects')
    nom_grp_muscle=fieldnames(tree.Model.ForceSet.objects);
    for i_grp_muscle=1:size(nom_grp_muscle,1)
        nb_muscles=length(tree.Model.ForceSet.objects.(nom_grp_muscle{i_grp_muscle}));
        for i_muscle=1:nb_muscles
            if isfield(tree.Model.ForceSet.objects.(nom_grp_muscle{i_grp_muscle})(i_muscle),'GeometryPath')
                list_type_point=fieldnames(tree.Model.ForceSet.objects.(nom_grp_muscle{i_grp_muscle})(i_muscle).GeometryPath.PathPointSet.objects);
                nb_type_point=size(list_type_point,1);
                for i_type_point=1:nb_type_point
                    type_point=list_type_point{i_type_point};
                    if strcmp(type_point,'PathPoint')
                        nb_point=size(fieldnames(tree.Model.ForceSet.objects.(nom_grp_muscle{i_grp_muscle})(i_muscle).GeometryPath.PathPointSet.objects.PathPoint),2);
                        for i_point=1:nb_point
                            cur_body=tree.Model.ForceSet.objects.(nom_grp_muscle{i_grp_muscle})(i_muscle).GeometryPath.PathPointSet.objects.PathPoint(i_point).body;
                            tree_out.Model.ForceSet.objects.(nom_grp_muscle{i_grp_muscle})(i_muscle).GeometryPath.PathPointSet.objects.PathPoint(i_point).location=...
                                tree.Model.ForceSet.objects.(nom_grp_muscle{i_grp_muscle})(i_muscle).GeometryPath.PathPointSet.objects.PathPoint(i_point).location.*scaling_factors.(cur_body);
                        end
                    elseif strcmp(type_point,'ConditionalPathPoint')
                        nb_point=size(fieldnames(tree.Model.ForceSet.objects.(nom_grp_muscle{i_grp_muscle})(i_muscle).GeometryPath.PathPointSet.objects.ConditionalPathPoint),2);
                        for i_point=1:nb_point
                            cur_body=tree.Model.ForceSet.objects.(nom_grp_muscle{i_grp_muscle})(i_muscle).GeometryPath.PathPointSet.objects.ConditionalPathPoint(i_point).body;
                            tree_out.Model.ForceSet.objects.(nom_grp_muscle{i_grp_muscle})(i_muscle).GeometryPath.PathPointSet.objects.ConditionalPathPoint(i_point).location=...
                                tree.Model.ForceSet.objects.(nom_grp_muscle{i_grp_muscle})(i_muscle).GeometryPath.PathPointSet.objects.ConditionalPathPoint(i_point).location.*scaling_factors.(cur_body);
                        end
                    elseif strcmp(type_point,'MovingPathPoint')
                        nb_point=size(fieldnames(tree.Model.ForceSet.objects.(nom_grp_muscle{i_grp_muscle})(i_muscle).GeometryPath.PathPointSet.objects.MovingPathPoint),2);
                        for i_point=1:nb_point
                            cur_body=tree.Model.ForceSet.objects.(nom_grp_muscle{i_grp_muscle})(i_muscle).GeometryPath.PathPointSet.objects.MovingPathPoint(i_point).body;
                            tree_out.Model.ForceSet.objects.(nom_grp_muscle{i_grp_muscle})(i_muscle).GeometryPath.PathPointSet.objects.MovingPathPoint(i_point).location=...
                                tree.Model.ForceSet.objects.(nom_grp_muscle{i_grp_muscle})(i_muscle).GeometryPath.PathPointSet.objects.MovingPathPoint(i_point).location.*scaling_factors.(cur_body);
                            % X
                            if isfield(tree.Model.ForceSet.objects.(nom_grp_muscle{i_grp_muscle})(i_muscle).GeometryPath.PathPointSet.objects.MovingPathPoint(i_point).x_location,'SimmSpline')
                                tree_out.Model.ForceSet.objects.(nom_grp_muscle{i_grp_muscle})(i_muscle).GeometryPath.PathPointSet.objects.MovingPathPoint(i_point).x_location.SimmSpline.y=...
                                    tree.Model.ForceSet.objects.(nom_grp_muscle{i_grp_muscle})(i_muscle).GeometryPath.PathPointSet.objects.MovingPathPoint(i_point).x_location.SimmSpline.y*scaling_factors.(cur_body)(1);
                            elseif isfield(tree.Model.ForceSet.objects.(nom_grp_muscle{i_grp_muscle})(i_muscle).GeometryPath.PathPointSet.objects.MovingPathPoint(i_point).x_location,'PiecewiseLinearXfunction')
                                tree_out.Model.ForceSet.objects.(nom_grp_muscle{i_grp_muscle})(i_muscle).GeometryPath.PathPointSet.objects.MovingPathPoint(i_point).x_location.PiecewiseLinearXfunction.y=...
                                    tree.Model.ForceSet.objects.(nom_grp_muscle{i_grp_muscle})(i_muscle).GeometryPath.PathPointSet.objects.MovingPathPoint(i_point).x_location.PiecewiseLinearXfunction.y*scaling_factors.(cur_body)(1);
                            elseif isfield(tree.Model.ForceSet.objects.(nom_grp_muscle{i_grp_muscle})(i_muscle).GeometryPath.PathPointSet.objects.MovingPathPoint(i_point).x_location,'LinearXfunction')
                                disp('Scaling de LinearXfunction dans le muscle non fait')
                            elseif isfield(tree.Model.ForceSet.objects.(nom_grp_muscle{i_grp_muscle})(i_muscle).GeometryPath.PathPointSet.objects.MovingPathPoint(i_point).x_location,'Constant')
                                disp('Scaling de Constant dans le muscle non fait')
                            elseif isfield(tree.Model.ForceSet.objects.(nom_grp_muscle{i_grp_muscle})(i_muscle).GeometryPath.PathPointSet.objects.MovingPathPoint(i_point).x_location,'MulitplierXfunction')
                                disp('Scaling de MulitplierXfunction dans le muscle non fait')
                            end
                            % Y
                            if isfield(tree.Model.ForceSet.objects.(nom_grp_muscle{i_grp_muscle})(i_muscle).GeometryPath.PathPointSet.objects.MovingPathPoint(i_point).y_location,'SimmSpline')
                                tree_out.Model.ForceSet.objects.(nom_grp_muscle{i_grp_muscle})(i_muscle).GeometryPath.PathPointSet.objects.MovingPathPoint(i_point).y_location.SimmSpline.y=...
                                    tree.Model.ForceSet.objects.(nom_grp_muscle{i_grp_muscle})(i_muscle).GeometryPath.PathPointSet.objects.MovingPathPoint(i_point).y_location.SimmSpline.y*scaling_factors.(cur_body)(2);
                            elseif isfield(tree.Model.ForceSet.objects.(nom_grp_muscle{i_grp_muscle})(i_muscle).GeometryPath.PathPointSet.objects.MovingPathPoint(i_point).y_location,'PiecewiseLinearXfunction')
                                tree_out.Model.ForceSet.objects.(nom_grp_muscle{i_grp_muscle})(i_muscle).GeometryPath.PathPointSet.objects.MovingPathPoint(i_point).y_location.PiecewiseLinearXfunction.y=...
                                    tree.Model.ForceSet.objects.(nom_grp_muscle{i_grp_muscle})(i_muscle).GeometryPath.PathPointSet.objects.MovingPathPoint(i_point).y_location.PiecewiseLinearXfunction.y*scaling_factors.(cur_body)(1);
                            elseif isfield(tree.Model.ForceSet.objects.(nom_grp_muscle{i_grp_muscle})(i_muscle).GeometryPath.PathPointSet.objects.MovingPathPoint(i_point).y_location,'LinearXfunction')
                                disp('Scaling de LinearXfunction dans le muscle non fait')
                            elseif isfield(tree.Model.ForceSet.objects.(nom_grp_muscle{i_grp_muscle})(i_muscle).GeometryPath.PathPointSet.objects.MovingPathPoint(i_point).y_location,'Constant')
                                disp('Scaling de Constant dans le muscle non fait')
                            elseif isfield(tree.Model.ForceSet.objects.(nom_grp_muscle{i_grp_muscle})(i_muscle).GeometryPath.PathPointSet.objects.MovingPathPoint(i_point).y_location,'MulitplierXfunction')
                                disp('Scaling de MulitplierXfunction dans le muscle non fait')
                            end
                            % Z
                            if isfield(tree.Model.ForceSet.objects.(nom_grp_muscle{i_grp_muscle})(i_muscle).GeometryPath.PathPointSet.objects.MovingPathPoint(i_point).z_location,'SimmSpline')
                                tree_out.Model.ForceSet.objects.(nom_grp_muscle{i_grp_muscle})(i_muscle).GeometryPath.PathPointSet.objects.MovingPathPoint(i_point).z_location.SimmSpline.y=...
                                    tree.Model.ForceSet.objects.(nom_grp_muscle{i_grp_muscle})(i_muscle).GeometryPath.PathPointSet.objects.MovingPathPoint(i_point).z_location.SimmSpline.y*scaling_factors.(cur_body)(3);
                            elseif isfield(tree.Model.ForceSet.objects.(nom_grp_muscle{i_grp_muscle})(i_muscle).GeometryPath.PathPointSet.objects.MovingPathPoint(i_point).z_location,'PiecewiseLinearXfunction')
                                tree_out.Model.ForceSet.objects.(nom_grp_muscle{i_grp_muscle})(i_muscle).GeometryPath.PathPointSet.objects.MovingPathPoint(i_point).z_location.PiecewiseLinearXfunction.y=...
                                    tree.Model.ForceSet.objects.(nom_grp_muscle{i_grp_muscle})(i_muscle).GeometryPath.PathPointSet.objects.MovingPathPoint(i_point).z_location.PiecewiseLinearXfunction.y*scaling_factors.(cur_body)(1);
                            elseif isfield(tree.Model.ForceSet.objects.(nom_grp_muscle{i_grp_muscle})(i_muscle).GeometryPath.PathPointSet.objects.MovingPathPoint(i_point).z_location,'LinearXfunction')
                                disp('Scaling de LinearXfunction dans le muscle non fait')
                            elseif isfield(tree.Model.ForceSet.objects.(nom_grp_muscle{i_grp_muscle})(i_muscle).GeometryPath.PathPointSet.objects.MovingPathPoint(i_point).z_location,'Constant')
                                disp('Scaling de Constant dans le muscle non fait')
                            elseif isfield(tree.Model.ForceSet.objects.(nom_grp_muscle{i_grp_muscle})(i_muscle).GeometryPath.PathPointSet.objects.MovingPathPoint(i_point).z_location,'MulitplierXfunction')
                                disp('Scaling de MulitplierXfunction dans le muscle non fait')
                            end
                        end
                    end
                end
            end
        end
    end
else
    disp('Pas de muscles dans le modèle')
end
end