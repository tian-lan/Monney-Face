close all;
clear all;
clc;


%%%%%%%%%%%%%%%
% Max angle 18, distance to screen: 26 inches
%%%%%%%%%%%%%%%

PsychDefaultSetup(2);

Screen('Preference', 'SkipSyncTests', 1);
commandwindow

ResPath = '.\Results';

%% Initialization
%%%%%%%%%%%%%%% Gather inputs %%%%%%%%%%%%%%%%%%
T_start = datetime('now');
%%% Collect subject info

prompt = {'\fontsize{10} Age:','\fontsize{10} Gender (Male = 1, Female = 0):','\fontsize{10} Handedness (Left = 1, Right = 0):','\fontsize{10} Doing Eye-tracking? (Yes = 1, No = 0)','\fontsize{10} Subject ID:','\fontsize{10} Distance to screen (inch)'}; 
title    = 'Subject Info';
dims = [1 60];
opts.Interpreter = 'tex';
definput = {'','','','','',''};
Dialog_Answer = inputdlg(prompt,title,dims,definput,opts);

Age        = str2double(Dialog_Answer{1});
Gender     = str2double(Dialog_Answer{2});
Handedness = str2double(Dialog_Answer{3});
ET         = str2double(Dialog_Answer{4});
Subject    = Dialog_Answer{5};
dis2scr    = str2double(Dialog_Answer{6});


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ScreenSize = 24; % In inch
angle      = [1.5;3;6;12;24]./2;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

num_blocks = 6;

%%%%%%%%%%Load images and shuffle%%%%%%%%%%%%%%%%%
PicPath  = dir('pics/*.bmp');
stim     = cell(numel(PicPath),1);
stim_dis = cell(numel(PicPath),11);
BehavResults = cell(numel(PicPath),6);

PicPath_practice  = dir('pics_practice/*.bmp');
stim_practice     = cell(numel(PicPath_practice),1);
stim_dis_practice = cell(numel(PicPath_practice),11);

PicPath_browse  = dir('pics_browse/*.bmp');
stim_browse     = cell(numel(PicPath_browse),1);


for i = 1:numel(PicPath)
    F = fullfile(PicPath(i).folder,PicPath(i).name);
    stim{i,1} = imread(F); 
    stim{i,2} = fullfile(PicPath(i).name);
end
order=randperm(numel(PicPath));

for i = 1:numel(PicPath)
    stim{i,3}=order(i);
end

stim = sortrows(stim,3);

% Shuffe practice
for i = 1:numel(PicPath_practice)
    F = fullfile(PicPath_practice(i).folder,PicPath_practice(i).name);
    stim_practice{i,1} = imread(F); 
    stim_practice{i,2} = fullfile(PicPath_practice(i).name);
end
order_practice=randperm(numel(PicPath_practice));

for i = 1:numel(PicPath_practice)
    stim_practice{i,3}=order_practice(i);
end

stim_practice = sortrows(stim_practice,3);

% shuffle browse
for i = 1:numel(PicPath_browse)
    F = fullfile(PicPath_browse(i).folder,PicPath_browse(i).name);
    stim_browse{i,1} = imread(F); 
    stim_browse{i,2} = fullfile(PicPath_browse(i).name);
end
order_browse=randperm(numel(PicPath_browse));

for i = 1:numel(PicPath_browse)
    stim_browse{i,3}=order_browse(i);
end

stim_browse = sortrows(stim_browse,3);


%%
%%%%%%%%%%%%%%%%% Make sure each block has en equal number of trials per condition

angle_all = repmat(angle,numel(PicPath)/5,1);
% angle_all = angle_all(randperm(size(angle_all,1)),1);
angle_all = [angle_all(randperm(size(angle_all,1)/num_blocks),1);
             angle_all(randperm(size(angle_all,1)/num_blocks),1);
             angle_all(randperm(size(angle_all,1)/num_blocks),1);
             angle_all(randperm(size(angle_all,1)/num_blocks),1);
             angle_all(randperm(size(angle_all,1)/num_blocks),1);
             angle_all(randperm(size(angle_all,1)/num_blocks),1)];

%%%%Stimulus set to display%%%%
for i = 1:numel(PicPath)
    stim_dis{i,1} = stim{i,1};
    stim_dis{i,2} = stim{i,2};
    stim_dis{i,3} = stim{i,3};
    stim_dis{i,4} = angle_all(i,1);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% angles for practice

angle_all_practice = repmat(angle,numel(PicPath_practice)/5,1);
% angle_all = angle_all(randperm(size(angle_all,1)),1);
angle_all_practice = [angle_all_practice(randperm(size(angle_all_practice,1)/num_blocks),1);
             angle_all_practice(randperm(size(angle_all_practice,1)/num_blocks),1);
             angle_all_practice(randperm(size(angle_all_practice,1)/num_blocks),1);
             angle_all_practice(randperm(size(angle_all_practice,1)/num_blocks),1);
             angle_all_practice(randperm(size(angle_all_practice,1)/num_blocks),1);
             angle_all_practice(randperm(size(angle_all_practice,1)/num_blocks),1)];

%%%%Stimulus set to display%%%%
for i = 1:numel(PicPath_practice)
    stim_dis_practice{i,1} = stim_practice{i,1};
    stim_dis_practice{i,2} = stim_practice{i,2};
    stim_dis_practice{i,3} = stim_practice{i,3};
    stim_dis_practice{i,4} = angle_all_practice(i,1);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

pre_stim = 1+0.5*rand(size(stim_dis,1),1);  % Matrix of pre stim interval
pre_stim_practice = 1+0.5*rand(size(stim_dis_practice,1),1);  % Matrix of pre stim interval


% Get the screen numbers
screens = Screen('Screens');

% Draw to the external screen if avaliable
screenNumber = max(screens);

% Define black and white
black  = [0 0 0];
white  = [255 255 255];
grey   = [128 128 128];
red    = [80 0 0];
green  = [0 255 0];
blue   = [0 0 255];


[w, winRect] = Screen('OpenWindow', 0, black);
Screen('TextSize', w, 60);
HideCursor

% Get the size of the screen window in pixels
[screenXpixels, screenYpixels] = Screen('WindowSize', w);

PPI = sqrt(screenXpixels^2 + screenYpixels^2)/ScreenSize;


%Calculate actual display height of images in pixels and DrawTexture

for i = 1:numel(PicPath)
stim_dis{i,5} = dis2scr*PPI*tand(stim_dis{i,4})*2;
stim_dis{i,6} = imresize(stim_dis{i,1},[stim_dis{i,5} NaN]);
stim_dis{i,7} = Screen('MakeTexture',w,stim_dis{i,6});
end


% actual display for practice 

for i = 1:numel(PicPath_practice)
stim_dis_practice{i,5} = dis2scr*PPI*tand(stim_dis_practice{i,4})*2;
stim_dis_practice{i,6} = imresize(stim_dis_practice{i,1},[stim_dis_practice{i,5} NaN]);
stim_dis_practice{i,7} = Screen('MakeTexture',w,stim_dis_practice{i,6});
end


% actual display for browsing
for i = 1:numel(PicPath_browse)
stim_browse{i,4} = Screen('MakeTexture',w,stim_browse{i,1});
end



%% Eyelink prep

if ET == 1
    
    %%%% Do EyeLink Preparation
    dataFiledir = 'C:\Users\tlan\Desktop\Monney Face\Eye-tracking Data';
    
    edfFile = [num2str(Subject) '.edf'];
    
    %  PREPARE
    eyetrackYN = true;
    liveDisplayYN = true;
    
    if eyetrackYN
        
        if EyelinkInit() ~= 1
            sca
            return
        end
        
        
        el=EyelinkInitDefaults(w);
        
        % open file to record data to
        Eyelink('openfile',edfFile);
        
        % Calibrate the eye tracker using the standard calibration routines
        EyelinkDoTrackerSetup(el);
        
    end
    
end   % if ET == 1

if ET == 1
   Eyelink('StartRecording');
   WaitSecs(6)
   Eyelink('StopRecording');
end

Screen('CloseAll');


if ET == 1
    Eyelink('CloseFile');
    
    %get edf file from eyelink computer
%      status=Eyelink('ReceiveFile', EyelinkFilename, fullfile(dataFiledir, [EyelinkFilename '_' num2str(fileNum) '.edf']));
%     status=Eyelink('ReceiveFile', edfFile, fullfile(dataFiledir, [num2str(date) '_' num2str(subject) '_' num2str(ID) '.edf']));
%     status=Eyelink('ReceiveFile', edfFile);
    status=Eyelink('ReceiveFile', edfFile, fullfile(dataFiledir, [num2str(Subject) '.edf']));

    disp(status);
end