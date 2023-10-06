%###names of input and output folders###

path = {'NCSU-CUB_Foram_Images_G-bulloides','NCSU-CUB_Foram_Images_G-ruber','NCSU-CUB_Foram_Images_G-sacculifer','NCSU-CUB_Foram_Images_N-dutertrei','NCSU-CUB_Foram_Images_N-incompta','NCSU-CUB_Foram_Images_N-pachyderma','NCSU-CUB_Foram_Images_Others'};
outF = 'DCTIMG';

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
        %reduce dimension of the image matrix from 16 to 3 using dct and convert
        %pixel values from double to integers
        imgO = dct(px,3,3);
        imgO = uint8(imgO);
        
        %save the image in the new folder
        
        nome = strcat(outF,'/',path{K},'/',char(imB.Labels(I-1)),'.png');
        imwrite(imgO,nome);
    end
end    