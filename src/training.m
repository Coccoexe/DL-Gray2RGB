clear all
warning off


%###########network and data initialization###############

pathP = 'percentileIMG';%here you have to save the 3-channels images, not the original images

imP = imageDatastore(pathP, ...
                     'IncludeSubfolders', true, ...
                     'LabelSource','foldername');
               
[imdsTrain,imdsTest] = splitEachLabel(imP,0.8,'randomized'); %split test and training set

numTr = size(imdsTrain.Files); %number of patterns in the training set

numClasses = numel(categories(imdsTrain.Labels)); %number of classes in the training set

net = alexnet;  %load AlexNet
siz=[227 227];


%###########tuning rete############


miniBatchSize = 30;
learningRate = 1e-4;
metodoOptim='sgdm';
options = trainingOptions(metodoOptim,...
    'MiniBatchSize',miniBatchSize,...
    'MaxEpochs',30,...
    'InitialLearnRate',learningRate,...
    'ExecutionEnvironment','parallel',...
    'Verbose',false,...
    'Plots','training-progress');
numIterationsPerEpoch = floor(numTr/miniBatchSize);


layersTransfer = net.Layers(1:end-3);
layers = [
        layersTransfer
        fullyConnectedLayer(numClasses,'WeightLearnRateFactor',20,'BiasLearnRateFactor',20)
        softmaxLayer
        classificationLayer];
    
    
%############resizing images############

YTest = imdsTest.Labels; %save test set labels
imdsTest = augmentedImageDatastore(siz,imdsTest);    
imdsTrain = augmentedImageDatastore(siz,imdsTrain);


%############training############

netTransfer = trainNetwork(imdsTrain,layers,options);

%############test#############

[YPred,scores] = classify(netTransfer,imdsTest);

%############data############
accuracy = mean(YPred == YTest);
accuracy
confusionchart(YTest,YPred)