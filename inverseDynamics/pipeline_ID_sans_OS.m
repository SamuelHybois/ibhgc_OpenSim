<<<<<<< HEAD
function res_ID=pipeline_ID_sans_OS(rep_global,cur_sujet,cur_activity,cur_acquisition,st_prot,path_model,base_expression)
disp('Début de la dynamique inverse')
%% Ouverture fichiers
% Modèle OpenSim
struct_model_OS=xml_readOSIM_TJ(path_model);
[struct_bodies,struct_joints]=extract_KinChainData_ModelOS(struct_model_OS);
list_bodies=fieldnames(struct_bodies);
% Fichier des coordonnées généralisées
file_coord=[cur_acquisition(1:end-4),'_ik_lisse.mot'];
coord_gene=load_sto_file(fullfile(rep_global,cur_sujet,cur_activity,file_coord));
freq_cine=1/(coord_gene.time(2)-coord_gene.time(1));
% Fichier des efforts
file_effort=[cur_acquisition(1:end-4),'.mot'];
efforts=load_sto_file(fullfile(rep_global,cur_sujet,cur_activity,file_effort));
mat_efforts=cell2mat(struct2cell(efforts)');
% Nom du fichier de sortie
cur_nom_ID=[cur_acquisition(1:end-4),'_ID.sto'];
nom_fich_sortie=fullfile(rep_global,cur_sujet,cur_activity,cur_nom_ID);

%% Calcul des matrices homogènes
struct_MH=calcul_MH(struct_model_OS,coord_gene);
=======
function pipeline_ID_sans_OS(rep_global,cur_sujet,cur_activity,cur_acquisition,st_prot,path_model,base_expression)

%% Déclaration chemins
% rep_global='E:\Stage_Marsan_Golf_Biomechanics\Personal_Work\Donnees\Donnees_traitees';
% cur_sujet='golf_037_PLE';
% file_coord='golf_037_PLE_coupdriver_01_ik_lisse.mot';
% file_effort='golf_037_PLE_coupdriver_01.mot';
% file_prot='juin_2017_IBHGC_fullbodyV4_golf.protOS';
% file_model='golf_037_PLE_model_final.osim';

%% Ouverture fichiers
struct_model_OS=xml_readOSIM_TJ(path_model);
[struct_bodies,struct_joints]=extract_KinChainData_ModelOS(struct_model_OS);
% st_prot=lire_fichier_prot_2(fullfile(rep_global,'info_global',file_prot));
file_coord=[cur_acquisition(1:end-4),'_ik.mot'];
coord_gene=load_sto_file(fullfile(rep_global,cur_sujet,cur_activity,file_coord));
freq_cine=1/(coord_gene.time(2)-coord_gene.time(1));
file_effort=[cur_acquisition(1:end-4),'_grf.mot'];
efforts=load_sto_file(fullfile(rep_global,cur_sujet,cur_activity,file_effort));
mat_efforts=cell2mat(struct2cell(efforts)');
list_bodies=fieldnames(struct_bodies);

%% Calcul des matrices homogènes
[~,struct_MH] = cinematiqueDirecte(struct_bodies,coord_gene);
>>>>>>> dev_diane_ENSAM

%% Initiatlisation nb_frame
list_bodies=fieldnames(struct_bodies);
nb_body=size(list_bodies,1);
nb_frame=size(struct_MH.(list_bodies{end}).MH,3);

%% Détermination des chaines du modèle
chaines_modele=calcul_chaines(struct_bodies);

%% Détemination axe de gravité
axe_gravite=struct_bodies.(list_bodies{chaines_modele.ind_ground}).gravity;

%% Transformation des efforts extérieurs en matrice d'action mécanique
% Ré-échantillonage des efforts pour correspondre à la fréquence de
% cinématique
nb_frame_cine=size(coord_gene.time,1);
time_effort=efforts.time;
nb_effort=size(mat_efforts,2);
mat_effort_bis(nb_frame_cine,nb_effort)=0;
frame_init_cine=coord_gene.time(1);
frame_fin_cine=coord_gene.time(end);

ind_debut=find(abs(time_effort-frame_init_cine)==min(abs(time_effort-frame_init_cine)));
ind_fin=find(abs(time_effort-frame_fin_cine)==min(abs(time_effort-frame_fin_cine)));
temps_effort=(linspace(frame_init_cine,frame_fin_cine,ind_fin-ind_debut+1))';
for i_effort=1:nb_effort
    mat_effort_bis(:,i_effort)=interp1(temps_effort,mat_efforts(ind_debut:ind_fin,i_effort),coord_gene.time);
end

% Transformation efforts extérieurs
efforts_ext=st_prot.EFFORTS_EXT;
efforts_ext_R0=cell(size(efforts_ext.nom,2),2);
for i_effort=1:size(efforts_ext.nom,2)
    Mat=mat_effort_bis(:,((i_effort-1)*9+1)+[1:3,7:9]);
    efforts_ext_R0{i_effort,1}=Mat2D_2_MH(Mat,'dynamique',1);
    if ~strcmpi(efforts_ext.expression_body{i_effort},'ground') % Test si l'effort n'est pas exprimé dans le ground
        % Repasser dans le ground
        efforts_ext_R0{i_effort,1}=changement_repere_Legnani(efforts_ext_R0{i_effort,1},struct_MH.(efforts_ext.expression_body{i_effort}),repmat(eye(4,4),[1,1,nb_frame]),'dynamique');
    end
    efforts_ext_R0{i_effort,2}=efforts_ext.applied_body{i_effort};
    efforts_ext_R0{i_effort,3}=find(strcmp(list_bodies,efforts_ext_R0{i_effort,2})); % Rajouter indice body
end

%% Calcul du torseur d'effort du poids

for i_body=1:nb_body
    cur_body=list_bodies{i_body};
<<<<<<< HEAD
    if isfield(struct_MH,cur_body) && ~strcmp(cur_body,'ground')
=======
    if isfield(struct_MH,cur_body);
>>>>>>> dev_diane_ENSAM
        PIS=struct_bodies.(cur_body).BSIP; % Masse, coord centre de masse, moments d'inertie, produit d'inertie];
        mass_center_R0=repmat(eye(4,4),[1,1,nb_frame]);
        poids=PIS(1)*axe_gravite;
        Mat_poids=repmat([poids,0,0,0],[nb_frame,1]);
        MH_poids=Mat2D_2_MH(Mat_poids,'dynamique',1);
        for i_frame=1:nb_frame
            mass_center_R0(:,4,i_frame)=struct_MH.(cur_body).MH(:,:,i_frame)*[PIS(2:4),1]';
        end
        MH_poids_R0.(cur_body)=changement_repere_Legnani(MH_poids,mass_center_R0,repmat(eye(4,4),[1,1,nb_frame]),'dynamique');
    end
end

%% Calcul des matrices du torseur dynamique
for i_body=1:nb_body
    cur_body=list_bodies{i_body};
    % Initialisation matrices
    acceleration.(cur_body)=zeros(4,4,nb_frame);
    dyn_R0.(cur_body)=zeros(4,4,nb_frame);
    J_R0.(cur_body)=zeros(4,4,nb_frame);
<<<<<<< HEAD
    if isfield(struct_MH,cur_body) && ~strcmp(cur_body,'ground')
=======
    if isfield(struct_MH,cur_body)
>>>>>>> dev_diane_ENSAM
        MH_derive=derive_MH(derive_MH(struct_MH.(cur_body).MH,freq_cine),freq_cine); % Dérivation de la matrice homogène (2 fois) pour calculer l'accélération des segments
        PIS=struct_bodies.(cur_body).BSIP;
        % Définition des paramètres inertiels
        Ixx=(-PIS(5)+PIS(6)+PIS(7))/2;
        Iyy=(PIS(5)-PIS(6)+PIS(7))/2;
        Izz=(PIS(5)+PIS(6)-PIS(7))/2;
        % Matrice de pseudo-inertie dans le repère segment
        J_Rs=[[Ixx,PIS(8),PIS(9);PIS(8),Iyy,PIS(10);PIS(9),PIS(10),Izz],...
            PIS(1)*PIS(2:4)';PIS(1)*PIS(2:4),PIS(1)];
        for i_frame=1:nb_frame
            J_R0.(cur_body)(:,:,i_frame)=struct_MH.(cur_body).MH(:,:,i_frame)*J_Rs*struct_MH.(cur_body).MH(:,:,i_frame)'; % Matrice de pseudo-inertie dans R0
            acceleration.(cur_body)(:,:,i_frame)=MH_derive(:,:,i_frame)*struct_MH.(cur_body).MH(:,:,i_frame)'; % Matrice d'accélération dans R0
            dyn_R0.(cur_body)(:,:,i_frame)=acceleration.(cur_body)(:,:,i_frame)*J_R0.(cur_body)(:,:,i_frame)-J_R0.(cur_body)(:,:,i_frame)*acceleration.(cur_body)(:,:,i_frame)';
        end
    end
end

%% Calcul effort intersegmentaire
% ATTENTION ON NE GERE QUE LES CHAINES OUVERTES DANS LE MODELE
% Chaines entre une extrémité et un noeud
Mr0rvoulu(4,4,nb_frame)=0;
Mr0rdistal(4,4,nb_frame)=0;
for i_chaine_nf=1:size(chaines_modele.noeud_fin,2)
    list_seg=chaines_modele.noeud_fin{i_chaine_nf};
    add_dyn=zeros(4,4,nb_frame);
    add_poids=zeros(4,4,nb_frame);
    add_ext=zeros(4,4,nb_frame);
    for i_seg=1:size(list_seg,2)-1
        cur_body=list_bodies{list_seg(i_seg)};
        nom_joint=struct_bodies.(cur_body).Joints;
<<<<<<< HEAD
        cur_parent=struct_bodies.(cur_body).Parent{1};
=======
        cur_parent=struct_bodies.(cur_body).Parent;
>>>>>>> dev_diane_ENSAM
        % Addition torseur dynamique, poids, effort ext dans R0
        add_dyn=add_dyn+dyn_R0.(cur_body);
        add_poids=add_poids+MH_poids_R0.(cur_body);
        tmp=find(cell2mat(efforts_ext_R0(:,3))==list_seg(i_seg));
        if ~isempty(tmp)
            for i_effort_ext=1:size(tmp,1)
                add_ext=add_ext+efforts_ext_R0{tmp(i_effort_ext)};  %Régler le sous échantillonage
            end
        end
        add_all=add_dyn-add_poids-add_ext;
        % Changement de repère vers repère voulu
        % Récupérer MH_c et non MH_c_inv pour éviter d'inverser une
        % inverse
        MH_JointProximal=struct_joints.(nom_joint).MH_p;
<<<<<<< HEAD
        %         JointCenter=MH_JointDistal(:,4);
        for i_frame=1:nb_frame
            Mr0rdistal(:,:,i_frame)=struct_MH.(cur_body).MH(:,:,i_frame)/struct_joints.(nom_joint).MH_c_inv; % Matrice de R0 dans Rdistal
        end
        switch base_expression{1}
=======
%         JointCenter=MH_JointDistal(:,4);
        for i_frame=1:nb_frame
            Mr0rdistal(:,:,i_frame)=struct_MH.(cur_body).MH(:,:,i_frame)/struct_joints.(nom_joint).MH_c_inv; % Matrice de R0 dans Rdistal
        end
        switch base_expression
>>>>>>> dev_diane_ENSAM
            case 'Proximal'
                for i_frame=1:nb_frame
                    Mr0rvoulu(:,:,i_frame)=struct_MH.(cur_parent).MH(:,:,i_frame)*MH_JointProximal; % Matrice de R0 dans Rdistal
                end
                Mr0rvoulu(:,4,:)=Mr0rdistal(:,4,:);
            case 'Distal'
                Mr0rvoulu=Mr0rdistal; % Matrice de R0 dans Rdistal
            case 'JCS'
                disp('faire un autre choix')
        end
        torseur_inter_seg=changement_repere_Legnani(add_all,repmat(eye(4,4),[1,1,nb_frame]),Mr0rvoulu,'dynamique');
        res_ID.(nom_joint)=Mat2D_2_MH(torseur_inter_seg,'dynamique',-1);
    end % i_seg
end

<<<<<<< HEAD
list_joint=fieldnames(struct_joints);
=======
list_joint=fieldnames(struct_joint);
>>>>>>> dev_diane_ENSAM
list_effort_connus=fieldnames(res_ID);
% Chaines entre deux noeuds
while length(list_joint)~=length(list_effort_connus)
    taille_liste_precedente=length(list_effort_connus);
    for i_chaine_nn=1:size(chaines_modele.noeud_noeud,2)
        list_seg=chaines_modele.noeud_noeud{i_chaine_nn};
        % Détermination du sens de lecture
        first_seg=chaines_modele.noeud_noeud{i_chaine_nn}(1);
        first_body=list_bodies{list_seg(1)};
        last_seg=chaines_modele.noeud_noeud{i_chaine_nn}(end);
        if first_seg~=chaines_modele.ind_ground
            Joint_enfant={};
            Joint_parent={};
            for i_joint_parent=1:size(struct_bodies.(first_body).Parent{:,2},1)
                Joint_parent{i_joint_parent}=struct_bodies.(first_body).Joints;
            end
            for i_joint_enfant=1:size(struct_bodies.(first_body).Children,1)
                body_children=struct_bodies.(first_body).Children{i_joint_enfant,1};
                Joint_enfant=[Joint_enfant,struct_bodies.(body_children).Joints];
            end
            Joint_seg=[Joint_parent,Joint_enfant];
            efforts_connus_seg=intersect(Joint_seg,list_effort_connus);
            if size(efforts_connus_seg,1)==size(Joint_seg,2)-1
                % on peut résoudre
                flag=1;
            else % Cas où il faut inverser le sens de lecture
                list_seg_flip=fliplr(list_seg);
                if list_seg_flip(1)==chaines_modele.ind_ground
                    flag=0;
                else
                    first_body_flip=list_bodies{list_seg_flip(1)};
                    Joint_enfant_flip={};
                    Joint_parent_flip=cell(1,size(struct_bodies.(first_body_flip).Parent{:,2},1));
                    for i_joint_parent=1:size(struct_bodies.(first_body_flip).Parent{:,2},1)
                        Joint_parent_flip{i_joint_parent}=struct_bodies.(first_body_flip).Joints;
                    end
                    for i_joint_enfant=1:size(struct_bodies.(first_body_flip).Children,1)
                        body_children=struct_bodies.(first_body_flip).Children{i_joint_enfant,1};
                        Joint_enfant_flip=[Joint_enfant_flip,struct_bodies.(body_children).Joints];
                    end
                    Joint_seg_flip=[Joint_parent_flip,Joint_enfant_flip];
                    efforts_connus_seg_flip=intersect(Joint_seg_flip,list_effort_connus);
                    if size(efforts_connus_seg_flip,1)==size(Joint_seg_flip,2)-1
                        % on peut résoudre
                        flag=1;
                        list_seg=list_seg_flip;
                    else
                        flag=0;
                    end
                end
            end
            if flag==1
                % résoudre
                add_dyn=zeros(4,4,nb_frame);
                add_poids=zeros(4,4,nb_frame);
                add_ext=zeros(4,4,nb_frame);
                for i_seg=1:size(list_seg,2)-1
                    cur_body=list_bodies{list_seg(i_seg)};
                    nom_joint=struct_bodies.(cur_body).Joints;
<<<<<<< HEAD
                    cur_parent=struct_bodies.(cur_body).Parent{1};
=======
                    cur_parent=struct_bodies.(cur_body).Parent;
>>>>>>> dev_diane_ENSAM
                    % Addition torseur dynamique, poids, effort ext dans R0
                    % Dynamique
                    add_dyn=add_dyn+dyn_R0.(cur_body);
                    % Poids
                    add_poids=add_poids+MH_poids_R0.(cur_body);
                    % Effort ext
                    tmp=find(cell2mat(efforts_ext_R0(:,3))==list_seg(i_seg));
                    if ~isempty(tmp)
                        for i_effort_ext=1:size(tmp,1)
                            add_ext=add_ext+efforts_ext_R0{tmp(i_effort_ext)};
                        end
                    end
                    add_all=add_dyn-add_poids-add_ext;
                    % Changement de repère vers repère voulu
                    % Récupérer MH_c et non MH_c_inv pour éviter d'inverser une
                    % inverse
                    MH_JointProximal=struct_joints.(nom_joint).MH_p;
                    MH_JointDistal=inv(struct_joints.(nom_joint).MH_c_inv);
<<<<<<< HEAD
                    %                     JointCenter=MH_JointDistal(:,4);
                    for i_frame=1:nb_frame
                        Mr0rdistal(:,:,i_frame)=struct_MH.(cur_body).MH(:,:,i_frame)/struct_joints.(nom_joint).MH_c_inv; % Matrice de R0 dans Rdistal
                    end
                    switch base_expression{1}
=======
%                     JointCenter=MH_JointDistal(:,4);
                    for i_frame=1:nb_frame
                        Mr0rdistal(:,:,i_frame)=struct_MH.(cur_body).MH(:,:,i_frame)/struct_joints.(nom_joint).MH_c_inv; % Matrice de R0 dans Rdistal
                    end
                    switch base_expression
>>>>>>> dev_diane_ENSAM
                        case 'Proximal'
                            for i_frame=1:nb_frame
                                Mr0rvoulu(:,:,i_frame)=struct_MH.(cur_parent).MH(:,:,i_frame)*MH_JointProximal; % Matrice de R0 dans Rdistal
                            end
                            Mr0rvoulu(:,4,:)=Mr0rdistal(:,4,:);
                        case 'Distal'
                            Mr0rvoulu=Mr0rdistal; % Matrice de R0 dans Rdistal
                        case 'JCS'
                            disp('faire un autre choix')
                    end
                    torseur_inter_seg=changement_repere_Legnani(add_all,repmat(eye(4,4),[1,1,nb_frame]),Mr0rvoulu,'dynamique');
                    res_ID.(nom_joint)=Mat2D_2_MH(torseur_inter_seg,'dynamique',-1);
                end
            end
        end
    end
    list_effort_connus=fieldnames(res_ID);
    if taille_liste_precedente==length(list_effort_connus)
        break
    end
end
<<<<<<< HEAD
%% Ecriture du fichier de sortie
% res_ID est de la forme [Fx,Fy,Fz,Mx,My,Mz] pour chaque articulation
disp('Ecriture du fichier de dynamique inverse')
list_data={'Fx','Fy','Fz','Mx','My','Mz'};
data_ID=struct;
list_effort=fieldnames(res_ID);
for i_coord=1:size(list_effort,1)
    cur_effort=list_effort{i_coord};
    for i_data=1:6
        nom_effort=[cur_effort,'_',list_data{i_data}];
        data_ID.(nom_effort)=res_ID.(cur_effort)(:,i_data);
    end
end
data_ID.time=coord_gene.time;
write_sto_file(data_ID,nom_fich_sortie)
=======
>>>>>>> dev_diane_ENSAM
end