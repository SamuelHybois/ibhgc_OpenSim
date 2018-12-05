function [visu]=association_EOS_OS(folder_EOS,geo_EOS,geo_OS)
file_EOS=fullfile(folder_EOS,geo_EOS{1});

if exist(file_EOS,'file')~=0
    for i_visu=1:length(geo_EOS)
        visu{i_visu}=geo_EOS{i_visu};
    end
else
    for i_visu=1:length(geo_OS)
        visu{i_visu}=geo_OS{i_visu};
    end
end



end