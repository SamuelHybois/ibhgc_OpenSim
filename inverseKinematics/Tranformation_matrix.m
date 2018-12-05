function Struct_IK = Tranformation_matrix_shoulder(Struct_MH)
% From MH_R0_Rs, it gives the Transformation matrix between segments
% MH_Rs_Rs+1
%%%EN DUR%%%%%%%%%%%%%%%
List_of_Matrix = {'thorax','clavicle','sternoclavicular','yxz';...
    'thorax','scapula','scapulothoracic','yxz';...
    'thorax','humerus','thoracohumeral','yxy';...
    'clavicle','scapula','acromioclavicular','yxz';...
    'scapula','humerus','glenohumeral','yxy'};

side={'_r','_l'};
%%%EN DUR%%%%%%%%%%%%%%%
for i_s=1:length(side)
    s=side{i_s};
    for i_jt = 1:length(List_of_Matrix)
        
        if ~strcmp(List_of_Matrix{i_jt,1}, 'thorax')
            par_b=[List_of_Matrix{i_jt,1} s] ;
        else
            par_b=List_of_Matrix{i_jt,1};
        end
        chi_b=[List_of_Matrix{i_jt,2} s] ;
        
        cur_jt = [List_of_Matrix{i_jt,3} s]; 
        Struct_IK.(cur_jt).seq = List_of_Matrix{i_jt,4};
        
        %Parent=>Enfant
        for i_f = 1:size(Struct_MH.(par_b).MH,3)
            Struct_IK.(cur_jt).MH(:,:,i_f) = Struct_MH.(par_b).MH(:,:,i_f) * Struct_MH.(chi_b).MH(:,:,i_f)\eye(4);
            [Struct_IK.(cur_jt).angles(:,:,i_f)]=axemobile_V2(Struct_IK.(cur_jt).MH(:,:,i_f),Struct_IK.(cur_jt).seq);
        end
        
        
    end
end
end