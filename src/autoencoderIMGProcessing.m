% Alessio Cocco 2087635 Andrea Valentinuzzi 2090451, Giovanni Brejc 2096046
% Convolutional Autoencoder for image colorization on 16 planktic foraminifera images
% Matlab R2023b

% INITIALIZATION - Folders & paths
clear all
clc
baseF = 'assignment/dataset';   % dataset folder
outF = 'AUTOENCIMG';            % colorized images folder
path = dir(baseF);
path = {path([path.isdir] & ~ismember({path.name}, {'.', '..'})).name};
if not(isfolder(outF))
    mkdir(outF);
end

% INPUT - 16 images of planktic foraminifera
DATA = path;                                    % initialize dataset
for K = 1 : length(path)                        % for each folder
    imds = imageDatastore(...                   % image datastore
        fullfile(baseF, path{K}), ...
        'IncludeSubfolders', true, ...
        'LabelSource', 'foldernames');
    
    if not(isfolder(path{K}))
        mkdir(outF, path{K});                   % create folder for colorized images
    end
    
    I = 1;
    while I < length(imB.Labels)                % for each image
        [imgR, imgC] = size(readimage(imds, I));
        px = zeros(imgR, imgC, 16);             % initialize colorized image

        for J = 1 : 16                          % for each channel (batches of 16)
            px(:, :, J) = readimage(imds, I);   % copy grayscale image
            I = I + 1;                          % next image
        end


    end
end

% PREPROCESSING - Image resizing to 16x...x...


% TRAINING - Convolutional Autoencoder


% EXTRACTION - 3x...x... image


% OUTPUT - colorized image