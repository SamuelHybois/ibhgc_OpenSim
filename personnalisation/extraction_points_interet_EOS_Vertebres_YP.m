function [reperes,points]=extraction_points_interet_EOS_Vertebres_YP(dir_regions,rep_wrl,protocol,rep_billes_cc)
%% Lecture des fichiers DDR  
File_regions_Cerv = 'Vertebre_C3_CS.ddr';
Reg_cerv = lire_fichier_ddr(fullfile(dir_regions, File_regions_Cerv));
Regions_Cerv3=RegtyI2tyII(Reg_cerv,'Polygones');

File_regions_Cerv = 'Vertebre_C4_CS.ddr';
Reg_cerv = lire_fichier_ddr(fullfile(dir_regions, File_regions_Cerv));
Regions_Cerv4=RegtyI2tyII(Reg_cerv,'Polygones');

File_regions_Cerv = 'Vertebre_C5_CS.ddr';
Reg_cerv = lire_fichier_ddr(fullfile(dir_regions, File_regions_Cerv));
Regions_Cerv5=RegtyI2tyII(Reg_cerv,'Polygones');

File_regions_Cerv = 'Vertebre_C6_CS.ddr';
Reg_cerv = lire_fichier_ddr(fullfile(dir_regions, File_regions_Cerv));
Regions_Cerv6=RegtyI2tyII(Reg_cerv,'Polygones');

File_regions_Cerv = 'Vertebre_C7_CS.ddr';
Reg_cerv = lire_fichier_ddr(fullfile(dir_regions, File_regions_Cerv));
Regions_Cerv7=RegtyI2tyII(Reg_cerv,'Polygones');

File_regions_Thor = 'Vertebre_T1.ddr';
Reg_thor = lire_fichier_ddr(fullfile(dir_regions, File_regions_Thor));
Regions_Thor1=RegtyI2tyII(Reg_thor,'Polygones');

File_regions_Thor = 'Vertebre_T2.ddr';
Reg_thor = lire_fichier_ddr(fullfile(dir_regions, File_regions_Thor));
Regions_Thor2=RegtyI2tyII(Reg_thor,'Polygones');

File_regions_Thor = 'Vertebre_T3.ddr';
Reg_thor = lire_fichier_ddr(fullfile(dir_regions, File_regions_Thor));
Regions_Thor3=RegtyI2tyII(Reg_thor,'Polygones');

File_regions_Thor = 'Vertebre_T4.ddr';
Reg_thor = lire_fichier_ddr(fullfile(dir_regions, File_regions_Thor));
Regions_Thor4=RegtyI2tyII(Reg_thor,'Polygones');
 
File_regions_Thor = 'Vertebre_T5.ddr';
Reg_thor = lire_fichier_ddr(fullfile(dir_regions, File_regions_Thor));
Regions_Thor5=RegtyI2tyII(Reg_thor,'Polygones');
 
File_regions_Thor = 'Vertebre_T6.ddr';
Reg_thor = lire_fichier_ddr(fullfile(dir_regions, File_regions_Thor));
Regions_Thor6=RegtyI2tyII(Reg_thor,'Polygones');
 
File_regions_Thor = 'Vertebre_T7.ddr';
Reg_thor = lire_fichier_ddr(fullfile(dir_regions, File_regions_Thor));
Regions_Thor7=RegtyI2tyII(Reg_thor,'Polygones');
 
File_regions_Thor = 'Vertebre_T8.ddr';
Reg_thor = lire_fichier_ddr(fullfile(dir_regions, File_regions_Thor));
Regions_Thor8=RegtyI2tyII(Reg_thor,'Polygones');
 
File_regions_Thor = 'Vertebre_T9.ddr';
Reg_thor = lire_fichier_ddr(fullfile(dir_regions, File_regions_Thor));
Regions_Thor9=RegtyI2tyII(Reg_thor,'Polygones');
 
File_regions_Thor = 'Vertebre_T10.ddr';
Reg_thor = lire_fichier_ddr(fullfile(dir_regions, File_regions_Thor));
Regions_Thor10=RegtyI2tyII(Reg_thor,'Polygones');
 
File_regions_Thor = 'Vertebre_T11.ddr';
Reg_thor = lire_fichier_ddr(fullfile(dir_regions, File_regions_Thor));
Regions_Thor11=RegtyI2tyII(Reg_thor,'Polygones');
 
File_regions_Thor = 'Vertebre_T12.ddr';
Reg_thor = lire_fichier_ddr(fullfile(dir_regions, File_regions_Thor));
Regions_Thor12=RegtyI2tyII(Reg_thor,'Polygones');
 
File_regions_Lomb = 'Vertebre_L1.ddr';
Reg_lomb= lire_fichier_ddr(fullfile(dir_regions, File_regions_Lomb ));
Regions_Lomb1=RegtyI2tyII(Reg_lomb,'Polygones');

File_regions_Lomb = 'Vertebre_L2.ddr';
Reg_lomb= lire_fichier_ddr(fullfile(dir_regions, File_regions_Lomb ));
Regions_Lomb2=RegtyI2tyII(Reg_lomb,'Polygones');

File_regions_Lomb = 'Vertebre_L3.ddr';
Reg_lomb= lire_fichier_ddr(fullfile(dir_regions, File_regions_Lomb ));
Regions_Lomb3=RegtyI2tyII(Reg_lomb,'Polygones');

File_regions_Lomb = 'Vertebre_L4.ddr';
Reg_lomb= lire_fichier_ddr(fullfile(dir_regions, File_regions_Lomb ));
Regions_Lomb4=RegtyI2tyII(Reg_lomb,'Polygones');

File_regions_Lomb = 'Vertebre_L5.ddr';
Reg_lomb= lire_fichier_ddr(fullfile(dir_regions, File_regions_Lomb ));
Regions_Lomb5=RegtyI2tyII(Reg_lomb,'Polygones');

File_regions_Bassin = 'MG_Bassin_Femme.ddr';
Reg_bassin= lire_fichier_ddr(fullfile(dir_regions, File_regions_Bassin ));
Regions_Bassin=RegtyI2tyII(Reg_bassin,'Polygones');

%% Lecture des fichiers wrl
C3 = lire_fichier_vrml(fullfile(rep_wrl,'Vertebre_C3.wrl'));
C4 = lire_fichier_vrml(fullfile(rep_wrl,'Vertebre_C4.wrl'));
C5 = lire_fichier_vrml(fullfile(rep_wrl,'Vertebre_C5.wrl'));
C6 = lire_fichier_vrml(fullfile(rep_wrl,'Vertebre_C6.wrl'));
C7 = lire_fichier_vrml(fullfile(rep_wrl,'Vertebre_C7.wrl'));
T1 = lire_fichier_vrml(fullfile(rep_wrl,'Vertebre_T1.wrl'));
T2 = lire_fichier_vrml(fullfile(rep_wrl,'Vertebre_T2.wrl'));
T3 = lire_fichier_vrml(fullfile(rep_wrl,'Vertebre_T3.wrl'));
T4 = lire_fichier_vrml(fullfile(rep_wrl,'Vertebre_T4.wrl'));
T5 = lire_fichier_vrml(fullfile(rep_wrl,'Vertebre_T5.wrl'));
T6 = lire_fichier_vrml(fullfile(rep_wrl,'Vertebre_T6.wrl'));
T7 = lire_fichier_vrml(fullfile(rep_wrl,'Vertebre_T7.wrl'));
T8 = lire_fichier_vrml(fullfile(rep_wrl,'Vertebre_T8.wrl'));
T9 = lire_fichier_vrml(fullfile(rep_wrl,'Vertebre_T9.wrl'));
T10 = lire_fichier_vrml(fullfile(rep_wrl,'Vertebre_T10.wrl'));
T11 = lire_fichier_vrml(fullfile(rep_wrl,'Vertebre_T11.wrl'));
T12 = lire_fichier_vrml(fullfile(rep_wrl,'Vertebre_T12.wrl'));
L1 = lire_fichier_vrml(fullfile(rep_wrl,'Vertebre_L1.wrl'));
L2 = lire_fichier_vrml(fullfile(rep_wrl,'Vertebre_L2.wrl'));
L3 = lire_fichier_vrml(fullfile(rep_wrl,'Vertebre_L3.wrl'));
L4 = lire_fichier_vrml(fullfile(rep_wrl,'Vertebre_L4.wrl'));
L5 = lire_fichier_vrml(fullfile(rep_wrl,'Vertebre_L5.wrl'));
Bassin = lire_fichier_vrml(fullfile(rep_wrl,'Bassin.wrl'));

%% Identification des points d'interet pour calcul des reperes
% Tete
if isfield(protocol,'MARQUEURS_EOS')
    flag=isfield(protocol.MARQUEURS_EOS,'repere_tete');
    if flag==1
        billes_repere_tete = protocol.MARQUEURS_EOS.repere_tete;
        for i_repere_tete=1:size(billes_repere_tete,2)
            cur_bille_a_trouver=billes_repere_tete{i_repere_tete};
            Sphere_wrl=lire_fichier_vrml(fullfile(rep_billes_cc,[cur_bille_a_trouver '.wrl']));
            Sphere = sphere_moindres_carres(Sphere_wrl.Noeuds);
            centre= Sphere.Centre*10^(-3);
            if strcmp(cur_bille_a_trouver,'01_NASI')
                nasion=centre;
            elseif strcmp(cur_bille_a_trouver,'03_EARD')
                orD = centre;
            elseif strcmp(cur_bille_a_trouver,'04_EARG')
                orG = centre;
            end
        end
    end

    % Vertebre Cervicale
    flagcerv=isfield(protocol.MARQUEURS_EOS,'C2etC1');
    if flagcerv==1
        billes_C2etC1 = protocol.MARQUEURS_EOS.C2etC1;
        for i_C2etC1=1:size(billes_C2etC1,2)
            cur_bille_a_trouver=billes_C2etC1{i_C2etC1};
            Sphere_wrl=lire_fichier_vrml(fullfile(rep_billes_cc,[cur_bille_a_trouver '.wrl']));
            Sphere = sphere_moindres_carres(Sphere_wrl.Noeuds);
            centre= Sphere.Centre;
            if strcmp(cur_bille_a_trouver,'C1SUP')
                CentrePS_C1=centre;
            elseif strcmp(cur_bille_a_trouver,'C1INF')
                CentrePI_C1=centre;
            elseif strcmp(cur_bille_a_trouver,'C2SUP')
                CentrePS_C2=centre;
            elseif strcmp(cur_bille_a_trouver,'C2INF')
                CentrePI_C2=centre;
            end
        end
    end
end

%C3
[Plateau_sup]=ISOLE_SURF_MAILLAGE('Polygones',Regions_Cerv3.Plateau_sup.Polygones,C3);
CentrePS_C3=barycentre(Plateau_sup.Noeuds);
                       
[Plateau_inf]=ISOLE_SURF_MAILLAGE('Polygones',Regions_Cerv3.Plateau_inf.Polygones,C3);
CentrePI_C3=barycentre(Plateau_inf.Noeuds);
                     
[Apophyse_Transverse_G]=ISOLE_SURF_MAILLAGE('Polygones',Regions_Cerv3.Apophyse_Transverse_G.Polygones,C3);
CentreApG_C3=barycentre(Apophyse_Transverse_G.Noeuds);
                      
[Apophyse_Transverse_D]=ISOLE_SURF_MAILLAGE('Polygones',Regions_Cerv3.Apophyse_Transverse_D.Polygones,C3);
CentreApD_C3=barycentre(Apophyse_Transverse_D.Noeuds);

% C4
[Plateau_sup]=ISOLE_SURF_MAILLAGE('Polygones',Regions_Cerv4.Plateau_sup.Polygones,C4);
CentrePS_C4=barycentre(Plateau_sup.Noeuds);
                       
[Plateau_inf]=ISOLE_SURF_MAILLAGE('Polygones',Regions_Cerv4.Plateau_inf.Polygones,C4);
CentrePI_C4=barycentre(Plateau_inf.Noeuds);
                     
[Apophyse_Transverse_G]=ISOLE_SURF_MAILLAGE('Polygones',Regions_Cerv4.Apophyse_Transverse_G.Polygones,C4);
CentreApG_C4=barycentre(Apophyse_Transverse_G.Noeuds);
                      
[Apophyse_Transverse_D]=ISOLE_SURF_MAILLAGE('Polygones',Regions_Cerv4.Apophyse_Transverse_D.Polygones,C4);
CentreApD_C4=barycentre(Apophyse_Transverse_D.Noeuds);

% C5
[Plateau_sup]=ISOLE_SURF_MAILLAGE('Polygones',Regions_Cerv5.Plateau_sup.Polygones,C5);
CentrePS_C5=barycentre(Plateau_sup.Noeuds);
                       
[Plateau_inf]=ISOLE_SURF_MAILLAGE('Polygones',Regions_Cerv5.Plateau_inf.Polygones,C5);
CentrePI_C5=barycentre(Plateau_inf.Noeuds);
                     
[Apophyse_Transverse_G]=ISOLE_SURF_MAILLAGE('Polygones',Regions_Cerv5.Apophyse_Transverse_G.Polygones,C5);
CentreApG_C5=barycentre(Apophyse_Transverse_G.Noeuds);
                      
[Apophyse_Transverse_D]=ISOLE_SURF_MAILLAGE('Polygones',Regions_Cerv5.Apophyse_Transverse_D.Polygones,C5);
CentreApD_C5=barycentre(Apophyse_Transverse_D.Noeuds);

%C6
[Plateau_sup]=ISOLE_SURF_MAILLAGE('Polygones',Regions_Cerv6.Plateau_sup.Polygones,C6);
CentrePS_C6=barycentre(Plateau_sup.Noeuds);
                       
[Plateau_inf]=ISOLE_SURF_MAILLAGE('Polygones',Regions_Cerv6.Plateau_inf.Polygones,C6);
CentrePI_C6=barycentre(Plateau_inf.Noeuds);
                     
[Apophyse_Transverse_G]=ISOLE_SURF_MAILLAGE('Polygones',Regions_Cerv6.Apophyse_Transverse_G.Polygones,C6);
CentreApG_C6=barycentre(Apophyse_Transverse_G.Noeuds);
                      
[Apophyse_Transverse_D]=ISOLE_SURF_MAILLAGE('Polygones',Regions_Cerv6.Apophyse_Transverse_D.Polygones,C6);
CentreApD_C6=barycentre(Apophyse_Transverse_D.Noeuds);

%C7
[Plateau_sup]=ISOLE_SURF_MAILLAGE('Polygones',Regions_Cerv7.Plateau_sup.Polygones,C7);
CentrePS_C7=barycentre(Plateau_sup.Noeuds);
                       
[Plateau_inf]=ISOLE_SURF_MAILLAGE('Polygones',Regions_Cerv7.Plateau_inf.Polygones,C7);
CentrePI_C7=barycentre(Plateau_inf.Noeuds);
                     
[Apophyse_Transverse_G]=ISOLE_SURF_MAILLAGE('Polygones',Regions_Cerv7.Apophyse_Transverse_G.Polygones,C7);
CentreApG_C7=barycentre(Apophyse_Transverse_G.Noeuds);
                      
[Apophyse_Transverse_D]=ISOLE_SURF_MAILLAGE('Polygones',Regions_Cerv7.Apophyse_Transverse_D.Polygones,C7);
CentreApD_C7=barycentre(Apophyse_Transverse_D.Noeuds);


% Vertebres Thoraciques
%T1
[Plat_inf_T1] = ISOLE_SURF_MAILLAGE('Polygones',Regions_Thor1.plat_inf.Polygones,T1);
CentrePI_T1 = barycentre(Plat_inf_T1.Noeuds);

[Plat_sup_T1] = ISOLE_SURF_MAILLAGE('Polygones',Regions_Thor1.plat_sup.Polygones,T1);
CentrePS_T1 = barycentre(Plat_sup_T1.Noeuds);

[Pedicule_G_T1] = ISOLE_SURF_MAILLAGE('Polygones',Regions_Thor1.pedicule_g.Polygones,T1);
CentrePedG_T1 = barycentre(Pedicule_G_T1.Noeuds);

[Pedicule_D_T1] = ISOLE_SURF_MAILLAGE('Polygones',Regions_Thor1.pedicule_d.Polygones,T1);
CentrePedD_T1 = barycentre(Pedicule_D_T1.Noeuds);

%T2
[Plat_inf_T2] = ISOLE_SURF_MAILLAGE('Polygones',Regions_Thor2.plat_inf.Polygones,T2);
CentrePI_T2 = barycentre(Plat_inf_T2.Noeuds);

[Plat_sup_T2] = ISOLE_SURF_MAILLAGE('Polygones',Regions_Thor2.plat_sup.Polygones,T2);
CentrePS_T2 = barycentre(Plat_sup_T2.Noeuds);

[Pedicule_G_T2] = ISOLE_SURF_MAILLAGE('Polygones',Regions_Thor2.pedicule_g.Polygones,T2);
CentrePedG_T2 = barycentre(Pedicule_G_T2.Noeuds);

[Pedicule_D_T2] = ISOLE_SURF_MAILLAGE('Polygones',Regions_Thor2.pedicule_d.Polygones,T2);
CentrePedD_T2 = barycentre(Pedicule_D_T2.Noeuds);

%T3
[Plat_inf_T3] = ISOLE_SURF_MAILLAGE('Polygones',Regions_Thor3.plat_inf.Polygones,T3);
CentrePI_T3 = barycentre(Plat_inf_T3.Noeuds);

[Plat_sup_T3] = ISOLE_SURF_MAILLAGE('Polygones',Regions_Thor3.plat_sup.Polygones,T3);
CentrePS_T3 = barycentre(Plat_sup_T3.Noeuds);

[Pedicule_G_T3] = ISOLE_SURF_MAILLAGE('Polygones',Regions_Thor3.pedicule_g.Polygones,T3);
CentrePedG_T3 = barycentre(Pedicule_G_T3.Noeuds);

[Pedicule_D_T3] = ISOLE_SURF_MAILLAGE('Polygones',Regions_Thor3.pedicule_d.Polygones,T3);
CentrePedD_T3 = barycentre(Pedicule_D_T3.Noeuds);

%T4
[Plat_inf_T4] = ISOLE_SURF_MAILLAGE('Polygones',Regions_Thor4.plat_inf.Polygones,T4);
CentrePI_T4 = barycentre(Plat_inf_T4.Noeuds);

[Plat_sup_T4] = ISOLE_SURF_MAILLAGE('Polygones',Regions_Thor4.plat_sup.Polygones,T4);
CentrePS_T4 = barycentre(Plat_sup_T4.Noeuds);

[Pedicule_G_T4] = ISOLE_SURF_MAILLAGE('Polygones',Regions_Thor4.pedicule_g.Polygones,T4);
CentrePedG_T4 = barycentre(Pedicule_G_T4.Noeuds);

[Pedicule_D_T4] = ISOLE_SURF_MAILLAGE('Polygones',Regions_Thor4.pedicule_d.Polygones,T4);
CentrePedD_T4 = barycentre(Pedicule_D_T4.Noeuds);

%T5
[Plat_inf_T5] = ISOLE_SURF_MAILLAGE('Polygones',Regions_Thor5.plat_inf.Polygones,T5);
CentrePI_T5 = barycentre(Plat_inf_T5.Noeuds);

[Plat_sup_T5] = ISOLE_SURF_MAILLAGE('Polygones',Regions_Thor5.plat_sup.Polygones,T5);
CentrePS_T5 = barycentre(Plat_sup_T5.Noeuds);

[Pedicule_G_T5] = ISOLE_SURF_MAILLAGE('Polygones',Regions_Thor5.pedicule_g.Polygones,T5);
CentrePedG_T5 = barycentre(Pedicule_G_T5.Noeuds);

[Pedicule_D_T5] = ISOLE_SURF_MAILLAGE('Polygones',Regions_Thor5.pedicule_d.Polygones,T5);
CentrePedD_T5 = barycentre(Pedicule_D_T5.Noeuds);

%T6
[Plat_inf_T6] = ISOLE_SURF_MAILLAGE('Polygones',Regions_Thor6.plat_inf.Polygones,T6);
CentrePI_T6 = barycentre(Plat_inf_T6.Noeuds);

[Plat_sup_T6] = ISOLE_SURF_MAILLAGE('Polygones',Regions_Thor6.plat_sup.Polygones,T6);
CentrePS_T6 = barycentre(Plat_sup_T6.Noeuds);

[Pedicule_G_T6] = ISOLE_SURF_MAILLAGE('Polygones',Regions_Thor6.pedicule_g.Polygones,T6);
CentrePedG_T6 = barycentre(Pedicule_G_T6.Noeuds);

[Pedicule_D_T6] = ISOLE_SURF_MAILLAGE('Polygones',Regions_Thor6.pedicule_d.Polygones,T6);
CentrePedD_T6 = barycentre(Pedicule_D_T6.Noeuds);

%T7
[Plat_inf_T7] = ISOLE_SURF_MAILLAGE('Polygones',Regions_Thor7.plat_inf.Polygones,T7);
CentrePI_T7 = barycentre(Plat_inf_T7.Noeuds);

[Plat_sup_T7] = ISOLE_SURF_MAILLAGE('Polygones',Regions_Thor7.plat_sup.Polygones,T7);
CentrePS_T7 = barycentre(Plat_sup_T7.Noeuds);

[Pedicule_G_T7] = ISOLE_SURF_MAILLAGE('Polygones',Regions_Thor7.pedicule_g.Polygones,T7);
CentrePedG_T7 = barycentre(Pedicule_G_T7.Noeuds);

[Pedicule_D_T7] = ISOLE_SURF_MAILLAGE('Polygones',Regions_Thor7.pedicule_d.Polygones,T7);
CentrePedD_T7 = barycentre(Pedicule_D_T7.Noeuds);

%T8
[Plat_inf_T8] = ISOLE_SURF_MAILLAGE('Polygones',Regions_Thor8.plat_inf.Polygones,T8);
CentrePI_T8 = barycentre(Plat_inf_T8.Noeuds);

[Plat_sup_T8] = ISOLE_SURF_MAILLAGE('Polygones',Regions_Thor8.plat_sup.Polygones,T8);
CentrePS_T8 = barycentre(Plat_sup_T8.Noeuds);

[Pedicule_G_T8] = ISOLE_SURF_MAILLAGE('Polygones',Regions_Thor8.pedicule_g.Polygones,T8);
CentrePedG_T8 = barycentre(Pedicule_G_T8.Noeuds);

[Pedicule_D_T8] = ISOLE_SURF_MAILLAGE('Polygones',Regions_Thor8.pedicule_d.Polygones,T8);
CentrePedD_T8 = barycentre(Pedicule_D_T8.Noeuds);

%T9
[Plat_inf_T9] = ISOLE_SURF_MAILLAGE('Polygones',Regions_Thor9.plat_inf.Polygones,T9);
CentrePI_T9 = barycentre(Plat_inf_T9.Noeuds);

[Plat_sup_T9] = ISOLE_SURF_MAILLAGE('Polygones',Regions_Thor9.plat_sup.Polygones,T9);
CentrePS_T9 = barycentre(Plat_sup_T9.Noeuds);

[Pedicule_G_T9] = ISOLE_SURF_MAILLAGE('Polygones',Regions_Thor9.pedicule_g.Polygones,T9);
CentrePedG_T9 = barycentre(Pedicule_G_T9.Noeuds);

[Pedicule_D_T9] = ISOLE_SURF_MAILLAGE('Polygones',Regions_Thor9.pedicule_d.Polygones,T9);
CentrePedD_T9 = barycentre(Pedicule_D_T9.Noeuds);

%T10
[Plat_inf_T10] = ISOLE_SURF_MAILLAGE('Polygones',Regions_Thor10.plat_inf.Polygones,T10);
CentrePI_T10 = barycentre(Plat_inf_T10.Noeuds);

[Plat_sup_T10] = ISOLE_SURF_MAILLAGE('Polygones',Regions_Thor10.plat_sup.Polygones,T10);
CentrePS_T10 = barycentre(Plat_sup_T10.Noeuds);

[Pedicule_G_T10] = ISOLE_SURF_MAILLAGE('Polygones',Regions_Thor10.pedicule_g.Polygones,T10);
CentrePedG_T10 = barycentre(Pedicule_G_T10.Noeuds);

[Pedicule_D_T10] = ISOLE_SURF_MAILLAGE('Polygones',Regions_Thor10.pedicule_d.Polygones,T10);
CentrePedD_T10 = barycentre(Pedicule_D_T10.Noeuds);

%T11
[Plat_inf_T11] = ISOLE_SURF_MAILLAGE('Polygones',Regions_Thor11.plat_inf.Polygones,T11);
CentrePI_T11 = barycentre(Plat_inf_T11.Noeuds);

[Plat_sup_T11] = ISOLE_SURF_MAILLAGE('Polygones',Regions_Thor11.plat_sup.Polygones,T11);
CentrePS_T11 = barycentre(Plat_sup_T11.Noeuds);

[Pedicule_G_T11] = ISOLE_SURF_MAILLAGE('Polygones',Regions_Thor11.pedicule_g.Polygones,T11);
CentrePedG_T11 = barycentre(Pedicule_G_T11.Noeuds);

[Pedicule_D_T11] = ISOLE_SURF_MAILLAGE('Polygones',Regions_Thor11.pedicule_d.Polygones,T11);
CentrePedD_T11 = barycentre(Pedicule_D_T11.Noeuds);

%T12
[Plat_inf_T12] = ISOLE_SURF_MAILLAGE('Polygones',Regions_Thor12.plat_inf.Polygones,T12);
CentrePI_T12 = barycentre(Plat_inf_T12.Noeuds);

[Plat_sup_T12] = ISOLE_SURF_MAILLAGE('Polygones',Regions_Thor12.plat_sup.Polygones,T12);
CentrePS_T12 = barycentre(Plat_sup_T12.Noeuds);

[Pedicule_G_T12] = ISOLE_SURF_MAILLAGE('Polygones',Regions_Thor12.pedicule_g.Polygones,T12);
CentrePedG_T12 = barycentre(Pedicule_G_T12.Noeuds);

[Pedicule_D_T12] = ISOLE_SURF_MAILLAGE('Polygones',Regions_Thor12.pedicule_d.Polygones,T12);
CentrePedD_T12 = barycentre(Pedicule_D_T12.Noeuds);

% Vertebres Lombaires
%L1
[Plat_inf_L1] = ISOLE_SURF_MAILLAGE('Polygones',Regions_Lomb1.plat_inf.Polygones,L1);
CentrePI_L1 = barycentre(Plat_inf_L1.Noeuds);

[Plat_sup_L1] = ISOLE_SURF_MAILLAGE('Polygones',Regions_Lomb1.plat_sup.Polygones,L1);
CentrePS_L1 = barycentre(Plat_sup_L1.Noeuds);

[Pedicule_G_L1] = ISOLE_SURF_MAILLAGE('Polygones',Regions_Lomb1.pedicule_g.Polygones,L1);
CentrePedG_L1 = barycentre(Pedicule_G_L1.Noeuds);

[Pedicule_D_L1] = ISOLE_SURF_MAILLAGE('Polygones',Regions_Lomb1.pedicule_d.Polygones,L1);
CentrePedD_L1 = barycentre(Pedicule_D_L1.Noeuds);

%L2
[Plat_inf_L2] = ISOLE_SURF_MAILLAGE('Polygones',Regions_Lomb2.plat_inf.Polygones,L2);
CentrePI_L2 = barycentre(Plat_inf_L2.Noeuds);

[Plat_sup_L2] = ISOLE_SURF_MAILLAGE('Polygones',Regions_Lomb2.plat_sup.Polygones,L2);
CentrePS_L2 = barycentre(Plat_sup_L2.Noeuds);

[Pedicule_G_L2] = ISOLE_SURF_MAILLAGE('Polygones',Regions_Lomb2.pedicule_g.Polygones,L2);
CentrePedG_L2 = barycentre(Pedicule_G_L2.Noeuds);

[Pedicule_D_L2] = ISOLE_SURF_MAILLAGE('Polygones',Regions_Lomb2.pedicule_d.Polygones,L2);
CentrePedD_L2 = barycentre(Pedicule_D_L2.Noeuds);

%L3
[Plat_sup_L3] = ISOLE_SURF_MAILLAGE('Polygones',Regions_Lomb3.plat_sup.Polygones,L3);
CentrePS_L3 = barycentre(Plat_sup_L3.Noeuds);

[Plat_inf_L3] = ISOLE_SURF_MAILLAGE('Polygones',Regions_Lomb3.plat_inf.Polygones,L3);
CentrePI_L3 = barycentre(Plat_inf_L3.Noeuds);

[Pedicule_G_L3] = ISOLE_SURF_MAILLAGE('Polygones',Regions_Lomb3.pedicule_g.Polygones,L3);
CentrePedG_L3 = barycentre(Pedicule_G_L3.Noeuds);

[Pedicule_D_L3] = ISOLE_SURF_MAILLAGE('Polygones',Regions_Lomb3.pedicule_d.Polygones,L3);
CentrePedD_L3 = barycentre(Pedicule_D_L3.Noeuds);

%L4
[Plat_sup_L4] = ISOLE_SURF_MAILLAGE('Polygones',Regions_Lomb4.plat_sup.Polygones,L4);
CentrePS_L4 = barycentre(Plat_sup_L4.Noeuds);

[Plat_inf_L4] = ISOLE_SURF_MAILLAGE('Polygones',Regions_Lomb4.plat_inf.Polygones,L4);
CentrePI_L4 = barycentre(Plat_inf_L4.Noeuds);

[Pedicule_G_L4] = ISOLE_SURF_MAILLAGE('Polygones',Regions_Lomb4.pedicule_g.Polygones,L4);
CentrePedG_L4 = barycentre(Pedicule_G_L4.Noeuds);

[Pedicule_D_L4] = ISOLE_SURF_MAILLAGE('Polygones',Regions_Lomb4.pedicule_d.Polygones,L4);
CentrePedD_L4 = barycentre(Pedicule_D_L4.Noeuds);

%L5
[Plat_sup_L5] = ISOLE_SURF_MAILLAGE('Polygones',Regions_Lomb5.plat_sup.Polygones,L5);
CentrePS_L5 = barycentre(Plat_sup_L5.Noeuds);

[Plat_inf_L5] = ISOLE_SURF_MAILLAGE('Polygones',Regions_Lomb5.plat_inf.Polygones,L5);
CentrePI_L5 = barycentre(Plat_inf_L5.Noeuds);

[Pedicule_G_L5] = ISOLE_SURF_MAILLAGE('Polygones',Regions_Lomb5.pedicule_g.Polygones,L5);
CentrePedG_L5 = barycentre(Pedicule_G_L5.Noeuds);

[Pedicule_D_L5] = ISOLE_SURF_MAILLAGE('Polygones',Regions_Lomb5.pedicule_d.Polygones,L5);
CentrePedD_L5 = barycentre(Pedicule_D_L5.Noeuds);


%Bassin
% Accetabulum G
AcetaG = ISOLE_SURF_MAILLAGE('Polygones',Regions_Bassin.Acetabulum_G.Polygones,Bassin);
AG = sphere_moindres_carres(AcetaG.Noeuds); 
AG=AG.Centre;

% Accetabulum D
AcetaD = ISOLE_SURF_MAILLAGE('Polygones',Regions_Bassin.Acetabulum_D.Polygones,Bassin);
AD = sphere_moindres_carres(AcetaD.Noeuds); 
AD=AD.Centre;

%Plateau sacré
[SacralPlate] = ISOLE_SURF_MAILLAGE('Polygones',Regions_Bassin.Plateau_Sacrum.Polygones,Bassin);
SP = barycentre(SacralPlate.Noeuds);

[EpineSciat_G] = ISOLE_SURF_MAILLAGE('Polygones',Regions_Bassin.EPINE_SCIAT_G.Polygones,Bassin);
[EpineSciat_D] = ISOLE_SURF_MAILLAGE('Polygones',Regions_Bassin.EPINE_SCIAT_D.Polygones,Bassin);
[NormaleVerticale,~] = plan_moindres_carres([barycentre(EpineSciat_G.Noeuds); barycentre(EpineSciat_D.Noeuds); AD; AG]);
if NormaleVerticale(3)<0
    NormaleVerticale = -NormaleVerticale; % on veut que la normale soit dirigée vers le haut
end

%% Centre de rotation des vertebres
HJC_D = AD;
HJC_G = AG;
L5JC=(SP+CentrePI_L5)/2;
L4JC=(CentrePS_L5+CentrePI_L4)/2;
L3JC=(CentrePS_L4+CentrePI_L3)/2;
L2JC=(CentrePS_L3+CentrePI_L2)/2;
L1JC=(CentrePS_L2+CentrePI_L1)/2;
T12JC=(CentrePS_L1+CentrePI_T12)/2;
T11JC=(CentrePS_T12+CentrePI_T11)/2;
T10JC=(CentrePS_T11+CentrePI_T10)/2;
T9JC=(CentrePS_T10+CentrePI_T9)/2;
T8JC=(CentrePS_T9+CentrePI_T8)/2;
T7JC=(CentrePS_T8+CentrePI_T7)/2;
T6JC=(CentrePS_T7+CentrePI_T6)/2;
T5JC=(CentrePS_T6+CentrePI_T5)/2;
T4JC=(CentrePS_T5+CentrePI_T4)/2;
T3JC=(CentrePS_T4+CentrePI_T3)/2;
T2JC=(CentrePS_T3+CentrePI_T2)/2;
T1JC=(CentrePS_T2+CentrePI_T1)/2;
C7JC=(CentrePS_T1+CentrePI_C7)/2;
C6JC=(CentrePS_C7+CentrePI_C6)/2;
C5JC=(CentrePS_C6+CentrePI_C5)/2;
C4JC=(CentrePS_C5+CentrePI_C4)/2;
C3JC=(CentrePS_C4+CentrePI_C3)/2;
C2JC=CentrePS_C3;

if flagcerv==1
    C2JC=(CentrePS_C3+CentrePI_C2)/2;
    C1JC=(CentrePS_C2+CentrePI_C1)/2;
    C2center=(CentrePS_C2+CentrePI_C2)/2;
    C1center=(CentrePS_C1+CentrePI_C1)/2;
    if flag==1
        skullJC=(CentrePS_C1+((orD+orG)*10^3/2))/2;
        skullcenter=((orD+orG)*10^3/2);
    end
end

%% Calcul des repères body
% Tete
if flag==1 && flagcerv==1
    M_R0_RTete=calcul_reperes_harmo_YP('tete',nasion*10^3,orD*10^3,orG*10^3);
    PT=M_R0_RTete\[skullJC',[1 1 1]';1,1];
    skullJC_Rt=PT(1:3,1); 
end

%Bassin
M_R0_Rb=calcul_reperes_harmo_YP('bassin',AD,AG,NormaleVerticale);
PT=M_R0_Rb\[L5JC',[1 1 1]';1,1];
L5JC_Rb=PT(1:3,1);

PT=M_R0_Rb\[HJC_D',HJC_G';1,1];
HJC_D_Rb=PT(1:3,1);
HJC_G_Rb=PT(1:3,2);

% Vertebres Lombaires
M_R0_RL5=calcul_reperes_harmo_YP('lombaire',CentrePI_L5,CentrePS_L5,CentrePedG_L5,CentrePedD_L5);
PT=M_R0_RL5\[L4JC',L5JC';1,1];
L4JC_RL5=PT(1:3,1);
L5JC_RL5=PT(1:3,2);

M_R0_RL4=calcul_reperes_harmo_YP('lombaire',CentrePI_L4,CentrePS_L4,CentrePedG_L4,CentrePedD_L4);
PT=M_R0_RL4\[L3JC',L4JC';1,1];
L3JC_RL4=PT(1:3,1);
L4JC_RL4=PT(1:3,2);

M_R0_RL3=calcul_reperes_harmo_YP('lombaire',CentrePI_L3,CentrePS_L3,CentrePedG_L3,CentrePedD_L3);
PT=M_R0_RL3\[L2JC',L3JC';1,1];
L2JC_RL3=PT(1:3,1);
L3JC_RL3=PT(1:3,2);

M_R0_RL2=calcul_reperes_harmo_YP('lombaire',CentrePI_L2,CentrePS_L2,CentrePedG_L2,CentrePedD_L2);
PT=M_R0_RL2\[L1JC',L2JC';1,1];
L1JC_RL2=PT(1:3,1);
L2JC_RL2=PT(1:3,2);

M_R0_RL1=calcul_reperes_harmo_YP('lombaire',CentrePI_L1,CentrePS_L1,CentrePedG_L1,CentrePedD_L1);
PT=M_R0_RL1\[T12JC',L1JC';1,1];
T12JC_RL1=PT(1:3,1);
L1JC_RL1=PT(1:3,2);

% Vertebres Thoraciques
M_R0_RT12=calcul_reperes_harmo_YP('thoracique',CentrePI_T12,CentrePS_T12,CentrePedG_T12,CentrePedD_T12);
PT=M_R0_RT12\[T11JC',T12JC';1,1];
T11JC_RT12=PT(1:3,1);
T12JC_RT12=PT(1:3,2);

M_R0_RT11=calcul_reperes_harmo_YP('thoracique',CentrePI_T11,CentrePS_T11,CentrePedG_T11,CentrePedD_T11);
PT=M_R0_RT11\[T10JC',T11JC';1,1];
T10JC_RT11=PT(1:3,1);
T11JC_RT11=PT(1:3,2);

M_R0_RT10=calcul_reperes_harmo_YP('thoracique',CentrePI_T10,CentrePS_T10,CentrePedG_T10,CentrePedD_T10);
PT=M_R0_RT10\[T9JC',T10JC';1,1];
T9JC_RT10=PT(1:3,1);
T10JC_RT10=PT(1:3,2);

M_R0_RT9=calcul_reperes_harmo_YP('thoracique',CentrePI_T9,CentrePS_T9,CentrePedG_T9,CentrePedD_T9);
PT=M_R0_RT9\[T8JC',T9JC';1,1];
T8JC_RT9=PT(1:3,1);
T9JC_RT9=PT(1:3,2);

M_R0_RT8=calcul_reperes_harmo_YP('thoracique',CentrePI_T8,CentrePS_T8,CentrePedG_T8,CentrePedD_T8);
PT=M_R0_RT8\[T7JC',T8JC';1,1];
T7JC_RT8=PT(1:3,1);
T8JC_RT8=PT(1:3,2);

M_R0_RT7=calcul_reperes_harmo_YP('thoracique',CentrePI_T7,CentrePS_T7,CentrePedG_T7,CentrePedD_T7);
PT=M_R0_RT7\[T6JC',T7JC';1,1];
T6JC_RT7=PT(1:3,1);
T7JC_RT7=PT(1:3,2);

M_R0_RT6=calcul_reperes_harmo_YP('thoracique',CentrePI_T6,CentrePS_T6,CentrePedG_T6,CentrePedD_T6);
PT=M_R0_RT6\[T5JC',T6JC';1,1];
T5JC_RT6=PT(1:3,1);
T6JC_RT6=PT(1:3,2);

M_R0_RT5=calcul_reperes_harmo_YP('thoracique',CentrePI_T5,CentrePS_T5,CentrePedG_T5,CentrePedD_T5);
PT=M_R0_RT5\[T4JC',T5JC';1,1];
T4JC_RT5=PT(1:3,1);
T5JC_RT5=PT(1:3,2);

M_R0_RT4=calcul_reperes_harmo_YP('thoracique',CentrePI_T4,CentrePS_T4,CentrePedG_T4,CentrePedD_T4);
PT=M_R0_RT4\[T3JC',T4JC';1,1];
T3JC_RT4=PT(1:3,1);
T4JC_RT4=PT(1:3,2);

M_R0_RT3=calcul_reperes_harmo_YP('thoracique',CentrePI_T3,CentrePS_T3,CentrePedG_T3,CentrePedD_T3);
PT=M_R0_RT3\[T2JC',T3JC';1,1];
T2JC_RT3=PT(1:3,1);
T3JC_RT3=PT(1:3,2);

M_R0_RT2=calcul_reperes_harmo_YP('thoracique',CentrePI_T2,CentrePS_T2,CentrePedG_T2,CentrePedD_T2);
PT=M_R0_RT2\[T1JC',T2JC';1,1];
T1JC_RT2=PT(1:3,1);
T2JC_RT2=PT(1:3,2);

M_R0_RT1=calcul_reperes_harmo_YP('thoracique',CentrePI_T1,CentrePS_T1,CentrePedG_T1,CentrePedD_T1);
PT=M_R0_RT1\[C7JC',T1JC';1,1];
C7JC_RT1=PT(1:3,1);
T1JC_RT1=PT(1:3,2);

% Vertebres Cervicales
M_R0_RC7=calcul_reperes_harmo_YP('cervicale',CentrePI_C7,CentrePS_C7,CentreApG_C7,CentreApD_C7);
PT=M_R0_RC7\[C6JC',C7JC';1,1];
C6JC_RC7=PT(1:3,1);
C7JC_RC7=PT(1:3,2);

M_R0_RC6=calcul_reperes_harmo_YP('cervicale',CentrePI_C6,CentrePS_C6,CentreApG_C6,CentreApD_C6);
PT=M_R0_RC6\[C5JC',C6JC';1,1];
C5JC_RC6=PT(1:3,1);
C6JC_RC6=PT(1:3,2);

M_R0_RC5=calcul_reperes_harmo_YP('cervicale',CentrePI_C5,CentrePS_C5,CentreApG_C5,CentreApD_C5);
PT=M_R0_RC5\[C4JC',C5JC';1,1];
C4JC_RC5=PT(1:3,1);
C5JC_RC5=PT(1:3,2);

M_R0_RC4=calcul_reperes_harmo_YP('cervicale',CentrePI_C4,CentrePS_C4,CentreApG_C4,CentreApD_C4);
PT=M_R0_RC4\[C3JC',C4JC';1,1];
C3JC_RC4=PT(1:3,1);
C4JC_RC4=PT(1:3,2);

M_R0_RC3=calcul_reperes_harmo_YP('cervicale',CentrePI_C3,CentrePS_C3,CentreApG_C3,CentreApD_C3);
PT=M_R0_RC3\[C2JC',C3JC';1,1];
C2JC_RC3=PT(1:3,1);
C3JC_RC3=PT(1:3,2);

if flagcerv==1
    PT=M_R0_RC3\[C2center',C1center';1,1];
    centreC2_RC3=PT(1:3,1);
    centreC1_RC3=PT(1:3,2);

    PT=M_R0_RC3\[C1JC',[1 1 1]';1,1];
    C1JC_RC3=PT(1:3,1);
   
    if flag==1
        PT=M_R0_RC3\[skullcenter',[1 1 1]';1,1];
        skullcenter_RC3=PT(1:3,1);

        PT=M_R0_RC3\[skullJC',[1 1 1]';1,1];
        skullJC_RC3=PT(1:3,1);
    end
end

%% Calcul des COM de chaque vertèbre
%En se basant sur Vette et al. 2010
PT=M_R0_RL5\[([5.982; 0; 19.38]+M_R0_RL5(1:3,4)),[1 1 1]';1,1];
COM_L5_RL5=PT(1:3,1);

PT=M_R0_RL4\[([7.678; 0; 19.826]+M_R0_RL4(1:3,4)),[1 1 1]';1,1];
COM_L4_RL4=PT(1:3,1);

PT=M_R0_RL3\[([13.168; 0; 20.094]+M_R0_RL3(1:3,4)),[1 1 1]';1,1];
COM_L3_RL3=PT(1:3,1);

PT=M_R0_RL2\[([22.478; 0; 18.844]+M_R0_RL2(1:3,4)),[1 1 1]';1,1];
COM_L2_RL2=PT(1:3,1);

PT=M_R0_RL1\[([30.324; 0; 19.021]+M_R0_RL1(1:3,4)),[1 1 1]';1,1];
COM_L1_RL1=PT(1:3,1);

PT=M_R0_RT12\[([33.825; 0; 17.45]+M_R0_RT12(1:3,4)),[1 1 1]';1,1];
COM_T12_RT12=PT(1:3,1);

PT=M_R0_RT11\[([37.827; 0; 16.046]+M_R0_RT11(1:3,4)),[1 1 1]';1,1];
COM_T11_RT11=PT(1:3,1);

PT=M_R0_RT10\[([38.44; 0; 13.61]+M_R0_RT10(1:3,4)),[1 1 1]';1,1];
COM_T10_RT10=PT(1:3,1);

PT=M_R0_RT9\[([39.873; 0; 14.144]+M_R0_RT9(1:3,4)),[1 1 1]';1,1];
COM_T9_RT9=PT(1:3,1);

PT=M_R0_RT8\[([41.575; 0; 13.697]+M_R0_RT8(1:3,4)),[1 1 1]';1,1];
COM_T8_RT8=PT(1:3,1);

PT=M_R0_RT7\[([39.643; 0; 13.766]+M_R0_RT7(1:3,4)),[1 1 1]';1,1];
COM_T7_RT7=PT(1:3,1);

PT=M_R0_RT6\[([35.851; 0; 13.284]+M_R0_RT6(1:3,4)),[1 1 1]';1,1];
COM_T6_RT6=PT(1:3,1);

PT=M_R0_RT5\[([27.803; 0; 12.378]+M_R0_RT5(1:3,4)),[1 1 1]';1,1];
COM_T5_RT5=PT(1:3,1);

PT=M_R0_RT4\[([17.616; 0; 12.153]+M_R0_RT4(1:3,4)),[1 1 1]';1,1];
COM_T4_RT4=PT(1:3,1);

PT=M_R0_RT3\[([6.901; 0; 10.877]+M_R0_RT3(1:3,4)),[1 1 1]';1,1];
COM_T3_RT3=PT(1:3,1);

PT=M_R0_RT2\[([-2.656; 0; 10.24]+M_R0_RT2(1:3,4)),[1 1 1]';1,1];
COM_T2_RT2=PT(1:3,1);

PT=M_R0_RT1\[([-14.056; 0; 8.788]+M_R0_RT1(1:3,4)),[1 1 1]';1,1];
COM_T1_RT1=PT(1:3,1);

PT=M_R0_RC7\[([-23.228; 0; 7.883]+M_R0_RC7(1:3,4)),[1 1 1]';1,1];
COM_C7_RC7=PT(1:3,1);

PT=M_R0_RC6\[([-29.729; 0; 7.064]+M_R0_RC6(1:3,4)),[1 1 1]';1,1];
COM_C6_RC6=PT(1:3,1);

PT=M_R0_RC5\[([-20.076; 0; 7.986]+M_R0_RC5(1:3,4)),[1 1 1]';1,1];
COM_C5_RC5=PT(1:3,1);

PT=M_R0_RC4\[([-3.262; 0; 8.76]+M_R0_RC4(1:3,4)),[1 1 1]';1,1];
COM_C4_RC4=PT(1:3,1);

PT=M_R0_RC3\[([3.578; 0; 9.759]+M_R0_RC3(1:3,4)),[1 1 1]';1,1];
COM_C3_RC3=PT(1:3,1);

%% On range les données dans des structures pour la sortie
if flag==1 && flagcerv==1
    reperes.tete=M_R0_RTete;
end
reperes.bassin=M_R0_Rb;
reperes.lumbar5=M_R0_RL5;
reperes.lumbar4=M_R0_RL4;
reperes.lumbar3=M_R0_RL3;
reperes.lumbar2=M_R0_RL2;
reperes.lumbar1=M_R0_RL1;
reperes.thor12=M_R0_RT12;
reperes.thor11=M_R0_RT11;
reperes.thor10=M_R0_RT10;
reperes.thor9=M_R0_RT9;
reperes.thor8=M_R0_RT8;
reperes.thor7=M_R0_RT7;
reperes.thor6=M_R0_RT6;
reperes.thor5=M_R0_RT5;
reperes.thor4=M_R0_RT4;
reperes.thor3=M_R0_RT3;
reperes.thor2=M_R0_RT2;
reperes.thor1=M_R0_RT1;
reperes.cerv7=M_R0_RC7;
reperes.cerv6=M_R0_RC6;
reperes.cerv5=M_R0_RC5;
reperes.cerv4=M_R0_RC4;
reperes.cerv3=M_R0_RC3;

points.HJC_D_Rb=HJC_D_Rb;
points.HJC_G_Rb=HJC_G_Rb;
points.L5JC_Rb=L5JC_Rb;
points.L5JC_RL5=L5JC_RL5;
points.L4JC_RL5=L4JC_RL5;
points.L4JC_RL4=L4JC_RL4;
points.L3JC_RL4=L3JC_RL4;
points.L3JC_RL3=L3JC_RL3;
points.L2JC_RL3=L2JC_RL3;
points.L2JC_RL2=L2JC_RL2;
points.L1JC_RL2=L1JC_RL2;
points.L1JC_RL1=L1JC_RL1;
points.T12JC_RL1=T12JC_RL1;
points.T12JC_RT12=T12JC_RT12;
points.T11JC_RT12=T11JC_RT12;
points.T11JC_RT11=T11JC_RT11;
points.T10JC_RT11=T10JC_RT11;
points.T10JC_RT10=T10JC_RT10;
points.T9JC_RT10=T9JC_RT10;
points.T9JC_RT9=T9JC_RT9;
points.T8JC_RT9=T8JC_RT9;
points.T8JC_RT8=T8JC_RT8;
points.T7JC_RT8=T7JC_RT8;
points.T7JC_RT7=T7JC_RT7;
points.T6JC_RT7=T6JC_RT7;
points.T6JC_RT6=T6JC_RT6;
points.T5JC_RT6=T5JC_RT6;
points.T5JC_RT5=T5JC_RT5;
points.T4JC_RT5=T4JC_RT5;
points.T4JC_RT4=T4JC_RT4;
points.T3JC_RT4=T3JC_RT4;
points.T3JC_RT3=T3JC_RT3;
points.T2JC_RT3=T2JC_RT3;
points.T2JC_RT2=T2JC_RT2;
points.T1JC_RT2=T1JC_RT2;
points.T1JC_RT1=T1JC_RT1;
points.C7JC_RT1=C7JC_RT1;
points.C7JC_RC7=C7JC_RC7;
points.C6JC_RC7=C6JC_RC7;
points.C6JC_RC6=C6JC_RC6;
points.C5JC_RC6=C5JC_RC6;
points.C5JC_RC5=C5JC_RC5;
points.C4JC_RC5=C4JC_RC5;
points.C4JC_RC4=C4JC_RC4;
points.C3JC_RC4=C3JC_RC4;
points.C3JC_RC3=C3JC_RC3;
points.C2JC_RC3=C2JC_RC3;
if flagcerv==1
    points.C1JC_RC3=C1JC_RC3;
    points.centreC2_RC3=centreC2_RC3;
    points.centreC1_RC3=centreC1_RC3;
    if flag==1
        points.skullJC_Rt=skullJC_Rt;
        points.skullJC_RC3=skullJC_RC3;
        points.skullcenter_RC3=skullcenter_RC3;
    end
end
points.COM_L5_RL5=COM_L5_RL5;
points.COM_L4_RL4=COM_L4_RL4;
points.COM_L3_RL3=COM_L3_RL3;
points.COM_L2_RL2=COM_L2_RL2;
points.COM_L1_RL1=COM_L1_RL1;
points.COM_T12_RT12=COM_T12_RT12;
points.COM_T11_RT11=COM_T11_RT11;
points.COM_T10_RT10=COM_T10_RT10;
points.COM_T9_RT9=COM_T9_RT9;
points.COM_T8_RT8=COM_T8_RT8;
points.COM_T7_RT7=COM_T7_RT7;
points.COM_T6_RT6=COM_T6_RT6;
points.COM_T5_RT5=COM_T5_RT5;
points.COM_T4_RT4=COM_T4_RT4;
points.COM_T3_RT3=COM_T3_RT3;
points.COM_T2_RT2=COM_T2_RT2;
points.COM_T1_RT1=COM_T1_RT1;
points.COM_C7_RC7=COM_C7_RC7;
points.COM_C6_RC6=COM_C6_RC6;
points.COM_C5_RC5=COM_C5_RC5;
points.COM_C4_RC4=COM_C4_RC4;
points.COM_C3_RC3=COM_C3_RC3;


end
