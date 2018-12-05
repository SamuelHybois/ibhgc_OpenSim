function h=affiche_objet_movie(movie,varargin)

% Affiche un objet avec �clairage et possibilit� de s�lection de points.

p = inputParser();

p.addParamValue('couleur',[0.9490 0.9373 0.3686]);
p.addParamValue('aretes',false);
p.addParamValue('alpha',1);
p.addParamValue('axe',[]);

p.parse(varargin{:});

couleur=p.Results.couleur;
aretes=p.Results.aretes;
alpha=p.Results.alpha;
axe=p.Results.axe;

%% G�re les arguments qui ont besoin d'un traitement sp�cifique

if ~isempty(axe)
    h_axes=axe;
else
    h_figure=figure;
    h_axes=axes;
end

if aretes
    aretes='black';
else
    aretes='none';
end

%% Affiche les objets

axes(h_axes);

if size(couleur,1)~=numel(movie)
    couleur=repmat(couleur,numel(movie),1);
end

for i=1:numel(movie)
    h(i)=patch('vertices',movie(i).Noeuds,'faces',movie(i).Polygones,'facecolor',couleur(i,:), ...
               'edgecolor',aretes,'facealpha',alpha);
    h(i)=handle(h);
end

%% Ajoute une lumi�re si il n'y en a pas d�j� une

lumieres=findobj(gca,'type','light');

if numel(lumieres)~=0
    for i=1:numel(lumieres)
        set(lumieres(i),'position',campos);
    end
else
    l=light;

    % Fixe la position initiale pour �viter les "sauts"
    set(l,'position',campos);

    % Emp�che la barre d'outil de gestion de la cam�ra de perturber...
    addlistener(handle(l),'Position','PostSet',@ajuste_source_lumineuse);
end

% Met en place le callback pour d�placer la lumi�re avec la cam�ra
if ~strcmp(get(h_axes,'tag'),'MovieObject')
    addlistener(handle(h_axes),'CameraPosition','PostSet',@ajuste_source_lumineuse);
    set(h_axes,'tag','MovieObject')
end

%% Configure les propri�t�s d'affichage

axis equal;
material dull;
lighting gouraud;