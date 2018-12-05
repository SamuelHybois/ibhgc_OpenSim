function pipeline_harmonisation_personnalisation_EOS_global(rep_global,rep_billes_EOS_gen,cur_sujet,st_protocole,cur_sex)
% cur_sujet='golf_022_GB_driver'
% rep_global='G:\_30_EOS_etude';
% cur_sex='M';
% rep_billes_EOS_gen='G:\_31_mise_en_forme_data_EOS';
chemin_model_generique=fullfile(rep_global,'info_global','IBHGC_membre_inf.osim');
pos=strfind(cur_sujet,'_');
pos=pos(end);
cur_sujet_nom=cur_sujet(1:pos-1);
rep_billes_EOS=fullfile(rep_billes_EOS_gen,cur_sujet_nom);

% rep_sortie_model=fullfile(rep_global,cur_sujet,'modele');
repertoire_ddr=fullfile(rep_global,'info_global','fichiers_ddr');
repertoire_wrl_EOS=fullfile(rep_global,cur_sujet,'modele','EOS_wrl');
% chemin_modele_scaled=fullfile(rep_sortie_model,[cur_sujet '_model_final.osim']);
% [modele_scaled, RootName, ~] =xml_readOSIM(chemin_modele_scaled);
[modele_gen, RootName, ~]=xml_readOSIM(chemin_model_generique);
% decalage_in_bassin=[0 0 0];
chemin_geometry=fullfile(rep_global,cur_sujet,'modele','Geometry');
transfert_fichier_wrl_stl(repertoire_wrl_EOS,cur_sujet,chemin_geometry);
% fichier_o3=fullfile(rep_global,cur_sujet,'modele','EOS_wrl',[cur_sujet '.o3']);
%             [model_eos, reperesH]=pipeline_harmonisation_personnalisation_EOS(modele_scaled,repertoire_wrl_EOS, st_protocole, cur_sex, repertoire_ddr, decalage_in_bassin,chemin_geometry,cur_sujet); %,marqueurs);
% [model_eos, reperesH]=pipeline_harmonisation_personnalisation_EOS_memb_inf(modele_scaled,repertoire_wrl_EOS, st_protocole, cur_sex, repertoire_ddr, decalage_in_bassin,chemin_geometry,cur_sujet); %,marqueurs);
% [model_eos, reperesH]=pipeline_harmonisation_personnalisation_EOS_memb_inf(modele_scaled,repertoire_wrl_EOS, cur_sex, repertoire_ddr, chemin_geometry,cur_sujet); %,marqueurs); 
[model_eos, ~]=pipeline_harmonisation_personnalisation_EOS_memb_inf(modele_gen,repertoire_wrl_EOS, cur_sex, repertoire_ddr, chemin_geometry,cur_sujet); %,marqueurs); 
chemin_modele_EOS=fullfile(rep_global,cur_sujet,'modele',[cur_sujet '_model_final.osim']);
% chemin_modele_EOS=fullfile(rep_global,cur_sujet,'modele','test_EOS.osim');
%         pipeline_harmonisation_personnalisation_EOS_global(rep_global,cur_sujet,rep_sortie_model,st_protocole,cur_sex);

disp('écriture des marqueurs dans la structure')
[st_marqueurs]=gestion_billes_EOS2(rep_billes_EOS,repertoire_ddr,st_protocole,cur_sex);
[model_eos]=modif_marqueurs_in_OSIM_simple(model_eos,st_marqueurs,st_protocole);
disp('écriture du modèle personnalisé')
xml_writeOSIM(chemin_modele_EOS,model_eos,RootName,struct('StructItem',false,'CellItem',false));

end