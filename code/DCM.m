% =========================================================================
% Author: Lal Ersoy
% Date: 11.08.2022
% Title: Dynamic Causal Modeling (DCM) for fMRI Data
% Description: This script specifies and fits two dynamic causal models (DCM) 
%              to fMRI data to analyze brain connectivity across subjects 
%              and conditions using SPM12. Model 1 represents baseline 
%              connectivity, while Model 2 includes interaction modulation.
% License: MIT License
% =========================================================================

% --- MRI Scanner Settings ---
TR = 3.6;   % Repetition time (secs)
TE = 0.05;  % Echo time (secs)

nsub = 60;  % Number of subjects
nregions = 4;  % Number of regions in the brain
nconditions = 3;  % Number of experimental conditions

% --- Indexing Experimental Conditions ---
task = 1;  % Task condition
pictures = 2;  % Pictures condition
words = 3;  % Words condition

% --- Indexing Brain Regions ---
lvf = 1;  % Left ventral fusiform
ldf = 2;  % Left dorsal fusiform
rvf = 3;  % Right ventral fusiform
rdf = 4;  % Right dorsal fusiform

% --- Specifying Matrices A, B, C for Models 1 and 2 ---

% Matrix A represents the baseline brain connectivity (context-independent),
% where all the endogenous connections are allowed except the diagonal (self-connections).
a = ones(4, 4);  % Default connectivity
a(lvf, rdf) = 0;  % Turn off connection between LVF and RDF
a(ldf, rvf) = 0;  % Turn off connection between LDF and RVF
a(rvf, ldf) = 0;  % Turn off connection between RVF and LDF
a(rdf, lvf) = 0;  % Turn off connection between RDF and LVF

% Matrix C represents the input driving each brain region
c = [1 0 0; 
     1 0 0; 
     1 0 0; 
     1 0 0];

% --- Model 1: Specifying Modulated Connections ---
% Model 1 includes connections from LVF to LDF and from RVF to RDF,
% modulated by experimental conditions (words and pictures).
b_model1(:,:,task) = zeros(nregions, nregions);
b_model1(:,:,pictures) = [0 0 0 0;
                          1 0 0 0;
                          0 0 0 0;
                          0 0 1 0];  % Modulated by pictures condition
b_model1(:,:,words) = [0 0 0 0;
                       1 0 0 0;
                       0 0 0 0;
                       0 0 1 0];  % Modulated by words condition

% --- Model 2: Adding More Modulations ---
% Model 2 adds a connection from LDF to RDF, modulated by words and pictures.
b_model2(:,:,task) = zeros(nregions, nregions);
b_model2(:,:,pictures) = [0 0 0 0;
                           1 0 0 0;
                           0 0 0 0;
                           0 1 1 0];  % Modulated by pictures condition
b_model2(:,:,words) = [0 0 0 0;
                        1 0 0 0;
                        0 0 0 0;
                        0 1 1 0];  % Modulated by words condition

% --- Specifying DCMs for Each Subject ---
project_dir = '/Users/lal/Desktop/statsdcm';  % Path to project directory

% Loop through all subjects and define models
for subject = 1:nsub
    name = sprintf('sub-%02d', subject);  % Naming convention for subjects
    glm_dir = fullfile(project_dir, 'GLM', name);
    SPM = load(fullfile(glm_dir, 'SPM.mat'));  % Load SPM model
    SPM = SPM.SPM;

    % Load regions of interest (VOI) data for the four regions
    f = {fullfile(glm_dir, 'VOI_lvF_1.mat'), 
         fullfile(glm_dir, 'VOI_ldF_1.mat'),
         fullfile(glm_dir, 'VOI_rvF_1.mat'), 
         fullfile(glm_dir, 'VOI_rdF_1.mat')};
    
    % Load the data for each region
    for r = 1:length(f)
        XY = load(f{r});
        xY(r) = XY.xY;
    end

    cd(glm_dir);  % Change to the current subject's directory

    % --- Model 1: No Interaction Modulation ---
    include = [1 1 1]';
    s = struct();
    s.name = 'no_inter_mod';
    s.u = include;
    s.delays = repmat(TR, 1, nregions);
    s.TE = TE;
    s.nonlinear = false;
    s.two_state = false;
    s.stochastic = false;
    s.centre = true;
    s.induced = 0;
    s.a = a;
    s.b = b_model1;
    s.c = c;
    s.d = d;
    DCM_no_inter_mod = spm_dcm_specify(SPM, xY, s);  % Specify DCM

    cd(glm_dir);

    % --- Model 2: Interaction Modulation ---
    s.name = 'inter_mod';
    s.b = b_model2;
    DCM_inter_mod = spm_dcm_specify(SPM, xY, s);

    cd(glm_dir);
end

% --- Fitting Models ---
% Fit Model 1 (No Interaction Modulation)
dcms_model1 = spm_select('FPListRec', 'GLM', 'DCM_no_inter_mod.mat');
GCM_model1 = cellstr(dcms_model1);
GCM_model1 = spm_dcm_load(GCM_model1);
use_parfor = true;  % Use parallel computing
GCM_model1 = spm_dcm_fit(GCM_model1, use_parfor);
save('/Users/lal/Desktop/statsdcm/analyses/GCM_no_inter_mod.mat', 'GCM_model1');
spm_dcm_fmri_check(GCM_model1);

% Fit Model 2 (Interaction Modulation)
dcms_model2 = spm_select('FPListRec', 'GLM', 'DCM_inter_mod.mat');
GCM_model2 = cellstr(dcms_model2);
GCM_model2 = spm_dcm_load(GCM_model2);
GCM_model2 = spm_dcm_fit(GCM_model2, use_parfor);
save('/Users/lal/Desktop/statsdcm/analyses/GCM_inter_mod.mat', 'GCM_model2');
spm_dcm_fmri_check(GCM_model2);

% --- Fitting Models for a Single Subject (Example: Subject 28) ---
DCM_single = spm_dcm_fit(DCM_no_inter_mod, use_parfor);
save('/Users/lal/Desktop/statsdcm/GLM/sub-28/DCM_no_inter_mod_est.mat', 'DCM_single');
spm_dcm_fmri_check(DCM_single);

DCM_single_2 = spm_dcm_fit(DCM_inter_mod, use_parfor);
save('/Users/lal/Desktop/statsdcm/GLM/sub-28/DCM_inter_mod_est.mat', 'DCM_single_2');
spm_dcm_fmri_check(DCM_single_2);

% --- Model Comparison: Check Connectivity Parameters for Subject 28 ---
spm_dcm_fmri_check(GCM_model2{28, 1});
spm_dcm_fmri_check(GCM_model1{28, 1});

% --- Extract and Check Connectivity Parameters ---
% Check model parameters for Model 2 (example for subject 28)
GCM_model2{28, 1}.Ep.A  % A matrix (connectivity)
GCM_model2{28, 1}.Ep.B  % B matrix (modulated connectivity)
GCM_model2{28, 1}.Pp.B  % Statistical significance for B matrix
