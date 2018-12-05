function [] = pipeline_harmonised_ID(st_protocole,cur_sujet,mysituation_name,mycinfile_nom,rep_global,myosim_Matlab_name,f_filtre_ID,plugin_STJ)

output_rep_cine = fullfile(rep_global,cur_sujet,mysituation_name);
rep_trc= fullfile(rep_global,cur_sujet,mysituation_name);
mycinfile_path = fullfile(rep_trc,mycinfile_nom) ;

% Définition des fichiers pour le setup_ID
modelfileOS = myosim_Matlab_name;

myIKfile = fullfile( rep_trc , [mycinfile_nom(1:end-4), '_ik_lisse.mot'] ) ; % résultat de la cinématique inverse lissé

myeffort_nom =  [mycinfile_nom(1:end-4), '.mot']; % fichier "brut" de GRF .mot
myeffort_path = fullfile(rep_trc,myeffort_nom); % chemin

if ~exist(myeffort_path,'file')
    myeffort_nom=[mycinfile_nom(1:end-4),'_grf.mot'];
    myeffort_path=fullfile(rep_trc,myeffort_nom);
end

if exist(myIKfile, 'file') && exist(myeffort_path, 'file') &&  exist(mycinfile_path, 'file')
    data_ik = load_sto_file( myIKfile );
    data_GRF = load_sto_file( myeffort_path ) ;
    data_trc = lire_donnees_trc(mycinfile_path) ;
    
    dataGRF.TRC_Filename = chemin_relatif_OS(rep_trc,myeffort_path) ;
    dataGRF.Name = mycinfile_nom(1:end-4) ;
    
    
    sel_ForceIdentifier = st_protocole.EFFORTS_EXT.force ;
    sel_PointIdentifier = st_protocole.EFFORTS_EXT.point ;
    sel_TorqueIdentifier = st_protocole.EFFORTS_EXT.moment ;
    sel_ExtLoadNames = st_protocole.EFFORTS_EXT.nom ;
    sel_AppliedToBodies = st_protocole.EFFORTS_EXT.applied_body ;
    sel_ExpressedInBodies = st_protocole.EFFORTS_EXT.expression_body ;
    
    myeffortfileOS = chemin_relatif_OS(rep_trc, myeffort_path) ;
    sel_MOTFile =  myIKfile ;
    GRF_xmlfile = fullfile(rep_trc, [mycinfile_nom(1:end-4), '_GRF.xml'] ) ;
    
    
    dataID.Name = mycinfile_nom(1:end-4) ;
    Outputfile_sto = [mycinfile_nom(1:end-4), '_id.sto'] ;
    [~,GRF_xmlfile_name, GRF_xmlfile_ext] = fileparts(GRF_xmlfile) ;
    myIKfileOS = chemin_relatif_OS(rep_trc, myIKfile) ;
    
    
    
    
    %%% Passage des GRF de .mot à .xml pour la lecture OpenSim
    cd(rep_trc)
    
    grf2xml(...
        dataGRF, ...
        'ExternalLoadNames', sel_ExtLoadNames, ...
        'ForceIdentifier', sel_ForceIdentifier, ...
        'PointIdentifier',  sel_PointIdentifier, ...
        'TorqueIdentifier', sel_TorqueIdentifier, ...
        'AppliedToBodies',sel_AppliedToBodies, ...
        'GRFFile', myeffort_path, ...
        'MOTFile', myIKfile, ...
        'OutputFile',GRF_xmlfile, ...
        'ForceExpressedinBody', sel_ExpressedInBodies,...
        'PointExpressedinBody', sel_ExpressedInBodies...
        ) ;
    
    
    
    
    setup_InverseDynamics( ...
        'data', dataID,  ...
        'ModelFile',  modelfileOS,...
        'MOTFile', myIKfile, ...
        'GRFFile', [GRF_xmlfile_name, GRF_xmlfile_ext],   ...
        'LowPassFilterForKinematics', f_filtre_ID , ...
        'InitialTime', [num2str(data_trc.tps(1)), ' '] ,...
        'FinalTime', num2str(data_trc.tps(end)) ,...
        'ResultsDirectory', rep_trc, ...
        'OutputFile',  Outputfile_sto ...
        ) ;
    
    
    
    % call ID tool from the command line using setup file
    com = ['id -S ' fullfile(rep_trc, dataID.Name) '_Setup_ID.xml' ' -L ' plugin_STJ];
    system(com);
    
    
    
else  % exist files
    disp('!') ; disp('!') ; disp('!') ; disp('!') ; disp('!') ;
    disp('          Attention, fichier effort ou .mot inexistant: ') ;
    disp(myIKfile) ;
    disp('!') ; disp('!') ; disp('!') ; disp('!') ; disp('!') ;
    
end

end