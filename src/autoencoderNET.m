% Alessio Cocco 2087635 Andrea Valentinuzzi 2090451, Giovanni Brejc 2096046
% Convolutional Autoencoder for image colorization on 16 planktic foraminifera images
% Matlab R2023b
%
% TRAINING NETWORK

clear all
clc

% INPUT - Read images from dataset folder
dataFolder = 'assignment/dataset';
imds = imageDatastore(dataFolder, ...
    'IncludeSubfolders',true, ...
    'LabelSource','foldernames');

% PROCESSING - Resize images to imgSize and combine 16 at a time (channels)
imgSize = [224 224];
i = 1;
while i < length(imds.Labels)
    % allocate memory for 16 images
    px = zeros(imgSize(1), imgSize(2), 16);

    % read 16 images
    for j = 1:16
        temp = readimage(imds, i);

        % convert to grayscale if necessary
        if size(temp, 3) ~= 1
            temp = rgb2gray(temp);
        end

        % resize to imgSize
        px(:, :, j) = imresize(temp, imgSize);
        i = i + 1;
    end

    % shuffle channels
    px =  px(:, :, randperm(16));
    
end