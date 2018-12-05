function pipeline_harmonisation_personnalisation_EOS_global_var(rep_global,cur_sujet,rep_sortie_model,st_protocole,cur_sex)
% mise à jour de la fonction pour permettre l'étude de sensibilité. 

            repertoire_ddr=fullfile(rep_global,'info_global','fichiers_ddr');
            repertoire_wrl_EOS=fullfile(rep_global,cur_sujet,'modele','EOS_wrl');
            chemin_modele_scaled=fullfile(rep_sortie_model,[cur_sujet '_model_final.osim']);
            [modele_scaled, RootName, ~] =xml_readOSIM(chemin_modele_scaled);
            decalage_in_bassin=[0 0 0];
            chemin_geometry=fullfile(rep_global,cur_sujet,'modele','Geometry');
            transfert_fichier_wrl_stl(repertoire_wrl_EOS,cur_sujet,chemin_geometry);
            fichier_o3=fullfile(rep_global,cur_sujet,'modele','EOS_wrl',[cur_sujet '.o3']);
%             [model_eos, reperesH]=pipeline_harmonisation_personnalisation_EOS(modele_scaled,repertoire_wrl_EOS, st_protocole, cur_sex, repertoire_ddr, decalage_in_bassin,chemin_geometry,cur_sujet); %,marqueurs);
            [model_eos, reperesH]=pipeline_harmonisation_personnalisation_EOS_memb_inf(modele_scaled,repertoire_wrl_EOS, st_protocole, cur_sex, repertoire_ddr, decalage_in_bassin,chemin_geometry,cur_sujet); %,marqueurs);
        chemin_modele_EOS=fullfile(rep_global,cur_sujet,'modele',[cur_sujet '_model_EOS.osim']);
%         pipeline_harmonisation_personnalisation_EOS_global(rep_global,cur_sujet,rep_sortie_model,st_protocole,cur_sex);
        
        xml_writeOSIM(chemin_modele_EOS,model_eos,RootName,struct('StructItem',false,'CellItem',false));
       
end
        