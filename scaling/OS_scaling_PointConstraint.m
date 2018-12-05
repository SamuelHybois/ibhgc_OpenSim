function nom_osim_sortie = OS_scaling_PointConstraint(rep_scaled,path_model_gen)

[~,liste_files_scaled] = PathContent_Type(rep_scaled,'scaling_1_step1.osim') ;

% Chargement du modèle générique
xmlfile_generique = path_model_gen ;
[tree_generique, ~, ~] = xml_readOSIM_TJ(xmlfile_generique,struct('Sequence',true));
% Chargement du modèle scalé
xmlfile_scaled = fullfile(rep_scaled,liste_files_scaled{1}) ;
[tree_scaled, RootName, ~] = xml_readOSIM_TJ(xmlfile_scaled,struct('Sequence',true));

% Recherche des Points Constraints et identification des Bodies associés

Pt_con_scaled = tree_scaled.Model.ConstraintSet.objects.PointConstraint ;
Bodies_scaled = tree_scaled.Model.BodySet.objects.Body ;

Pt_con_gen = tree_generique.Model.ConstraintSet.objects.PointConstraint ;
Bodies_gen = tree_generique.Model.BodySet.objects.Body ;

if ~isempty(tree_scaled.Model.ConstraintSet.objects)
    
    for i_constraint = 1:length(Pt_con_scaled)
        
        body_1 = Pt_con_scaled(i_constraint).body_1 ;
        body_2 = Pt_con_scaled(i_constraint).body_2 ;
        
        location_ini_body_1 = Pt_con_gen(i_constraint).location_body_1 ;
        location_ini_body_2 = Pt_con_gen(i_constraint).location_body_2 ;
        
        for i_body=1:length(Bodies_gen)
            
            if strcmp(body_1 , Bodies_gen(i_body).ATTRIBUTE.name) == 1
                
                scale_factors_final_body1 = Bodies_scaled(i_body).VisibleObject.scale_factors ;
                scale_factors_initial_body1 = Bodies_gen(i_body).VisibleObject.scale_factors ;
                
                location_final_body_1 = (scale_factors_final_body1./scale_factors_initial_body1).*location_ini_body_1 ;
                Pt_con_scaled(i_constraint).location_body_1 = location_final_body_1 ;
                
                Pt_con_gen(i_constraint).location_body_1 = location_final_body_1 ;
                
            elseif strcmp(body_2,Bodies_gen(i_body).ATTRIBUTE.name)==1
                
                scale_factors_final_body2 = Bodies_scaled(i_body).VisibleObject.scale_factors ;
                scale_factors_initial_body2 = Bodies_scaled(i_body).VisibleObject.scale_factors ;
                
                location_final_body_2 = (scale_factors_final_body2./scale_factors_initial_body2).*location_ini_body_2 ;
                Pt_con_scaled(i_constraint).location_body_2 = location_final_body_2 ;
                
                Pt_con_gen(i_constraint).location_body_2 = location_final_body_2 ;
                
            else %ne rien faire
                
            end %if
            
        end %for i_body    
        
    end %for i_constraint
    
else % ne rien faire
    
end % if_isempty

tree_scaled.Model.ConstraintSet.objects.PointConstraint = Pt_con_scaled;
tree_scaled.Model.BodySet.objects.Body = Bodies_scaled ;

tree_generique.Model.ConstraintSet.objects.PointConstraint = Pt_con_gen ;
tree_generique.Model.BodySet.objects.Body = Bodies_gen  ;

% Réécrire le fichier sur le fichier scalé
% cd(rep_generique);
nom_osim_sortie = [liste_files_scaled{1}(1:end-20) 'pointconstraint.osim'] ;
xml_writeOSIM_TJ(fullfile(rep_scaled,nom_osim_sortie),tree_scaled, RootName, struct('StructItem',false,'CellItem',false));
end % function