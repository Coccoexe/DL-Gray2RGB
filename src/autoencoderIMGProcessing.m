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

% INPUT - 16 images of planktic foraminifera
disp('> INPUT:');
DATA = path;                                      % initialize dataset
for K = 1 : length(path)                          % for each folder
    disp(path{K});
    imds = imageDatastore(...                     % image datastore
        fullfile(baseF, path{K}), ...
        'IncludeSubfolders', true, ...
        'LabelSource', 'foldernames');
    
    if not(isfolder(fullfile(outF, path{K})))
        mkdir(outF, path{K});                     % create folder for colorized images
    end

    I = 1;
    while I < length(imds.Labels)                 % for each image
        px = zeros(imgS(1), imgS(2), 16);         % initialize colorized image

        for J = 1 : 16                            % for each channel (batches of 16)
            imgT = readimage(imds, I);            % read image
            if size(imgT, 3) ~= 1
                imgT = rgb2gray(imgT);            % convert to grayscale
            end
            px(:, :, J) = imresize(imgT, imgS);   % resize image
            I = I + 1;                            % next image
        end

        DATA{2, K}{(I - 1) / 16} = px;            % save colorized image
    end
end

% PREPROCESSING - Image resizing to 16x...x...


% TRAINING - Convolutional Autoencoder


% EXTRACTION - 3x...x... image


% OUTPUT - colorized image