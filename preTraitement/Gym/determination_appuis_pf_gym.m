function [pied_D,pied_G,main_D,main_G]=determination_appuis_pf_gym(c3d_file,M_pass_Vicon_OS,noms_efforts,rapport_frequence,cell_marqueurs)

acq=btkReadAcquisition(c3d_file); % Lecture du fichier c3d
[pf_data,pf_info]=btkGetForcePlatforms(acq); % Extraction des données des plateformes de force
marker_data=btkGetMarkers(acq); % Extraction des données des marqueurs
list_mrk=fieldnames(marker_data);
nb_frame=size(marker_data.(list_mrk{1}),1);
marker_data=zero2NaN(marker_data);
marker_data=NettoieMarkerLabels(marker_data);

SeuilHauteurMain=40;
SeuilHauteurPied=130;

%% Determiner quel appui est utilisé dans ce mouvement
%Pour ne pas faire de calculs inutiles
PD=0;PG=0;MD=0;MG=0; %Initialisation

for i_effort=1:length(noms_efforts)
    if  contains(noms_efforts{i_effort},'foot') || contains(noms_efforts{i_effort},'pied')
        if contains(noms_efforts{i_effort},'right') || contains(noms_efforts{i_effort},'droit')
            PD=1;
        elseif contains(noms_efforts{i_effort},'left') || contains(noms_efforts{i_effort},'gauche')
            PG=1;
        end
    elseif contains(noms_efforts{i_effort},'hand') || contains(noms_efforts{i_effort},'main')
        if contains(noms_efforts{i_effort},'right') || contains(noms_efforts{i_effort},'droit')
            MD=1;
        elseif contains(noms_efforts{i_effort},'left') || contains(noms_efforts{i_effort},'gauche')
            MG=1;
        end
    end
end

%% Définition des marqueurs à utiliser
pied_D.nom='pied_D';pied_D.marqueurs=cell_marqueurs(1,:);
pied_G.nom='pied_G';pied_G.marqueurs=cell_marqueurs(2,:);
main_D.nom='main_D';main_D.marqueurs=cell_marqueurs(3,:);
main_G.nom='main_G';main_G.marqueurs=cell_marqueurs(4,:);

%% On stocke les données des marqueurs dans des structures
%Pieds
pied_D.marker_data.(pied_D.marqueurs{1})=marker_data.(pied_D.marqueurs{1});
pied_D.marker_data.(pied_D.marqueurs{2})=marker_data.(pied_D.marqueurs{2});
pied_D.marker_data.(pied_D.marqueurs{3})=marker_data.(pied_D.marqueurs{3});

pied_G.marker_data.(pied_G.marqueurs{1})=marker_data.(pied_G.marqueurs{1});
pied_G.marker_data.(pied_G.marqueurs{2})=marker_data.(pied_G.marqueurs{2});
pied_G.marker_data.(pied_G.marqueurs{3})=marker_data.(pied_G.marqueurs{3});

%Mains
main_D.marker_data.(main_D.marqueurs{1})=marker_data.(main_D.marqueurs{1});
main_D.marker_data.(main_D.marqueurs{2})=marker_data.(main_D.marqueurs{2});
main_D.marker_data.(main_D.marqueurs{3})=marker_data.(main_D.marqueurs{3});

main_G.marker_data.(main_G.marqueurs{1})=marker_data.(main_G.marqueurs{1});
main_G.marker_data.(main_G.marqueurs{2})=marker_data.(main_G.marqueurs{2});
main_G.marker_data.(main_G.marqueurs{3})=marker_data.(main_G.marqueurs{3});

%% On récupère les points d'applications des forces mesurées par les plateformes de force dans le repère OS
data_c3d=btk_loadc3d(c3d_file);

for i_pf=1:size(pf_data,1)
    FP=['FP', num2str(i_pf)];
    %avec prise en compte du sous échantillonage
    xyz_location_of_force.(FP)=[data_c3d.fp_data.GRF_data(i_pf).P(1:rapport_frequence:end,1) data_c3d.fp_data.GRF_data(i_pf).P(1:rapport_frequence:end,2) data_c3d.fp_data.GRF_data(i_pf).P(1:rapport_frequence:end,3)];
    %Passage repère OS
    xyz_location_of_force.(FP)=xyz_location_of_force.(FP)*M_pass_Vicon_OS;
end

%% Sous échantillonage des plateformes de force
%Pour synchroniser à Vicon
new_pf_data=struct;
for i_pf=1:size(pf_data,1)
    list_effort=fieldnames(pf_data(i_pf).channels);
    for i_effort=1:size(list_effort,1)
        new_pf_data(i_pf).channels.(list_effort{i_effort})=pf_data(i_pf).channels.(list_effort{i_effort})(1:rapport_frequence:end);
    end
end

%% Détermination des plateformes sur lesquelles le sujet a ses appuis
pied_D.FP(nb_frame)=0;pied_D.CoM(nb_frame,3)=0;
pied_G.FP(nb_frame)=0;pied_G.CoM(nb_frame,3)=0;
main_D.FP(nb_frame)=0;main_D.CoM(nb_frame,3)=0;
main_G.FP(nb_frame)=0;main_G.CoM(nb_frame,3)=0;


for i_frame=1:nb_frame
    if PD==1
        pied_D=determination_plateforme_force(i_frame,pf_data,new_pf_data,marker_data,pied_D);
    end
    if PG==1
        pied_G=determination_plateforme_force(i_frame,pf_data,new_pf_data,marker_data,pied_G);
    end
    if MD==1
        main_D=determination_plateforme_force(i_frame,pf_data,new_pf_data,marker_data,main_D);
    end
    if MG==1
        main_G=determination_plateforme_force(i_frame,pf_data,new_pf_data,marker_data,main_G);
    end
end

%% Si le pied/la main est trop haut il ne peut physiquement pas être sur la plateforme

for i_frame=1:nb_frame
   if  pied_D.CoM(i_frame,3)>SeuilHauteurPied
       pied_D.FP(i_frame)=5;
   end
   if  pied_G.CoM(i_frame,3)>SeuilHauteurPied
       pied_G.FP(i_frame)=5;
   end
   if  main_D.CoM(i_frame,3)>SeuilHauteurMain
       main_D.FP(i_frame)=5;
   end
   if  main_G.CoM(i_frame,3)>SeuilHauteurMain
       main_G.FP(i_frame)=5;
   end
end

%% Lissage des FP sur lesquelles on n'a pas pu conclure (et les CoM qui vont avec)
%Si pendant quelques frames on ne sait pas sur quelle plateforme se trouve
%un membre (NaN) et que la dernière plateforme connue est identique à la
%première plateforme retrouvée, on remplace les NaN par cette même
%plateforme
for j_frame=2:nb_frame-1
    if MD==1
        if isnan(main_D.FP(j_frame))
            k=j_frame+1;
            while isnan(main_D.FP(k)) && k<nb_frame
                k=k+1;
            end
            %on lisse le CoM en x/y/z via une interpolation linéaire
            valeur_interp_CoM_x=interp1([j_frame-1 k],[main_D.CoM(j_frame-1,1) main_D.CoM(k,1)],j_frame-1:1:k);
            valeur_interp_CoM_y=interp1([j_frame-1 k],[main_D.CoM(j_frame-1,2) main_D.CoM(k,2)],j_frame-1:1:k);
            valeur_interp_CoM_z=interp1([j_frame-1 k],[main_D.CoM(j_frame-1,3) main_D.CoM(k,3)],j_frame-1:1:k);
            for n=j_frame:k-1
                main_D.CoM(n,:)= [valeur_interp_CoM_x(n-j_frame+2) valeur_interp_CoM_y(n-j_frame+2) valeur_interp_CoM_z(n-j_frame+2)];
            end
            %On remplace les FP si possible
            if main_D.FP(j_frame-1)==main_D.FP(k)
                for n=j_frame:k-1
                    main_D.FP(n)=main_D.FP(j_frame-1);
                end
            end
        end
    end
    if MG==1
        if isnan(main_G.FP(j_frame))
            k=j_frame+1;
            while isnan(main_G.FP(k)) && k<nb_frame
                k=k+1;
            end
            valeur_interp_CoM_x=interp1([j_frame-1 k],[main_G.CoM(j_frame-1,1) main_G.CoM(k,1)],j_frame-1:1:k);
            valeur_interp_CoM_y=interp1([j_frame-1 k],[main_G.CoM(j_frame-1,2) main_G.CoM(k,2)],j_frame-1:1:k);
            valeur_interp_CoM_z=interp1([j_frame-1 k],[main_G.CoM(j_frame-1,3) main_G.CoM(k,3)],j_frame-1:1:k);
            for n=j_frame:k-1
                main_G.CoM(n,:)= [valeur_interp_CoM_x(n-j_frame+2) valeur_interp_CoM_y(n-j_frame+2) valeur_interp_CoM_z(n-j_frame+2)];
            end
            if main_G.FP(j_frame-1)==main_G.FP(k)
                for n=j_frame:k-1
                    main_G.FP(n)=main_G.FP(j_frame-1);
                end
            end
        end
    end
    if PD==1
        if isnan(pied_D.FP(j_frame))
            k=j_frame+1;
            while isnan(pied_D.FP(k)) && k<nb_frame
                k=k+1;
            end
            valeur_interp_CoM_x=interp1([j_frame-1 k],[pied_D.CoM(j_frame-1,1) pied_D.CoM(k,1)],j_frame-1:1:k);
            valeur_interp_CoM_y=interp1([j_frame-1 k],[pied_D.CoM(j_frame-1,2) pied_D.CoM(k,2)],j_frame-1:1:k);
            valeur_interp_CoM_z=interp1([j_frame-1 k],[pied_D.CoM(j_frame-1,3) pied_D.CoM(k,3)],j_frame-1:1:k);
            for n=j_frame:k-1
                pied_D.CoM(n,:)= [valeur_interp_CoM_x(n-j_frame+2) valeur_interp_CoM_y(n-j_frame+2) valeur_interp_CoM_z(n-j_frame+2)];
            end
            if pied_D.FP(j_frame-1)==pied_D.FP(k)
                for n=j_frame:k-1
                    pied_D.FP(n)=pied_D.FP(j_frame-1);
                end
            end
        end
    end
    if PG==1
        if isnan(pied_G.FP(j_frame))
            k=j_frame+1;
            while isnan(pied_G.FP(k)) && k<nb_frame
                k=k+1;
            end
            valeur_interp_CoM_x=interp1([j_frame-1 k],[pied_G.CoM(j_frame-1,1) pied_G.CoM(k,1)],j_frame-1:1:k);
            valeur_interp_CoM_y=interp1([j_frame-1 k],[pied_G.CoM(j_frame-1,2) pied_G.CoM(k,2)],j_frame-1:1:k);
            valeur_interp_CoM_z=interp1([j_frame-1 k],[pied_G.CoM(j_frame-1,3) pied_G.CoM(k,3)],j_frame-1:1:k);
            for n=j_frame:k-1
                pied_G.CoM(n,:)= [valeur_interp_CoM_x(n-j_frame+2) valeur_interp_CoM_y(n-j_frame+2) valeur_interp_CoM_z(n-j_frame+2)];
            end
            if pied_G.FP(j_frame-1)==pied_G.FP(k)
                for n=j_frame:k-1
                    pied_G.FP(n)=pied_G.FP(j_frame-1);
                end
            end
        end
    end
end
    
%% On prépare le traitement des doubes appuis
% On stocke les plateforme associées à chaque appuis pour chaque frame et les CoM des mains et des pieds
appuis=[];CoM=struct;
if PD==1
    appuis=cat(2,appuis,pied_D.FP');
    CoM.pied_droit=pied_D.CoM*M_pass_Vicon_OS;
else
    appuis=cat(2,appuis,zeros(nb_frame,1));
end
if PG==1
    appuis=cat(2,appuis,pied_G.FP');
    CoM.pied_gauche=pied_G.CoM*M_pass_Vicon_OS;
else
    appuis=cat(2,appuis,zeros(nb_frame,1));
end
if MD==1
    appuis=cat(2,appuis,main_D.FP');
    CoM.main_droite=main_D.CoM*M_pass_Vicon_OS;
else
    appuis=cat(2,appuis,zeros(nb_frame,1));
end
if MG==1
    appuis=cat(2,appuis,main_G.FP');
    CoM.main_gauche=main_G.CoM*M_pass_Vicon_OS;
else
    appuis=cat(2,appuis,zeros(nb_frame,1));
end

%% Avertissement si des appuis ne sont pas entièrement sur une plateforme
if ~isempty(find(appuis > 13,1))
    disp('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx')
    disp('Nous avons détecté que certains appuis ne sont pas entièrement sur les plateformes,')
    disp("Les résultats riquent d'être érronés")
    disp('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx')
end
if ismember(12,appuis)
    disp('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx')
    disp('Nous avons détecté que certains appuis sont à cheval entre les plateformes 1 et 2,')
    disp("Les résultats riquent d'être érronés")
    disp('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx')
end


%% Calcul des torseurs d'efforts
if PD==1
    pied_D.torseur=Calcul_effort_ext_gym(pied_D,new_pf_data,M_pass_Vicon_OS,pf_info,pf_data,appuis,xyz_location_of_force,CoM);
else
    pied_D.torseur=zeros(nb_frame,9);
end
if PG==1
    pied_G.torseur=Calcul_effort_ext_gym(pied_G,new_pf_data,M_pass_Vicon_OS,pf_info,pf_data,appuis,xyz_location_of_force,CoM);
else
    pied_G.torseur=zeros(nb_frame,9);
end
if MD==1
    main_D.torseur=Calcul_effort_ext_gym(main_D,new_pf_data,M_pass_Vicon_OS,pf_info,pf_data,appuis,xyz_location_of_force,CoM);
else
    main_D.torseur=zeros(nb_frame,9);
end
if MD==1
    main_G.torseur=Calcul_effort_ext_gym(main_G,new_pf_data,M_pass_Vicon_OS,pf_info,pf_data,appuis,xyz_location_of_force,CoM);
else
    main_G.torseur=zeros(nb_frame,9);
end

end