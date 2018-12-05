function [struct_tree]=TopologicTree(Struct_Bodies)


bodies = fieldnames(Struct_Bodies);
struct_tree=struct;
%1) on cherche le grand parent qui n'a pas de parent
for i_b = 1:length(bodies)
    cur_b = Struct_Bodies.(bodies{i_b});
    if isempty(cur_b.Parent)
        Trunk = bodies{i_b};
    end
end

struct_tree=(Trunk)
%2) On a les enfants

struct_tree=(Trunk).(Struct_Bodies.(Trunk).Children)


end