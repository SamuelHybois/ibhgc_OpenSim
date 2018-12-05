function Struct_IK_ISB = Tranformation_matrix_shoulder(Struct_MH,Struct_MH_ISB)
% From MH_R0_Rs, it gives the Transformation matrix between segments
% MH_Rs_Rs+1

%Remplace les matrices homogènes de struct_MH par Struct_MH_ISB
bod =fieldnames(Struct_MH_ISB);
for i_b =1:length(bod)
    Struct_MH.(bod{i_b})=Struct_MH_ISB.(bod{i_b});
end

%%%EN DUR%%%%%%%%%%%%%%%
List_of_Matrix = {'thorax','clavicle','sternoclavicular','yxz';...
    'thorax','scapula','scapulothoracic','yxz';...
    'thorax','humerus','thoracohumeral','zxy';...
    'clavicle','scapula','acromioclavicular','yxz';...
    'scapula','humerus','glenohumeral','zxy'};

side={'_r','_l'};
%%%EN DUR%%%%%%%%%%%%%%%


for i_s=1:length(side)
    s=side{i_s};
    for i_jt = 1:length(List_of_Matrix)
        
        if ~strcmp(List_of_Matrix{i_jt,1}, 'thorax')
            %par_b : Parent_body
            par_b=[List_of_Matrix{i_jt,1} s] ;
        else
            %par_b : Parent_body
            par_b=List_of_Matrix{i_jt,1};
        end
            %chi_b : Child_body
        chi_b=[List_of_Matrix{i_jt,2} s] ;
        % cur_jt : current_joint
        cur_jt = [List_of_Matrix{i_jt,3} s]; 
        Struct_IK_ISB.(cur_jt).seq = List_of_Matrix{i_jt,4};
        
        %Parent=>Enfant
        for i_f = 1:size(Struct_MH.(par_b).MH,3)
            Matrice_R0_Rparent = Struct_MH.(par_b).MH(:,:,i_f);
            Matrice_R0_Renfant = Struct_MH.(chi_b).MH(:,:,i_f);
            Struct_IK_ISB.(cur_jt).MH(:,:,i_f) = Matrice_R0_Rparent \ Matrice_R0_Renfant ;
            [Struct_IK_ISB.(cur_jt).angles(:,:,i_f)]=axemobile_V2(Struct_IK_ISB.(cur_jt).MH(:,:,i_f),Struct_IK_ISB.(cur_jt).seq);
        end
        
    end
end
end