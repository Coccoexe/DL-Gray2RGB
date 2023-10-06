%###names of input and output folders###

path = {'NCSU-CUB_Foram_Images_G-bulloides','NCSU-CUB_Foram_Images_G-ruber','NCSU-CUB_Foram_Images_G-sacculifer','NCSU-CUB_Foram_Images_N-dutertrei','NCSU-CUB_Foram_Images_N-incompta','NCSU-CUB_Foram_Images_N-pachyderma','NCSU-CUB_Foram_Images_Others'};
outF = 'PCAIMG';

%create output folder
mkdir(outF);
%start of main loop, goes through all folders of the dataset 

for K = 1 : length(path)

    %create datastore of the selected folder
    imB = imageDatastore(strcat('Dataset/',path{K}), ...
                         'IncludeSubfolders', true, ...
                         'LabelSource','foldernames');
    
    %create new folder in the selected output folde that has the same name of the input folder                  
    mkdir(outF,path{K}); 
    
    %go through each image in the dataStore
    I = 1;
    while I < length(imB.Labels)                

        [imgR, imgC] = size(readimage(imB,I));
        px = zeros(imgR,imgC,16);
        %this loop goes through 16 images at a time and stores the value of
        %each pixel in a 3D matrix 
        for J = 1 : 16
            img = readimage(imB,I);
            for R = 1 : imgR
               for C = 1 : imgC
                   px(R,C,J) = img(R,C);
               end
            end
            I = I + 1;
        end
              
        %reshape matrix in order to make it compatible with the PCA toolbox 
        %function 
        px = reshape(px,imgR*imgC,16);
        %compute PCA, this treats every group of 16 pixels as an
        %entry, reducing the dimensionaly to 3
        [px,pxm] = compute_mapping(px,'PCA',3);
        %restructure the mapped matrix, use the 3 values of each pixel  
        %obtained using the pca methodas as RGB values
        imgO = reshape(px,imgR,imgC,3);
        imgO = uint8(imgO);
        %save image
        nome = strcat(outF,'/',path{K},'/',char(imB.Labels(I-1)),'.png');
        imwrite(imgO,nome);
    end
end    