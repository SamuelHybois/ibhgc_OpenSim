function tree_out=application_scale_factor_contraintes(tree,scaling_factors)

tree_out=tree;
if isfield(tree.Model.ConstraintSet.objects,'PointConstraint')
    nb_constraint=size(tree.Model.ConstraintSet.objects.PointConstraint,2);
    for i_constraint=1:nb_constraint
        body1=tree.Model.ConstraintSet.objects.PointConstraint(i_constraint).body_1;
        body2=tree.Model.ConstraintSet.objects.PointConstraint(i_constraint).body_2;
        tree_out.Model.ConstraintSet.objects.PointConstraint(i_constraint).location_body_1=...
            tree.Model.ConstraintSet.objects.PointConstraint(i_constraint).location_body_1.*scaling_factors.(body1);
        tree_out.Model.ConstraintSet.objects.PointConstraint(i_constraint).location_body_2=...
            tree.Model.ConstraintSet.objects.PointConstraint(i_constraint).location_body_2.*scaling_factors.(body2);
    end
end
end