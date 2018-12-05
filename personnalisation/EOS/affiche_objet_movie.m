function h=affiche_objet_movie(movie,varargin)

% Affiche un objet avec éclairage et possibilité de sélection de points.

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

%% Gère les arguments qui ont besoin d'un traitement spécifique

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

%% Ajoute une lumière si il n'y en a pas déjà une

lumieres=findobj(gca,'type','light');

if numel(lumieres)~=0
    for i=1:numel(lumieres)
        set(lumieres(i),'position',campos);
    end
else
    l=light;

    % Fixe la position initiale pour éviter les "sauts"
    set(l,'position',campos);

    % Empêche la barre d'outil de gestion de la caméra de perturber...
    addlistener(handle(l),'Position','PostSet',@ajuste_source_lumineuse);
end

% Met en place le callback pour déplacer la lumière avec la caméra
if ~strcmp(get(h_axes,'tag'),'MovieObject')
    addlistener(handle(h_axes),'CameraPosition','PostSet',@ajuste_source_lumineuse);
    set(h_axes,'tag','MovieObject')
end

%% Configure les propriétés d'affichage

axis equal;
material dull;
lighting gouraud;