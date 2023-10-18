clear all
warning off


%###########network and data initialization###############

pathP = 'AUTOENCIMG_2';%here you have to save the 3-channels images, not the original images

imP = imageDatastore(pathP, ...
                     'IncludeSubfolders', true, ...
                     'LabelSource','foldername');
               
[imdsTrain,imdsTest] = splitEachLabel(imP,0.8,'randomized'); %split test and training set

numTr = size(imdsTrain.Files); %number of patterns in the training set

numClasses = numel(categories(imdsTrain.Labels)); %number of classes in the training set

net = resnet50;  %load AlexNet
siz=[224 224];


%###########tuning rete############


miniBatchSize = 30;
learningRate = 1e-4;
metodoOptim='sgdm';
options = trainingOptions(metodoOptim,...
    'MiniBatchSize',miniBatchSize,...
    'MaxEpochs',15,...
    'InitialLearnRate',learningRate,...
    'Verbose',false,...
    'Plots','training-progress');
numIterationsPerEpoch = floor(numTr/miniBatchSize);

% transfer learning
layers = layerGraph(net);
layers = replaceLayer(layers, 'fc1000',fullyConnectedLayer(numClasses,'WeightLearnRateFactor',20,'BiasLearnRateFactor',20));
layers = replaceLayer(layers, 'fc1000_softmax',softmaxLayer);
layers = replaceLayer(layers, 'ClassificationLayer_fc1000',classificationLayer);


    
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

save('resnet_2.mat', 'netTransfer');