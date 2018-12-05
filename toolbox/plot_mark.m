function plot_mark(mark_names,mark_coord,col,fig)
% Permet de représenter les marqueurs du modele dans l'espace

if ~exist('col','var'), col = [0 0 0]; end

nb_mark = length(mark_names) ;
if isempty(fig); figure
else fig; 
end
for imark=1:nb_mark
    plot3(mark_coord(1,imark*3-2),mark_coord(1,imark*3-1),mark_coord(1,imark*3),'*','Color',col), hold on
    text(mark_coord(1,imark*3-2),mark_coord(1,imark*3-1),mark_coord(1,imark*3),mark_names(imark),'FontSize',6)
    xlabel('X'),ylabel('Y'),zlabel('Z')
    axis equal
end

end