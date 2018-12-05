function parent_folder = parentfolder(child,n)
% IN
% child : current path (char array)
% n : number of parent folders to go back (number)
% OUT
% parent_folder : parent path (char array)
%                                               D. Haering 30/05/2018
       
    list_filesep = strfind(child,filesep);
    parent_folder = child(1:list_filesep(end-n+1));

end% function