function out = load_sto_file(filename)
% Modification Maxime Borugain 02 12 2016
% si le nom de la colonne commence par '_', cela pose probleme pour créer
% un champ dans la strcture donc le nom devient Er_ ... 

% function data = load_sto_file(filename,delimiters)
%
% This function loads either STO or MOT files and stores each column of
% data in structure array with the field name which is the columning
% heading in the file. It discards any other information from the header of 
% the file.
%
% Input: filename - the STO or MOT filename
%
% Author: Glen Lichtwark 
% Last Modified: 17/11/2008

if nargin < 1
    [fname, pname] = uigetfile('*.*', 'File to load - ');
    file = [pname fname];
else file = filename;    
end

[file_data,s_data]= readtext(file, '\t', '', '', 'empty2NaN');

% search the numerical data (in s_data.numberMask) to find when the block 
% of data starts

a = find(abs(diff(sum(s_data.numberMask,2)))>0);
[m,n] = size(file_data);

% Check if there is strings in the middle of the table numbers
res = cellfun(@isnumeric,file_data);
res = res (a(1)+1:end,1:sum(s_data.numberMask(a(1)+1,:)));
[lg,col] = find(res== 0);
% if there is, we interpolate to get the length of the muscle
try
    nb_str = size(lg,1);
if ~isempty(lg) 
    for i_str = 1:nb_str
        if strcmp(file_data(a(1)+lg(i_str), col(i_str)),'-1.#IND0000')

            x=cell2mat([file_data(a(1)+lg(i_str)  +1 , 1);file_data(a(1)+lg(i_str)  -1 , 1)]);
            v=cell2mat([file_data(a(1)+lg(i_str)  +1 , col(i_str));...
            file_data(a(1)+lg(i_str)  -1 , col(i_str))]);
        
            xq = mean(x);
            
            file_data(a(1)+lg(i_str) , col(i_str)) = {interp1(x,v,xq,'linear')};
        end
    end
end
catch
    if ~isempty(lg) 
    for i_str = 1:nb_str
        if strcmp(file_data(a(1)+lg(i_str), col(i_str)),'-1.#IND0000')
            file_data(a(1)+lg(i_str) , col(i_str)) = {nan};
        end
    end
    end
end

% create an array with all of the data
num_dat = [file_data{a(1)+1:end,1:sum(s_data.numberMask(a(1)+1,:),2)}];

% reshape to put back into columns and rows
data = reshape(num_dat,m-a(1),sum(s_data.numberMask(a(1)+1,:),2));

% now find the column headings if there are any
if sum(s_data.stringMask(a(1),:)) == sum(s_data.numberMask(a(1)+1,:))
    data_label = file_data(a(1),:);
    b = a(1)-1;
else b = a(1);
end

% go through the data labels and find any that are duplicates (this occurs
% in the ground reaction force data where each forceplate has the same
% column headings) and add a number to distinguish the duplicates.

for i = 1:length(data_label)
    tf = strcmp(data_label(i),data_label);
    c = find(tf>0);
    if length(c) > 1
        for j = 1:length(c)
            data_label(c(j)) = cellstr([data_label{c(j)} num2str(j)]);
        end
    end
end

% now create the output structure with the field names from the data labels
% and the corresponding data from the columns of the data array
for i = 1:length(data_label)
    f_name = data_label{i};
    % find any spaces and replace with underscore
    e = findstr(f_name, ' ');
    if ~isempty(e)
        f_name(e) = '_';
    end
    e = findstr(f_name, '.');
    if ~isempty(e)
        f_name(e) = '_';
    end
%     if ~isempty(str2num(f_name(1)))
%         f_name = ['N' f_name];
%     end
    if strcmp(f_name(1),'_')==1
        f_name=['Er' f_name];
    end
    out.(f_name) = data(:,i);
end

