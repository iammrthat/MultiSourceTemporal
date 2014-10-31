clc
clear

addpath(genpath('../../'))
load('../../data/Foursquare/norm_4sq_small.mat')
load('../../data/Foursquare/fsq_missIdx.mat')
% load('../data/climateP4.mat')
% load('../data/synth/datasets/synth200_9.mat')
% load('../data/Foursquare/norm_4sq.mat')

% For Euclidian
% sigma = 2;
% mu = 18.3486;
% For Harversine
sigma = 0.1;  % Should be selected in a way that effectively few neighbors get weights
mu = 5;
% nTask = length(series);
[nLoc, tLen] = size(series{1});

global verbose
verbose = 1;
global evaluate
evaluate = 2;

% locations = names(:, 2:3);
% sim =  euclidSim(locations, sigma);
% sim = haverSimple(locations, sigma);
sim = sim/(max(sim(:)));       % The goal is to balance between two measures
sim(logical(eye(size(sim)))) = max(sim(:));
sim = diag(sum(sim)) - sim + (1e-5)*eye(nLoc);

max_iter = 4;
quality = zeros(max_iter-1, size(idx_Missing, 2));
% Create the matrices
for i = 1:size(idx_Missing, 2)
    testIndex = idx_Missing(:, 1);
    
    index = ones(nLoc, 1);
    index(testIndex) = 0;
    Iomega = diag( index);
    
    ep = 1e-10;
    mu = logspace(0, 2, 10);
    quality(:, i) =  prepareData(series, Iomega, 5, sim, max_iter, ep, testIndex, 'solveGreedyOrth');
    disp(i)
end

save('KrigingOrtho4sq.mat', 'quality')
% save('krigingOrtho.mat', 'quality')
