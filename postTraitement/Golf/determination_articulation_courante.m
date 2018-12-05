function [articulation]=determination_articulation_courante(tree,enfant)
articulation=struct;
for i_seg=1:size(tree.Model.BodySet.objects.Body,2)
    if strcmpi(tree.Model.BodySet.objects.Body(i_seg).ATTRIBUTE.name,enfant)
        num_ligne_enfant=i_seg;
        break
    end
end
TypeJoint=fieldnames(tree.Model.BodySet.objects.Body(num_ligne_enfant).Joint);
articulation.parent=tree.Model.BodySet.objects.Body(num_ligne_enfant).Joint.(char(TypeJoint)).parent_body;
articulation.nom=tree.Model.BodySet.objects.Body(num_ligne_enfant).Joint.(char(TypeJoint)).ATTRIBUTE.name;
articulation.enfant=enfant;

end