function     R0_Rseg = segment_matrix_from_trc(struc_trc,segment)
% This function is made to automatically compute segment matrix according
% ISB from trc structure.
% D. Haering 8.11.2018

% check for side
is_left = ~isempty(strfind(segment,'_l'));
is_right = ~isempty(strfind(segment,'_r'));
if is_left
    sign=-1;
    sign_char_fr='G';
    segment_short = segment(1:end-2);
elseif is_right
    sign=1; 
    sign_char_fr='D';
    segment_short = segment(1:end-2);
else
    segment_short = segment;
end

% extract data from structure
mark_coord = struc_trc.coord;
mark_names = struc_trc.noms;

% find case
switch segment_short
    case 'thorax'
        num_C7  = find(strcmp('C7',mark_names));
        num_MAN = find(strcmp('MAN',mark_names));
        num_XYP = find(strcmp('XYP',mark_names));
        num_T8  = find(strcmp('T8',mark_names));
        C7  = mark_coord(:,num_C7*3-2:num_C7*3);
        MAN = mark_coord(:,num_MAN*3-2:num_MAN*3);
        XYP = mark_coord(:,num_XYP*3-2:num_XYP*3);
        T8  = mark_coord(:,num_T8*3-2:num_T8*3);
        
        R0_Rseg = mark_2_mat('thorax',MAN,XYP,C7,T8);

    case 'scapula'
        num_AA = find(strcmp(['AA' sign_char_fr],mark_names));
        num_AI = find(strcmp(['AI' sign_char_fr],mark_names));
        num_TS = find(strcmp(['TS' sign_char_fr],mark_names));
        num_AC    = find(strcmp(['AC' sign_char_fr],mark_names));
        AA = mark_coord(:,num_AA*3-2:num_AA*3);
        AI = mark_coord(:,num_AI*3-2:num_AI*3);
        TS = mark_coord(:,num_TS*3-2:num_TS*3);
        AC = mark_coord(:,num_AC*3-2:num_AC*3);
        
        R0_Rseg = mark_2_mat('scapula',AC,AA,TS,AI,sign); 
    
    case 'humerus'
        num_AA = find(strcmp(['AA' sign_char_fr],mark_names));
        num_EL = find(strcmp(['EL' sign_char_fr],mark_names));
        num_EM = find(strcmp(['EM' sign_char_fr],mark_names));
        num_PSU = find(strcmp(['PSU' sign_char_fr],mark_names));
        AA = mark_coord(:,num_AA*3-2:num_AA*3);
        EL = mark_coord(:,num_EL*3-2:num_EL*3);
        EM = mark_coord(:,num_EM*3-2:num_EM*3);
        PSU = mark_coord(:,num_PSU*3-2:num_PSU*3);
        
        R0_Rseg = mark_2_mat('humerus',AA,EL,EM,PSU,sign);

    case 'radius'
        num_EL = find(strcmp(['EL' sign_char_fr],mark_names));
        num_EM = find(strcmp(['EM' sign_char_fr],mark_names));
        num_PSR = find(strcmp(['PSR' sign_char_fr],mark_names));
        EL = mark_coord(:,num_EL*3-2:num_EL*3);
        EM = mark_coord(:,num_EM*3-2:num_EM*3);
        PSR = mark_coord(:,num_PSR*3-2:num_PSR*3);
        
        R0_Rseg = mark_2_mat('radius',PSR,EL,EM); 
    
    case 'hand'
        num_MC2 = find(strcmp(['MC2' sign_char_fr],mark_names));
        num_MC5 = find(strcmp(['MC5' sign_char_fr],mark_names));
        num_PSR = find(strcmp(['PSR' sign_char_fr],mark_names));
        num_PSU = find(strcmp(['PSU' sign_char_fr],mark_names));
        MC2 = mark_coord(:,num_MC2*3-2:num_MC2*3);
        MC5 = mark_coord(:,num_MC5*3-2:num_MC5*3);
        PSR = mark_coord(:,num_PSR*3-2:num_PSR*3);
        PSU = mark_coord(:,num_PSU*3-2:num_PSU*3);
                
        R0_Rseg = mark_2_mat('hand',PSR,PSU,MC2,MC5,sign);
    otherwise
        disp(['!!the segment' segment_short 'is not defined yet!!'])
end %switch

end
