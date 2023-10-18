# DL-Gray2RGB

## Folder Structure

> - assignment: contains original code and dataset
> - src: our code
>     - autoencoderIMGProcessing.m    used to train an autoencoder that transform 16 grayscale images into an rgb image
>     - train_RESNET50.m              used to train the pretrained RESNET50 to classify the rgb images created with autoencoder
> - out_1 and out_2 contains trained RESNET50 with results obtained
> - AUTOENCIMG_1 and AUTOENCIMG_2 are the two colorized images created respectively by net_1 and net_2
> - net_1 and net_2 are two trained autoencoders
> - out_OR contains the output for the original method (percentileIMG)
> - percentileIMG is the original method used to colorize images

## autoencoderIMGPocessing.m

### Autoencoder Structure

> imageInputLayer     (227x227x16)  <br>
> convolution2dLayer  (227x227x32)  <br>
> batchNormalizationLayer           <br>
> leakyReluLayer                    <br>
> convolution2dLayer  (227x227x64)  <br>
> batchNormalizationLayer           <br>
> leakyReluLayer                    <br>
> convolution2dLayer  (227x227x3)   <br>
> batchNormalizationLayer           <br>
> leakyReluLayer                    <br>
> convolution2dLayer  (227x227x64)  <br>
> batchNormalizationLayer           <br>
> leakyReluLayer                    <br>
> convolution2dLayer  (227x227x32)  <br>
> batchNormalizationLayer           <br>
> leakyReluLayer                    <br>
> convolution2dLayer  (227x227x16)  <br>
> regressionLayer                   <br>

### Code

> #### Part 1 [20-64]
> Convert original dataset into images block of size 227x227x16

> #### Part 2 [66-108]
> Train an autoencoder

> #### Part 3 [112-142]
> Extract colorized images from the central layer of the autoencoder with dimensions 227x227x3

## training_RESNET50.m

> load the pretrained RESNET50 and replace the last 3 layers with:
> - fullyconnected
> - softmax
> - classification