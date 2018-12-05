cd H:\sauvegarde_ddr\Cours_these\Recherche\DATA\EOS\ReBe_M_1968\reconstructions\fichiers_o3

o3_ReBe_M_1968_L5=lire_fichier_o3('ReBe_M_1968.o3', {'Vertebre_L5'});

M_L5=calcul_repere_vertebre_tl(o3_ReBe_M_1968_L5);

f_init='H:\sauvegarde_ddr\Cours_these\Recherche\DATA\EOS\ReBe_M_1968\reconstructions\réegion_lombaire\Vertebre_L5.wrl';
fid_init=fopen(f_init,'r');
ReBe_M_1968_L5_movie_init=lire_fichier_wrml(f_init);
affiche_objet_movie(ReBe_M_1968_L5_movie_init);


f_tourne='H:\sauvegarde_ddr\Cours_these\Recherche\DATA\EOS\ReBe_M_1968\reconstructions\region_lombaire_tourne\Vertebre_L5.wrl';
fid_tourne=fopen(f_tourne,'r');
ReBe_M_1968_L5_movie_tourne=lire_fichier_wrml(f_tourne);
affiche_objet_movie(ReBe_M_1968_L5_movie_tourne);

[~,transformation_L5]=Recalage_svd(ReBe_M_1968_L5_movie_tourne.Noeuds,ReBe_M_1968_L5_movie_init.Noeuds);





f_init='H:\sauvegarde_ddr\Cours_these\Recherche\DATA\EOS\ReBe_M_1968\reconstructions\réegion_lombaire\Vertebre_L1.wrl';
fid_init=fopen(f_init,'r');
ReBe_M_1968_L1_movie_init=lire_fichier_wrml(f_init);
affiche_objet_movie(ReBe_M_1968_L1_movie_init);


f_tourne='H:\sauvegarde_ddr\Cours_these\Recherche\DATA\EOS\ReBe_M_1968\reconstructions\region_lombaire_tourne\Vertebre_L1.wrl';
fid_tourne=fopen(f_tourne,'r');
ReBe_M_1968_L1_movie_tourne=lire_fichier_wrml(f_tourne);
affiche_objet_movie(ReBe_M_1968_L1_movie_tourne);

[~,transformation_L1]=Recalage_svd(ReBe_M_1968_L1_movie_tourne.Noeuds,ReBe_M_1968_L1_movie_init.Noeuds);



% o3_ReBe_M_1968_L4=lire_fichier_o3('ReBe_M_1968.o3', {'Vertebre_L4'});
% 
% M_L4=calcul_repere_vertebre_tl(o3_ReBe_M_1968_L4);
% 
% o3_ReBe_M_1968_L3=lire_fichier_o3('ReBe_M_1968.o3', {'Vertebre_L3'});
% 
% M_L3=calcul_repere_vertebre_tl(o3_ReBe_M_1968_L3);
% 
% o3_ReBe_M_1968_L2=lire_fichier_o3('ReBe_M_1968.o3', {'Vertebre_L2'});
% 
% M_L2=calcul_repere_vertebre_tl(o3_ReBe_M_1968_L2);
% 
% o3_ReBe_M_1968_L1=lire_fichier_o3('ReBe_M_1968.o3', {'Vertebre_L1'});
% 
% M_L1=calcul_repere_vertebre_tl(o3_ReBe_M_1968_L1);
% 
% o3_ReBe_M_1968_T12=lire_fichier_o3('ReBe_M_1968.o3', {'Vertebre_T12'});
% 
% M_T12=calcul_repere_vertebre_tl(o3_ReBe_M_1968_T12);

