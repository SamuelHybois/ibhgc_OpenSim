function [coordGeneralisee] = cinematiqueInverse(modeleOsim,fichierProtocole,fichierTRC)
[nQ,labelQ,Aeq,beq,l_inf_Model,l_sup_Model] = CoordonneesGeneralisees(modeleOsim) ;
structurePROT = lire_fichier_prot_2(fichierProtocole);
[struct_Bodies, struct_Joints] = extract_KinChainData_ModelOS(modeleOsim,'');
dataTRC = convert_trc_struct(fichierTRC,'matrix');
marqueursTRC = dataTRC.noms;
[marqueursModele,indexMarqueursModele] = extract_MarkerSet_ModelOS(modeleOsim);
[MarkerSet,idx_TRC,idx_Modele] = intersect(marqueursTRC,marqueursModele);
dataTRC.matrix = dataTRC.matrix(idx_TRC,:,:);
dataTRC.noms = dataTRC.noms(idx_TRC,1);
wi = recuperationPoidsMarqueurs(structurePROT,MarkerSet);
wi_mat=cell2mat(wi(:,2));

% nFrames = size(dataTRC.matrix,3);
nFrames = 100;
% q0 = zeros(1,nQ);

%%% q0 "vrai" de l'IK d'OpenSim pour l'essai squat_jump02
%q0 = [-0.0618,0.2507,1.5153,-0.0603,1.0247,-0.2971,-0.2080,-0.1873,-0.1579,0.2017,-0.2017,0.3042,0 ,0 , -0.2676 ,-0.0426 ,-0.0815,0.1825,-0.1825,0.2838,0 ,0];

%%% q0 "vrai" de l'IK d'OpenSim pour l'essai Propulsion_Synchrone de AM01_SD
% modeleOsim = xml_readOSIM_TJ('D:\Samuel\MusculoSkeletalModelling\ameliorationIK_hors_OpenSim\dataTest\AM01SD\modele\AM01SD_model_final.osim',struct('Sequence',true));
% fichierTRC = 'D:\Samuel\MusculoSkeletalModelling\ameliorationIK_hors_OpenSim\dataTest\AM01SD\Propulsion_Synchrone\AM01SD_Propulsion_Synchrone_04.trc';
% fichierProtocole = 'D:\Samuel\MusculoSkeletalModelling\ameliorationIK_hors_OpenSim\dataTest\info_global\FRM_bilateral_STJ.protOS';
q0 = [-0.0231844825445946 -0.109088471317034 -0.180573684273511 -0.584648000000000 1.00960500000000 -0.309290000000000 -0.0287297426440310 0.123135073123302 -0.383512942606580 0.130335236966187 0.115013183449147 0.165100694682758 0.706178436594297 -0.746531531004542 0.559138077398618 1.18946069988347 0.770828783120330 0.698006211624513 -0.0404439737043965 -0.203650741802645 0.166932103573460 0.668426371461714 -0.109381058312839 0.177322240596800 -0.178373871284297 0.767672826406997 -0.801191211466432 -0.598957659563114 1.09794959654291 0.835812417720325 -0.0932216132739837 -0.428126787146671 -0.0147793433861329 0.102638310360316 0.176437341212747 0.00173642807280916 -0.0121455193718258 -0.000578105408138082];
%%
coordGeneralisee = zeros(nFrames,nQ);
Struct_MH_IK = {};
coordGeneralisee(1,:) = q0;
h = waitbar(0,'Inverse Kinematics: 0%');

for i_frame = 2:nFrames
    
    dataTRC_i.matrix = dataTRC.matrix(:,:,i_frame);
    dataTRC_i.noms = dataTRC.noms;
    
    if i_frame ==1
        [qOpt] = frameInitiale(modeleOsim,indexMarqueursModele,dataTRC_i,q0,wi_mat);
        coordGeneralisee(i_frame,:) = qOpt;
    else
        if i_frame > 2
            dq =  coordGeneralisee(i_frame-1,:) - coordGeneralisee(i_frame-2,:);
            qIni = coordGeneralisee(i_frame-1,:) + dq;
        else
            qIni = coordGeneralisee(i_frame-1,:);
        end
        
        l_inf=max(coordGeneralisee(i_frame-1,:)-0.05*l_sup_Model,l_inf_Model);
        l_sup=min(coordGeneralisee(i_frame-1,:)+0.05*l_sup_Model,l_sup_Model);
        
        
        fonctionObj =  @(coordGeneralisee)iterationIKcalculRMSE(modeleOsim,struct_Bodies, struct_Joints,indexMarqueursModele,wi_mat,dataTRC_i,coordGeneralisee,labelQ);
        options = optimoptions(@fmincon,'TolFun',5e-3,'Display','off','Algorithm','sqp');
        
        [qOpt,~,~,~] = fmincon(fonctionObj,qIni,[],[],Aeq,beq,l_inf,l_sup,[],options);
        
        coordGeneralisee(i_frame,:)= qOpt;
        structOpt = traductionQVecteurStruct(qOpt,labelQ);
        [~,Struct_MH] = cinematiqueDirecte(modeleOsim,struct_Bodies, struct_Joints,structOpt,MarkerSet,indexMarqueursModele);
        Struct_MH_IK{i_frame} = Struct_MH;
    end
    h=waitbar(i_frame/nFrames, h, strcat(['Inverse Kinematics: ', num2str(round((i_frame/nFrames)*100)),'%']));
    
end

close(h)

% %PLOT COMPARAISON OPENSIM
% figure ;
% plot(coordGeneralisee(:,7)) ;
% hold on
% plot((pi/180)*struct_ik_openSim.hip_flexion_r(1:100)) ;
% ylabel('Hip flexion (rad)')
% title('Multiple squat jumps')
% legend('Matlab IBHGC','OpenSim')


end