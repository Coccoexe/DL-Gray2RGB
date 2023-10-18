clear all
warning off


%###########network and data initialization###############

path1 = 'percentileIMG';
path2 = 'AUTOENCIMG_1';

imd1 = imageDatastore(path1, ...
                     'IncludeSubfolders', true, ...
                     'LabelSource','foldername');
               
[imdsTrain1,imdsTest1] = splitEachLabel(imd1,0.8,'randomized'); %split test and training set
imdsTrain2 = copy(imdsTrain1);
imdsTest2 = copy(imdsTest1);

for K = 1:size(imdsTrain2.Files)
    imdsTrain2.Files(K) = strrep(imdsTrain2.Files(K),path1,path2);
end
for K = 1:size(imdsTest2.Files)
    imdsTest2.Files(K) = strrep(imdsTest2.Files(K),path1,path2);
end


numTr = size(imdsTrain1.Files); %number of patterns in the training set

numClasses = numel(categories(imdsTrain1.Labels)); %number of classes in the training set

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

layers1 = layers;
layers2 = layers;
    
%############resizing images############

YTest = imdsTest1.Labels; %save test set labels
imdsTest1 = augmentedImageDatastore(siz,imdsTest1);    
imdsTrain1 = augmentedImageDatastore(siz,imdsTrain1);

imdsTest2 = augmentedImageDatastore(siz,imdsTest2);    
imdsTrain2 = augmentedImageDatastore(siz,imdsTrain2);


%############training############

netTransfer1 = trainNetwork(imdsTrain1,layers1,options);
netTransfer2 = trainNetwork(imdsTrain2,layers2,options);

%############test#############

[YPred1,scores1] = classify(netTransfer1,imdsTest1);
[YPred2,scores2] = classify(netTransfer2,imdsTest2);


save('scores.mat','scores1','scores2','YTest');

%############data############
accuracy1 = mean(YPred1 == YTest);
accuracy2 = mean(YPred2 == YTest);
accuracy1
accuracy2

scores1 = normalize(scores1,2);
scores2 = normalize(scores2,2);
ensembleScore = scores1 * accuracy1 + scores2 * accuracy2;
[~,YPred] = max(ensembleScore,[],2);
groundT = {'G_Bulloides','G_Ruber', 'G_Sacculifer', 'N_Dutertrei', 'N_Incompta', 'N_Pachyderma', 'Others'};
YPred = categorical(groundT(YPred)).';
ensembleAcc = mean(YPred == YTest);
ensembleAcc

%confusionchart(YTest,YPred)
save('net_1.mat', 'layers1');
save('net_2.mat', 'layers2');

%save('resnet_P.mat', 'netTransfer');