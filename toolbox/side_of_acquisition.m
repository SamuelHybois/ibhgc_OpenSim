function [sign,sign_char_en,sign_char_fr] = side_of_acquisition(cur_acquisition)
% This function is made to adapt signs or dominent side in the current 
% acquisition
% It requires the side to be mentionned in the file name.
% Diane H, 08.11.2018

    is_left = ~isempty(strfind(cur_acquisition,'_L'));
    is_right = ~isempty(strfind(cur_acquisition,'_R'));
    
    if is_left
        sign=-1; 
        sign_char_en='l'; 
        sign_char_fr='G';
    elseif is_right
        sign=1; 
        sign_char_en='r'; 
        sign_char_fr='D';
    end
        
end