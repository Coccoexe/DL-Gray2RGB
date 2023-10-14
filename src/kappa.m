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

    % combine 16 images into 3 channels
    color = zeros(imgSize(1), imgSize(2), 3);
    color(:, :, 1) = px(:, :, 2);
    color(:, :, 2) = px(:, :, 8);
    color(:, :, 3) = px(:, :, 15);
    color = color / 255;
    imshow(color);

    % compute x and y gradients
    [Gmag1, Gdir1] = imgradient(color(:, :, 1));
    [Gmag2, Gdir2] = imgradient(color(:, :, 2));
    [Gmag3, Gdir3] = imgradient(color(:, :, 3));

    % compute gradient magnitude and direction
    Gmag = Gmag1 + Gmag2 + Gmag3;
    Gdir = Gdir1 + Gdir2 + Gdir3;
    imshowpair(Gmag, Gdir, 'montage');
    
    % duh
    %duh = zeros(imgSize(1), imgSize(2), 3);
    %duh(:, :, 1) = Gmag;
    %duh(:, :, 2) = Gdir;
    %duh(:, :, 3) = sqrt((Gmag / 255).^2 + (Gdir / 255).^2);
    %imshow(duh);

    keyboard
end