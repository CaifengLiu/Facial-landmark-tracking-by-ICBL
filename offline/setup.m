function options = setup()
%%  paths    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

cwd=cd;
cwd(cwd=='\')='/';

options.workDir    = cwd;
options.slash      = '/'; %% For linux


%% @library paths %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~isdeployed

    %files fpr loading data
    addpath([cwd '/load_data/']);
    %data files
    addpath([cwd '/data/']);
    addpath(genpath([cwd '/toolbox/']));
    addpath([cwd '/initial_shape/']);
    addpath([cwd '/model/']);
    addpath([cwd '/BLS_regression/']);
    addpath([cwd '/learned_distribution/']);
    addpath([cwd '/cascade_BLS/']);
    addpath([cwd '/Testing/']);
end

%%Data preparation%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
options.datasetName = 'w300';  %% 'lfpw', 'helen' or 'w300'
options.num_pts = 68;             %% 'lfpw_29' should be 29,w300 'lfpw', 'helen'shoud be 68
options.trainingImageDataPath = './data/lfpw_29/trainset';
options.trainingTruthDataPath = './data/lfpw_29/trainset';
options.root_path             =   'G:/face_align_data';                               
options.testingImageDataPath  = './data/lfpw_29/testset';
options.testingTruthDataPath  = './data/lfpw_29/testset';

options.modelPath              = 'model_10_40_800';


options.meanshape_calculation = 1; % It's true if there need to calculate the meanshape of the train set
options.learningVariation = 1;
%%error evaluation%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LFPW dataset
% options.inter_ocular_left_eye_idx  = [9 11 13 14 17];
% options.inter_ocular_right_eye_idx = [10 12 15 16 18];
%%  or  300-W dataset (68)
options.inter_ocular_left_eye_idx  = 37:42;
options.inter_ocular_right_eye_idx = 43:48;

%%Data augmentation
options.flipflag = 0;
options.datageneration = 0;
options.augnumber = 10;
options.augnumber_scale = 1;
options.augnumber_rotate = 1;
options.augnumber_shift = 0;
options.angle_limit = 60;
%%s Set data parameters%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
options.Aug_BoxScale = 2.0; %%%%%set a scale for tailoring a face area in original image.
options.canvasSize  = [400 400];

%%%%preTraining Prameters%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
options.ifPretrain = 1;
options.n_cascades = 4;
options.ifPCA_for_desc      = 0; 
options.PCA_dims   = [2000,4000,4000,4000];
%%%%Feature parameters%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
options.descType  = 'sift';%%'sift'or 'hog'
options.descScale = [0.16 0.12 0.06 0.06 0.06 60.16 0.16];%decide the landmark's winsize for extracting features
options.descBins  =  4;%% sift parameters
%%%%MIxed GMM
options.GMM = 0;
options.GMM_K_components = 4;
%%%cascaded BLS parameters%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
options.C       = [2^-30 2^-30 2^-30 2^-30];
options.N11     = [40 40 40 40];
options.s       = [.8 .8 .8 .8];
options.N2      = [35 35 35 35];
options.N33     = [800 800 800 800];
options.epoch   = [1 1 1 1 ];

%%%%%%%initial
options.reginitial = 0;
options.initwinsize = [96 128];
options.cellsize = 16;

options.generate_initial = 0;
options.l = 1;%%or augmentation number

options.current_n = 4000;
end