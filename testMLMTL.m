
% X,Y: cell of 1 x numTasks
% X{i} =  featureDim  x numSample
% Y{i} =  1 x numSamples
% indicator: mode dim of tensor [ featureDim x TaskCategory1 x TaskCategory2 ...]
% beta: hyper_para, lambda: weight of regularizaer
% outerNiTPre: iteration number 100 is enough
clear all;
load 'climateP17'
% Climate dataset has  125 locations in 17 agents, 156 days of training
% data. Task: predict the values for certain location and certain agents


%load 'genomeP'
% Genomic dataset has 798 location(??) for 10 speciest, in 6 time stamp

nType = length(series);
[nLoc, nTime] = size(series{1});

numTask = nLoc * nType;



X = cell(1,numTask);
Y = cell(1,numTask);

% nLag = 5;
% nSample = nTime-nLag;
% for type = 1:nType
%     % contruct feature and label for each task
%     for loc = 1:nLoc
%          task_idx = (type-1)*nLoc+loc;
%          features = zeros(nLag, nSample);
%          labels = zeros(nSample,1);
%          
%          for sample = 1:nSample
%              start_idx = sample;
%              end_idx = sample+nLag-1;
%              features(:,sample) = series{type}(loc,start_idx:end_idx)';
%              labels(sample) = series{type}(loc,end_idx+1);
%          end
%          
%          X{task_idx}= features;
%          Y{task_idx}= labels;
%     end
% end
% indicators = [nLag, nType, nLoc];


nSample = nTime-1;
 for type = 1:nType
     % construct feature and label for each task
     for loc = 1:nLoc
         task_idx = (type-1)*nLoc + loc;
         features = zeros(nLoc,nSample);
         labels = zeros(nSample,1);
         
         for sample = 1:nSample
             features(:,sample) = series{type}(:,sample);
             labels(sample) = series{type}(loc,sample+1);
         end
         
         X{task_idx} = features;
         Y{task_idx} = labels;
     end
 end
 indicators = [nLoc, nLoc,nType];        

fprintf('Data Constructed\n');

%%
nTrainSample = ceil(nSample/3*2);
nTestSample = nSample-nTrainSample;
TrainIdx = randsample(nSample, nTrainSample);
TestIdx = setdiff(1:nSample,TrainIdx);

X_train = cell(1,numTask);
Y_train = cell(1,numTask);

X_test = cell(1,numTask);
Y_test = cell(1,numTask);

for i = 1:numTask
    X_train{i} = X{i}(:,TrainIdx);
    Y_train{i} = Y{i}(TrainIdx);
    X_test{i} = X{i}(:,TestIdx);
    Y_test{i} = Y{i}(TestIdx);
end

fprintf('Train/Test Splitted\n');

%% train (TBD: cross validation)

beta = 1e-2;
lambda = 1e-3;
outerNiTPre = 50;
[ W tensorW ] = MLMTL_Convex( X_train, Y_train, indicators, beta, lambda );

 MSE_Convex = MLMTL_Test(X_test,Y_test, W);
 
[ W tensorW ] = MLMTL_Mixture( X_train, Y_train, indicators, beta, lambda );

 MSE_Mixture = MLMTL_Mixture(X_test,Y_test, W);
 
fprintf('Prediction MSE Convex: %d Mixture:  %d\n ',MSE_Convex,MSE_Mixture);



%%
% 
% W_tensor = reshape(W, indicators);
% [p1,p2,p3] = tensorModeRank(W_tensor);
