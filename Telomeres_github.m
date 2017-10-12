clear 
clc
close all
%%
%% boxplot

%% stats test
%     cutoffLower = 20; 
%     cutoffHigher = 350; 
% 
% total = TstatsTotal.Fun_EquivDiameter(TstatsTotal.Fun_EquivDiameter > cutoffLower & TstatsTotal.Fun_EquivDiameter < cutoffHigher);
% 
% groups = findgroups(TstatsTotal.groupName(TstatsTotal.Fun_EquivDiameter > cutoffLower & TstatsTotal.Fun_EquivDiameter < cutoffHigher));
% 
% HEK = total(groups == 1);s
% HEKAZT = total(groups == 2);
% 
% Hmean = mean(HEK)
% HAZTmean = mean(HEKAZT)
% [h1, p1] = ttest2(HEK, HEKAZT)

%%

pwd
currentFolder = pwd; 
date = '/24_5_2016'; 
%load('TstatsTotal.mat')
    
    Fun_Area = [];  Fun_Perimeter = []; Fun_MajorAxisLength = []; Fun_MinorAxisLength = []; Fun_EquivDiameter = [];  Fun_Eccentricity = [];  Imgname = []; groupName = [];
    TstatsTotal = table(Fun_Area, Fun_Perimeter, Fun_MajorAxisLength, Fun_MinorAxisLength, Fun_EquivDiameter, Fun_Eccentricity, Imgname, groupName); 
%inputfolder = dir(['/Volumes/Data/Charlie/analysis/' date '/*.tiff']) ; 
% inputfolder = dir(['/Users/jcgj201/Documents/super res project/' date '/*.tiff']) ;
inputfolder = dir([currentFolder date '/*.tif']); 

TstatsTotal = masterFn(inputfolder, date, TstatsTotal, currentFolder); 

boxy(TstatsTotal)

save('TstatsTotal.mat', 'TstatsTotal'); 

function TstatsTotal = masterFn(inputfolder, date, TstatsTotal, currentFolder)
    [jitteredImgName, LEDimgName] = getfilenames(inputfolder, date, currentFolder);

    [imgLEDResz, imgJit, imgLEDResz_BW, imgJit_BW] = ResizedBinarised(jitteredImgName, LEDimgName); 

    comparedJit = imgLEDResz_BW & imgJit_BW; 

    figure, imtool(comparedJit); 

    TstatsTotal = Stats(comparedJit, jitteredImgName, TstatsTotal); 

    redbounds(comparedJit, TstatsTotal)
    
end

function [jitteredImgName, LEDimgName] = getfilenames(inputfolder, date, currentFolder)
    for j = 1 : size(inputfolder)

        if contains(inputfolder(j).name, 'F') && contains(inputfolder(j).name, 'super')...
%             && contains(inputfolder(j).name, 'usedthis')
           jitteredImgName = [currentFolder date '/' inputfolder(j).name];
        elseif    contains(inputfolder(j).name, '647') && contains(inputfolder(j).name, 'LED')
%             && contains(inputfolder(j).name, '_3') 
           LEDimgName = [currentFolder date '/' inputfolder(j).name];
        end
        
    end
end

function [imgLEDResz, imgJit, imgLEDResz_BW, imgJit_BW] = ResizedBinarised(jitteredImgName, LEDimgName)
  
    imgLED = imread(LEDimgName);
    
    imgJit = imread(jitteredImgName);

    sizejittered = size(imgJit)

    imgLEDResz = imresize(imgLED, size(imgJit));
    imgLEDResz = medfilt2(imgLEDResz, [3 3]); 

    sizeLED = size(imgLEDResz)
%binarise LED

    imgLEDResz_BW = imgLEDResz >1200;
%     imgLEDResz_BW = imbinarize(imgLEDResz); 
    figure, imshow(imgLEDResz_BW); 
    

                figure,      
                uicontrol('Position',[20 20 200 40],'String','Continue',...
                              'Callback','uiresume(gcbf)');
                disp('This will print immediately');
                uiwait(gcf); 
                disp('This will print after you click Continue');
                
    imgLEDResz_BW = imfill(imgLEDResz_BW,'holes');
%     h=gcf; 
%     save('/Users/jcgj201/Documents/MATLAB/TelomeresjitteredImgName, 'h'); /Users/jcgj201/Documents/MATLAB/Telomeres
%binarise     
%     imgJit_BW = imbinarize(imgJit); 
    imgJit_BW = imgJit > 0.0011;
%     y = 340-96; 
%     x = 2794-2621; 
%     imgJit_BW = imtranslate(imgJit_BW, [-128, y]); 
    figure, imshow(imgJit_BW); 
    
end
 
function [TstatsTotal] = Stats(comparedJit, jitteredImgName, TstatsTotal)

%                 if exist('TstatsTotal'); 
%                 else
%                     Fun_Area = [];  Fun_Perimeter = []; Fun_MajorAxisLength = []; Fun_MinorAxisLength = []; Fun_EquivDiameter = [];  Fun_Eccentricity = [];  Imgname = [], groupName = []; 
%                     TstatsTotal = table(Fun_Area, Fun_Perimeter, Fun_MajorAxisLength, Fun_MinorAxisLength, Fun_EquivDiameter, Fun_Eccentricity, Imgname, groupName); 
%                 end   

                stats = regionprops(comparedJit,'Area', 'Perimeter', 'MajorAxisLength', 'MinorAxisLength', 'EquivDiameter', 'Eccentricity' );
                
                
                
                sz = size(stats)
                
                if sz(1) > 10
                    
                    disp('true')
                    
                    Tstats = struct2table(stats);
                    
                    Tstats = varfun(@(x) x*5, Tstats); 
           
                    szT = size(Tstats(:,1)); 
                    Tstats.Imgname = repmat(cellstr(jitteredImgName), szT); % add ImgName to the table

                    if contains(jitteredImgName, 'p13') 
                        groupName = 'p13'; 
                    elseif contains(jitteredImgName, 'p18') 
                        groupName = 'p18';
                    elseif contains(jitteredImgName, 'HEK') 
                        groupName = 'HEK'; 
                    elseif contains(jitteredImgName, 'AZT')
                        groupName = 'HEK-AZT';
                    elseif contains(jitteredImgName, '4')
                        groupName = 'Conventional';
                

                    end

                    Tstats.groupName = repmat(string({groupName}), szT);
                    
                    TstatsTotal = vertcat(TstatsTotal, Tstats); 
                    
                   
 
                end

end

%%
% Boundaries on the jittered image
function redbounds(comparedJit, TstatsTotal)
    imshow(comparedJit); 
    BWholeFill = imfill(comparedJit, 'holes');
    imshow(BWholeFill); 
    L = bwlabel(BWholeFill);
    s = regionprops(L, 'Area', 'BoundingBox');
    s(1)
    % idx = find([stats.Area]  > 20 );
    idx = find([TstatsTotal.Fun_EquivDiameter] > 80 );
    BWareaSelect = ismember(L,idx);


    B = bwboundaries(BWareaSelect);
    figure, imshow(BWareaSelect)
    hold on
    visboundaries(B)  
end

function boxy(TstatsTotal)
    cutoffLower = 20; 
    cutoffHigher = 350; 
    figure
    subplot(1, 2, 2); 
    boxplot(TstatsTotal.Fun_EquivDiameter(TstatsTotal.Fun_EquivDiameter > cutoffLower & TstatsTotal.Fun_EquivDiameter < cutoffHigher),...
        TstatsTotal.groupName(TstatsTotal.Fun_EquivDiameter > cutoffLower & TstatsTotal.Fun_EquivDiameter < cutoffHigher));

%     boxplot(finaldata, finalgroup)
    ylim([0 350]); 
    ylabel('Telomere equivalent diameter (nm)'); 
    ax = gca; 
    ax.FontSize = 20;
    ax.FontWeight = 'bold'; 
    subplot(1, 2, 1);
    name = {'HEK-AZT';'HEK'};
    x = [1:2]; y = [9.3 10.2];
    stdev = [0.12 0.12]; 
    bar(x,y, 'r')
    set(gca,'xticklabel',name)
    hold on
    e = errorbar(y,stdev, '.'); 
    e.MarkerSize = 10;
    e.Color = 'black';
    e.CapSize = 15;
    ylim([8 11]); 
    ylabel('Telomere Length (kilo base pairs)'); 
    ax = gca; 
    ax.FontSize = 20;
    ax.FontWeight = 'bold';
end

