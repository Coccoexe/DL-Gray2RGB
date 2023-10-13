% Alessio Cocco 2087635 Andrea Valentinuzzi 2090451, Giovanni Brejc 2096046
% Convolutional Autoencoder for image colorization on 16 planktic foraminifera images
% Matlab R2023b

% INITIALIZATION - Folders & paths
clear all
clc
baseF = 'assignment/dataset';   % dataset folder
outF = 'AUTOENCIMG';            % colorized images folder
imgS = [224 224];               % image size
path = dir(baseF);
path = {path([path.isdir] & ~ismember({path.name}, {'.', '..'})).name};
if not(isfolder(outF))
    mkdir(outF);
end

TRAIN = false;

% INPUT - 16 images of planktic foraminifera
disp('> INPUT:');
IDX = path;
DATA = {};
for K = 1:length(path)
    disp(path{K});

    % datastore
    imds = imageDatastore(...
        fullfile(baseF, path{K}), ...
        'IncludeSubfolders', true, ...
        'LabelSource', 'foldernames');
    
    % image preparation
    I = 1;
    while I < length(imds.Labels)
        % allocate memory for 16 images
        px = zeros(imgS(1), imgS(2), 16);

        % read 16 images
        for J = 1:16
            temp = readimage(imds, I);

            % convert to grayscale if needed
            if size(temp, 3) ~= 1
                temp = rgb2gray(temp);
            end

            % resize image
            px(:, :, J) = imresize(temp, imgS);
            I = I + 1;
        end

        % shuffle channels to avoid bias
        px = px(:, :, randperm(16));
        DATA{end + 1} = px;
    end

    % save index
    IDX{2, K} = (I - 1) / 16;
end

if TRAIN
    
    % DATASET PREPARATION - shuffle & split
    disp('> DATASET PREPARATION:');
    perm = randperm(length(DATA));
    TRAIN = DATA(perm);
    TRAIN = cat(4, TRAIN{:});
    
    % TRAINING - Convolutional Autoencoder
    disp('> TRAINING:');
    inputSize = [imgS(1) imgS(2) 16];
    layers = [...
        imageInputLayer(inputSize, 'Normalization', 'none')
        convolution2dLayer([3 3], 32, 'Padding', 'same')
        convolution2dLayer([3 3], 64, 'Padding', 'same')
        convolution2dLayer([3 3], 3, 'Padding', 'same')
        convolution2dLayer([3 3], 64, 'Padding', 'same')
        convolution2dLayer([3 3], 32, 'Padding', 'same')
        convolution2dLayer([3 3], 16, 'Padding', 'same')
        regressionLayer];
    
    options = trainingOptions('adam', ...
        'MaxEpochs', 30, ...
        'MiniBatchSize', 8, ...
        'InitialLearnRate', 1e-4, ...
        'Shuffle', 'every-epoch', ...
        'Verbose', false, ...
        'Plots', 'training-progress');
    
    net = trainNetwork(TRAIN, TRAIN, layers, options);
    save('net.mat', 'net');

end


% EXTRACTION - 224x224x3 image
disp('> EXTRACTION:');
COLOR = {};
%encoder = assembleNetwork(net.Layers(1:4));
%encoder = freezeWeights(encoder);

encoder = load("net.mat").net;
a = activations(encoder,DATA{1},'conv_3');
imwrite(a, 'test.png');

I = 1;
for K = 1:length(path)
    disp(path{K});

    % output folder
    if not(isfolder(fullfile(outF, path{K})))
        mkdir(outF, path{K});
    end

    % extract images
    index = 0;
    if K ~= 1
        index = sum(cell2mat(IDX(2, 1:K - 1)));
    end
    for J = 1:IDX{2, K}
        % encode image
        px = predict(encoder, DATA{index + J});
        COLOR{end + 1} = px;
        imwrite(px, fullfile(outF, path{K}, sprintf('%d.png', J)));
    end
end