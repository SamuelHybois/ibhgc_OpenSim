function movie=lire_fichier_vrml( fichier )

%% Lecture du fichier. Read in the file.

% fprintf('* Lecture du fichier\n');

fid=fopen(fichier,'r');
data=fread(fid,'*char')';
fclose(fid);

%% Enlève les commentaires. Remove comments.

data=regexprep(data,'#.*$','','dotexceptnewline','lineanchors');

%% Découpage du fichier en blocs point[] et coordIndex[]. Cut out blocks of point[] and coordIndex[].

% fprintf('* Recherche des objets\n');

[tokens,matches]=regexpi(data,'(coordIndex|point)\s*\[(.*?)\]','tokens','match');

% Un objet contient deux blocs de données. An object contains two data blocks.
blocks=cell(size(tokens,2)/2,2);

% Groupe les deux blocs. Group the 2 blocks.
for i=1:size(tokens,2)
    this_block=tokens{i}(2);
    this_string=this_block{1};
    
    if strcmpi(tokens{i}(1),'point')
        blocks{floor((i-1)/2)+1,1}=this_string;
    else
        blocks{floor((i-1)/2)+1,2}=this_string;
    end
end

%% Traite les blocs de coordonnées. Treat blocks of coordinates.

% fprintf('* Traitement des coordonnées\n');

for i=1:size(blocks,1)
%     fprintf('  * Objet %i/%i ',i,size(blocks,1));
    
    % Lit les valeurs et transforme en format 3 colonnes
    values=textscan(blocks{i,1},'%f','delimiter',', \b\t');
    values{1,1}=values{1,1}(~isnan(values{1,1}));
    blocks{i,1}=reshape(values{1,1},3,numel(values{1,1})/3)';

%     fprintf('(%i points)\n',numel(values{1,1})/3);
end

%% Traite les blocs de faces. Treat blocks of faces.

% fprintf('* Traitement des faces\n');

for i=1:size(blocks,1)
%     fprintf('  * Objet %i/%i ',i,size(blocks,1));

    values=textscan(blocks{i,2},'%f','delimiter',', \b\t');
    values{1,1}=values{1,1}(~isnan(values{1,1}));

    % Ajoute un -1 à la fin si nécessaire. Add a "-1" to the end if necessary.
    if values{1,1}(end)~=-1
        values{1,1}=[values{1,1};-1];
    end
    
    % Convertit en polygones. Covert to polygons.
    if values{1,1}(4)==-1
        % Triangles
%         fprintf('(%i triangles)\n',numel(values{1,1})/4);
        blocks{i,2}=reshape(values{1,1},4,numel(values{1,1})/4)';
    elseif values{1,1}(5)==-1
        % Quad
%         fprintf('(%i quads)\n',numel(values{1,1})/5);
        blocks{i,2}=reshape(values{1,1},5,numel(values{1,1})/5)';
    end
    
    % Enlève la dernière colonne (terminateurs) et décale de 1. Removes the last column (terminators) and shifts 1
    blocks{i,2}(:,end)=[];
    blocks{i,2}=blocks{i,2}+1;
end

%% Crée l'objet movie. Create a movie for object.

movie.N_Obj=size(blocks,1);

% Valeurs initiales. Initialize the values.
movie.N_Pts=0;
movie.N_Pol=0;
movie.N_Arr=0;

movie.Objets=[];
movie.Noeuds=[];
movie.Polygones=[];

% Construit l'objet composite. Build the composite object.
for i=1:size(blocks,1)
    
    movie.Noeuds=[movie.Noeuds;blocks{i,1}];
    movie.Polygones=[movie.Polygones;blocks{i,2}+movie.N_Pts];
    
    movie.Objets(i,:)=[movie.N_Pol+1 movie.N_Pol+size(blocks{i,2},1)];
    
    movie.N_Pts=movie.N_Pts+size(blocks{i,1},1);
    movie.N_Pol=movie.N_Pol+size(blocks{i,2},1);
    movie.N_Arr=movie.N_Arr+size(blocks{i,2},1)*size(blocks{i,2},2);
    
end

end