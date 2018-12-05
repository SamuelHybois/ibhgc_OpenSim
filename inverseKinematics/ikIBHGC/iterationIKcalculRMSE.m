function RMSE = iterationIKcalculRMSE(modeleOsim,struct_Bodies, struct_Joints,indexMarqueursModele,wi_mat,dataTRC_i,coordGeneralisee,labelQ)

structQ = traductionQVecteurStruct(coordGeneralisee,labelQ) ;
[dataReconstruite,~] = cinematiqueDirecte(modeleOsim,struct_Bodies, struct_Joints,structQ,dataTRC_i.noms,indexMarqueursModele);
RMSE = sqrt((nansum(wi_mat.*sum((dataTRC_i.matrix - dataReconstruite.matrix).^2,2))/nansum(wi_mat)));
    
end