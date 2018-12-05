function [q0_opt] = frameInitiale(modeleOsim,indexMarqueursModele,dataTRC_i,q0,wi_mat)

[nQ,labelQ,Aeq,beq,l_inf_Model,l_sup_Model] = CoordonneesGeneralisees(modeleOsim);
[struct_Bodies, struct_Joints] = extract_KinChainData_ModelOS(modeleOsim,'');

% Identification du Body proximal
proximalBody = char(struct_Bodies.ground.Children);

proximalMarkerSet = struct_Bodies.(proximalBody).Markers;
nMarkers_proximal = size(proximalMarkerSet,2);

if nMarkers_proximal >= 3
    
    if nMarkers_proximal ==3 % on prend les 3 seuls marqueurs du segment
        
    else
        
    end
    
else % Cas où il y a moins de 3 marqueurs dans le segment racine : méthode par défaut
    
    structQ = traductionQVecteurStruct(q0,labelQ) ;
    [dataReconstruite,Struct_MH] = cinematiqueDirecte(modeleOsim,struct_Bodies, struct_Joints,structQ,dataTRC_i.noms,indexMarqueursModele);
    barycentre_ROS = nanmean(dataReconstruite.matrix);
    barycentre_RVicon = nanmean(dataTRC_i.matrix);
    
    % Décalage du body pelvis initialement
    translation_ini = barycentre_RVicon - barycentre_ROS ;
    
    % Modification de q0
    nom_q = fieldnames(labelQ) ;
    
    for i_q = 1:nQ
        nom_i_q = nom_q{i_q} ;
        if strfind(nom_i_q,proximalBody)==1
            if strfind(nom_i_q,'_tx')
                q0(i_q) = translation_ini(1) ;
            end
            if strfind(nom_i_q,'_ty')
                q0(i_q) = translation_ini(2) ;
            end
            if strfind(nom_i_q,'_tz')
                q0(i_q) = translation_ini(3) ;
            end
        end
    end %for i_q
    
    [fonctionObj] =  @(coordGeneralisee)iterationIKcalculRMSE(modeleOsim,struct_Bodies, struct_Joints,indexMarqueursModele,wi_mat,dataTRC_i,coordGeneralisee,labelQ);
    options = optimoptions(@fmincon,'TolFun',1e-3,'Display','iter','Algorithm','interior-point');
    [q0_opt,~,~,~] = fmincon(fonctionObj,q0,[],[],Aeq,beq,l_inf_Model,l_sup_Model,[],options) ;
    
end

end