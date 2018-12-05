function ANALYZE = setup_ANALYZE(varargin)

% function ANALYZE = setup_ANALYZE(data)
%
% This function will create a Setup_ANALYZE.XML file for use with OpenSIM (ver
% 2.31 and beyond) based on the data from the C3D file and the names of the 
% model files which will be used to track the kinematics using the scaled
% model.
% 
% Input - 'ModelFile' - string which is the filename (including path) of the
%                OSIM file (model file - scaled)
%         'MarkerFile' - filename string of the TRC file containing
%           coordinates of the markers to be used in scaling (defaults to
%           the data.TRC_Filename if 'data' structure passed)
%         'IKTasksFile' - filename string of the ScaleTasksFile
%
%          OPTIONAL
%         'data' - structure containing data from C3D file after processing
%                with C3D2TRC.m
%         'InitialTime' - initial time for IK to run from (defaults to
%                   start of the MOT file time)
%         'FinalTime' - final time for IK to run until (defaults to
%                   time at end of the MOT file)
%         'ResultsDirectory' - name of directory where IK results are
%                   written (default - ./)
%         'InputDirectory' - name of directory where data arrises from
%                   (default - empty --> current directory used)
%         'ConstraintWeight' - A positive scalar that is used to weight the 
%                   importance of satisfying constraints.A weighting of 
%                   'Infinity' or if it is unassigned results in the
%                   constraints being strictly enforced (default -
%                   'infinity')
%         'Accuracy' - The accuracy of the solution in absolute terms. I.e. 
%                   the number of significant digits to which the solution 
%                   can be trusted (default = 0.00005)
%         'ReportErrors' - Flag (true or false) indicating whether or not 
%                   to report marker and coordinate errors from the inverse 
%                   kinematics solution (default - 'true')
%         'OutputFile' - Name of the motion file (.mot) to which the
%                   results should be written (default - empty [] -->
%                   the same name as TRC file will be used')
%          'st_protocole' - structure of the protocole
%
% Output - ANALYZE (optional) - This is the structure which is used to make the
%                         XML output file
%
% Written by Puchaud Pierre (Arts & Metiers ParisTech)
%
% Inspirations from Glen Lichtwark's Gait Extract Toolbox -writeXML.m (University of
% Melbourne)

% setup default input files to emtpy

% xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
%      modif jba: utiliation de MarkerFile name plutot que data.TRC_Filename dans le
%      fichier de sortie
% xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

ModelFile = [];
replace_force_set = [];
force_set_files = [];
InitialTime = [];
FinalTime = [];
OutputPrecision = [];
Result_IK = [];
GRFFile = [];

ResultsDirectory = './';

data = [];

if ~isempty(varargin)
    if rem(length(varargin),2)
        error('Incorrect input arguments - must specify property and input')
    end
    for i = 1:2:length(varargin)
       n = varargin{i+1};
       eval([varargin{i} '= n;']); 
    end    
end

% define the initial and final times for the scaling if these aren't
% prescribe and the MarkerFile if this isn't prescribed
if ~isempty(data)
    if isfield(data,'time')
        if isempty(InitialTime)
            InitialTime = data.time(1);
        end
        if isempty(FinalTime)
            FinalTime = data.time(end);
        end
    end
end

[~, Name, ~] = fileparts(ModelFile);

%setup root and ANALYZE_Tool
root = 'OpenSimDocument';
        
V.ATTRIBUTE.Version = '3000';
V.AnalyzeTool.ATTRIBUTE.name = Name;

% define model file
if ~isempty(ModelFile)
    V.AnalyzeTool.model_file = ModelFile;
end

% Replace_force_set
% <!--Replace the model's force set with sets specified in <force_set_files>? If false, the force set is appended to.-->
% <!--List of xml files used to construct an force set for the model.-->
if ~isempty(replace_force_set)
    V.AnalyzeTool.replace_force_set = replace_force_set ;
    V.AnalyzeTool.force_set_files = force_set_files ;
else
    V.AnalyzeTool.replace_force_set = 'false';%Default
    V.AnalyzeTool.force_set_files = [];%Default
end

% define results directories
V.AnalyzeTool.results_directory = ResultsDirectory ;
%
%<!--Output precision.  It is 8 by default.-->
if ~isempty(OutputPrecision)
    V.AnalyzeTool.output_precision = OutputPrecision;
else
    V.AnalyzeTool.output_precision = 8;
end

% Define the time range
V.AnalyzeTool.initial_time = num2str(InitialTime);
V.AnalyzeTool.final_time = num2str(FinalTime);

% <!--Flag indicating whether or not to compute equilibrium values for states other than the coordinates or speeds.  For example, equilibrium muscle fiber lengths or muscle forces.-->
V.AnalyzeTool.solve_for_equilibrium_for_auxiliary_states = 'true'; %Default
V.AnalyzeTool.maximum_number_of_integrator_steps = 20000 ; %Default
V.AnalyzeTool.maximum_integrator_step_size = 1 ; %Default
V.AnalyzeTool.minimum_integrator_step_size = 1e-008 ; %Default
V.AnalyzeTool.integrator_error_tolerance = 1e-005 ; %Default

if strcmp(st_protocole.FONCTION_A_LANCER.BodyKinematics{1},'1')==1
%Body Kinematics
V.AnalyzeTool.AnalysisSet.objects.BodyKinematics.ATTRIBUTE.name = 'BodyKinematics' ;
V.AnalyzeTool.AnalysisSet.objects.BodyKinematics.on = 'true'; %Default
V.AnalyzeTool.AnalysisSet.objects.BodyKinematics.start_time = InitialTime ;
V.AnalyzeTool.AnalysisSet.objects.BodyKinematics.end_time = FinalTime ;
V.AnalyzeTool.AnalysisSet.objects.BodyKinematics.stepinterval = 1 ; %Default
V.AnalyzeTool.AnalysisSet.objects.BodyKinematics.in_degrees = 'true'; %Default
V.AnalyzeTool.AnalysisSet.objects.BodyKinematics.bodies = 'all'; %Default
V.AnalyzeTool.AnalysisSet.objects.BodyKinematics.express_results_in_body_local_frame = 'false';
end

if strcmp(st_protocole.FONCTION_A_LANCER.MuscleAnalysis{1},'1')==1
%Muscle analysis
V.AnalyzeTool.AnalysisSet.ATTRIBUTE.name = 'Analyses' ;
V.AnalyzeTool.AnalysisSet.objects.MuscleAnalysis.ATTRIBUTE.name = 'MuscleAnalysis' ;
V.AnalyzeTool.AnalysisSet.objects.MuscleAnalysis.on = 'true'; %Default
V.AnalyzeTool.AnalysisSet.objects.MuscleAnalysis.start_time = InitialTime ;
V.AnalyzeTool.AnalysisSet.objects.MuscleAnalysis.end_time = FinalTime ;
%<!--Specifies how often to store results during a simulation.
% More specifically, the interval (a positive integer) specifies 
% how many successful integration steps should be taken before results are recorded again.-->
V.AnalyzeTool.AnalysisSet.objects.MuscleAnalysis.stepinterval = 1 ; %Default
V.AnalyzeTool.AnalysisSet.objects.MuscleAnalysis.in_degrees = 'true'; %Default
V.AnalyzeTool.AnalysisSet.objects.MuscleAnalysis.muscle_list = 'all'; %Default

if strcmp(st_protocole.FONCTION_A_LANCER.MuscleAnalysis{1},'1')==1
    V.AnalyzeTool.AnalysisSet.objects.MuscleAnalysis.moment_arm_coordinate_list = ''; %On ne s'intéresse qu'aux longueurs Musculaires
    V.AnalyzeTool.AnalysisSet.objects.MuscleAnalysis.compute_moments = '' ; %Default
elseif strcmp(st_protocole.FONCTION_A_LANCER.MomentArms{1},'1')==1
    V.AnalyzeTool.AnalysisSet.objects.MuscleAnalysis.moment_arm_coordinate_list = 'all'; %On ne s'intéresse pas qu'aux longueurs Musculaires
    V.AnalyzeTool.AnalysisSet.objects.MuscleAnalysis.compute_moments = 'true' ; %Default
end

end
%Not finished yet.%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%					
% 		<!--XML file (.xml) containing the forces applied to the model as ExternalLoads.-->
% V.AnalyzeTool.external_loads_file = GRFFile;
V.AnalyzeTool.external_loads_file = ' ';
% 		<!--Storage file (.sto) containing the time history of states for the model. This file often contains multiple rows of data, each row being a time-stamped array of states. The first column contains the time.  The rest of the columns contain the states in the order appropriate for the model. In a storage file, unlike a motion file (.mot), non-uniform time spacing is allowed.  If the user-specified initial time for a simulation does not correspond exactly to one of the time stamps in this file, inerpolation is NOT used because it is sometimes necessary to an exact set of states for analyses.  Instead, the closest earlier set of states is used.-->
V.AnalyzeTool.states_file = [];
% <!--Motion file (.mot) or storage file (.sto) containing the time history of the generalized coordinates for the model. These can be specified in place of the states file.-->
V.AnalyzeTool.coordinates_file = Result_IK ;
% 		<!--Storage file (.sto) containing the time history of the generalized speeds for the model. If coordinates_file is used in place of states_file, these can be optionally set as well to give the speeds. If not specified, speeds will be computed from coordinates by differentiation.-->
V.AnalyzeTool.speeds_file = [];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%<!--Low-pass cut-off frequency for filtering the coordinates_file data 
%(currently does not apply to states_file or speeds_file). 
%A negative value results in no filtering. The default value is -1.0,
%so no filtering.-->
% V.AnalyzeTool.lowpass_cutoff_frequency_for_coordinates = -1.0 ; %Default
V.AnalyzeTool.lowpass_cutoff_frequency_for_coordinates = 6.0 ; %Default

% fileout = [data.Name '_Setup_InverseKinematics.xml'];
fileout = fullfile(ResultsDirectory , [MarkerFile(1:end-4), '_Setup_ANALYZE.xml']);

Pref.StructItem = false;
xml_write(fileout, V, root,Pref);

ANALYZE = V;
        