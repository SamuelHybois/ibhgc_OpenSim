% récupération du modèle scalé
file_osim_scaled=fullfile(rep_global,cur_sujet,'modele',[cur_sujet '_model_final.osim']);
[model_scaled, RootName,~]=xml_readOSIM(file_osim_scaled);

% déclaration des dossiers de données EOS
repertoire_wrl_EOS=fullfile(rep_global, cur_sujet, 'modele', 'EOS_wrl');
repertoire_ddr=fullfile(rep_global, 'info_global','fichiers_ddr');

decalage_hanche_in_bassin=[0 0 0];
[model_perso_eos, reperesH]=pipeline_harmonisation_personnalisation_EOS(model_scaled,repertoire_wrl_EOS, st_protocole, cur_mass, repertoire_ddr, decalage_hanche_in_bassin);


my_name_osim_eos=[my_ext_decal '_' mypatient_name my_extension_EOS];
% version 2014
rep_sortie_model_EOS=fullfile(rep_global, mypatient_name, my_osim_folder_EOS);
mkdir(rep_sortie_model_EOS);
cd (rep_sortie_model_EOS)
nom_fichier_billes_eos=[mypatient_name '_billes_EOS.xml'];
fichier_sortie_billes=fullfile(rep_sortie_model_EOS,nom_fichier_billes_eos);
rep_billes_EOS=fullfile(rep_global, mypatient_name, my_raw_data, my_EOS_billes);
[model_perso_eos,billes_eos]=gestion_billes_EOS(rep_billes_EOS,model_perso_eos, Protocol, reperesH,fichier_sortie_billes);
xml_writeOSIM(my_name_osim_eos,model_perso_eos,RootName);