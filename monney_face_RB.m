clearvars;
clc;
close all;
sca;


%% Response Box Setup

% Press = 0; Release = 1;

d = daq.getDevices;

s = daq.createSession('ni');


addDigitalChannel(s,'dev1','Port0/Line0:7','InputOnly');
addDigitalChannel(s,'dev1','Port1/Line0:7','OutputOnly');

out = [1 0 0 0 0 0 0 1];
outputSingleScan(s,out)    % Button 1 red, Button 8 blue


%%

PsychDefaultSetup(2);

Screen('Preference', 'SkipSyncTests', 1);
commandwindow

ResPath = '.\Results';

%%
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
Subject    = str2double(Dialog_Answer{5});
dis2scr    = str2double(Dialog_Answer{6});



%%%%% Doing Eye-tracking? %%%%%%%%%%

% question = ['Doing Eye-tracking? (Y/N)\n'...
%            ''];
% ET = input(question,'s');
% 
% while (ET ~= 'y')&&(ET ~= 'n')
%     question = ['Doing Eye-tracking? (Y/N)\n'...
%                ''];
%     ET = input(question,'s');
% end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


ScreenSize = 24; % In inch
angle      = [1.5;3;6;9;12];


% question = 'Please enter your subject ID: ';
% Subject = input(question,'s');
% 
% dis2scr    = str2double(input('Distance to screen (inch) =  ','s'));

num_blocks = 6;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%Load images and shuffle%%%%%%%%%%%%%%%%%
PicPath  = dir('pics/*.bmp');
stim     = cell(numel(PicPath),1);
stim_dis = cell(numel(PicPath),11);
BehavResults = cell(numel(PicPath),6);

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

pre_stim = 1+0.5*rand(size(stim_dis,1),1);  % Matrix of pre stim interval


% Get the screen numbers
screens = Screen('Screens');



% Draw to the external screen if avaliable
screenNumber = max(screens);

% Define black and white
black  = [0 0 0];
white  = [255 255 255];
grey   = [128 128 128];
red    = [255 0 0];
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
stim_dis{i,5} = dis2scr*PPI*tand(stim_dis{i,4});
stim_dis{i,6} = imresize(stim_dis{i,1},[stim_dis{i,5} NaN]);
stim_dis{i,7} = Screen('MakeTexture',w,stim_dis{i,6});
end

%%

if ET == 1
   
    %%%% Do EyeLink Preparation
    dataFiledir = '';

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
   
   % record a few samples before we actually start displaying
   WaitSecs(0.1);
   
   % mark zero-plot time in data file
   Eyelink('Message', 'SYNCTIME');
   
   Eyelink('Message', 'Experiment begins');
 



   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
   Eyelink('StopRecording');
end


   %%%%%%%%%% Instructions %%%%%%%%%%%
   message_ins=['Welcome!\n'...
    '\n'...
    '\n'...
    'In this experiment, you will be presented with some images.'...
    '\n'...
    '\n'...
    'You will be asked whether you perceived a face or not.'...
    '\n'...
    '\n'...
    'There is no correct answer.'...
    '\n'...
    '\n'...
    'Place your right index on button "J" and your right middle finger on button "K"'...
    '\n'...
    '\n'...
    'Press "J" if you peceived a face, and press "K" if you didn''t'...
    '\n'...
    '\n'...
    '\n'...
    'Press the space bar when you are ready to start.\n'];

    Screen('TextSize', w, 32);
    DrawFormattedText(w, message_ins, 'center', 'center' , white);
    Screen('Flip',w);
    
    
    press = true;
while press
    [in,triggerTime] = inputSingleScan(s);
    if  in(2)*in(3) == 0
        press = false;
    end
    
end

Screen('TextSize', w, 60);
%%
%%%%% Start Task %%%%%

for i = 1:100 %size(stim_dis,1)
    

    
    if i>1&&mod(i,50) == 1  % Take a break each 50 trials
        DrawFormattedText(w, 'Please take a break for 2 minutes.', 'center', 'center' , white);
        Screen('Flip',w);
        WaitSecs(10);
        DrawFormattedText(w, 'Plese press the space bar to continue the task', 'center', 'center' , white);
        Screen('Flip',w);
        
        press = true;
        while press
            [in,triggerTime] = inputSingleScan(s);
            if  in(2)*in(3) == 0
                press = false;
            end
        end
        
    end %% mod(i,50) = 0
       
    %%%% Break ends
    
        
    
    if ET == 1&&mod(i,50)==1 % Start a new recording each block
        EyelinkDoDriftCorrection(el);
        Eyelink('StartRecording');
        Eyelink('Message', 'Block Starts');
%         Eyelink('Command', 'record_status_message "Block %d"',floor(i/51)+1);
    end
    
    
  
    
    if ET == 1
    Eyelink('Message', 'Trial %d',i);
    Eyelink('Command', 'record_status_message "Block %d  Trial %d"',floor(i/51)+1,i);
    end
    
    if  ET == 1&&mod(i,50)==1
    Screen('FillRect', w,black, winRect); 
    Screen('Flip', w) ;
    end
    
    DrawFormattedText(w, '+', 'center', 'center' , white);
    Screen('Flip',w);
    WaitSecs(pre_stim(i,1));
    
    
    Screen('DrawTexture',w,stim_dis{i,7});

    Screen('Flip', w) ;
    WaitSecs(0.25);
    
    DrawFormattedText(w, 'Did you perceive a face?', 'center', 'center' , white);
    stim_dis{i,8} = Screen('Flip',w);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     bb=1;
     aaa=zeros(1000,1);
     keyisdown      = zeros(size(stim_dis,1),1);
     Time_Press     = zeros(size(stim_dis,1),1);
     button_pressed = zeros(size(stim_dis,1),1);
     
     Timewait = true;
     while Timewait
         [keypress,Time_keypress,keyCode, ~] = KbCheck;
         [in_res,triggerTime] = inputSingleScan(s);
         
         if in_res(1)*in_res(4) == 0
             button_pressed(i,1) = find(in_res == 0);  % Find which button is pressed
             stim_dis{i,9} = GetSecs;
             
             DrawFormattedText(w, '+', 'center', 'center' , white);
             Screen('Flip',w);
             WaitSecs(2);
         end
    
         if( (Time_keypress - stim_dis{i,8}) > 2)
             Timewait = false;  
         end
         
     end


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    if ~isempty(stim_dis{i,9})
    stim_dis{i,10} = stim_dis{i,9} - stim_dis{i,8};
    else
    stim_dis{i,10} = [];
    Screen('FillRect', w,red, winRect); 
    Screen('Flip', w) ;
    WaitSecs(4);
    Screen('FillRect', w,black, winRect); 
    Screen('Flip', w) ;
    end
    
    %     if ~exist('pressedKey','var')
      if isempty(stim_dis{i,10})
        stim_dis{i,10} = NaN;
        stim_dis{i,11} = 2;
      elseif button_pressed(i,1) == 4 
        stim_dis{i,11} = 1;
      elseif button_pressed(i,1) == 1
        stim_dis{i,11} = 0;    
      else
        stim_dis{i,11} = 2; 

      end
      
      if ET == 1
      Eyelink('Message', 'Trial ends');
      end
      
    if (ET == 1)&&(mod(i,50)==0) % Start a new recording each block
        Eyelink('Message', 'Block ends');     
        Eyelink('StopRecording');
    end
    
    clear in_res
    
end

%% Ending

message_end=[ '\n'...
    'Complete!\n'...
    '\n'...
    '\n'...
    'Thank you for your participation.\n'...
    '\n'...
    '\n'...
    'Press the space bar to exit.\n'];

DrawFormattedText(w, message_end, 'center', 'center' , white) ;
Screen('Flip', w) ;

        press = true;
        while press
            [in,triggerTime] = inputSingleScan(s);
            if  in(2)*in(3) == 0
                press = false;
            end  
        end


        if ET == 1
            Eyelink('Message', 'Experiment ends');
            
        end

Screen('CloseAll');


%% Behavioral finalize
for i = 1:size(stim_dis,1)
stim_dis{i,10} = stim_dis{i,10}*1000;  % Convert RT from s to ms
end


for i = 1:size(stim_dis,1)
BehavResults{i,1} = stim_dis{i,2}; 
BehavResults{i,2} = stim_dis{i,4};
BehavResults{i,3} = stim_dis{i,5};
BehavResults{i,4} = stim_dis{i,10};
BehavResults{i,5} = stim_dis{i,11};
BehavResults{i,6} = pre_stim(i,1);
end

fields = {'Stimulus', 'Angle', 'Image_Height', 'RT', 'Response', 'PreStim_Interval'};
BehavResults = cell2struct(BehavResults, fields, 2);


T_end = datetime('now');
formatOut = 'yymmdd';
date = datestr(now,formatOut);
% filename = [num2str(date) '_' num2str(Initial) '_' num2str(Student)];
filename = sprintf('%s%c%s_%s.mat', ResPath, filesep, date, Subject);

save(filename);


%% EyeLink Finalize
if ET == 1
    Eyelink('CloseFile');
    
    %get edf file from eyelink computer
%      status=Eyelink('ReceiveFile', EyelinkFilename, fullfile(dataFiledir, [EyelinkFilename '_' num2str(fileNum) '.edf']));
%     status=Eyelink('ReceiveFile', edfFile, fullfile(dataFiledir, [num2str(date) '_' num2str(subject) '_' num2str(ID) '.edf']));
%     status=Eyelink('ReceiveFile', edfFile);
    status=Eyelink('ReceiveFile', edfFile, fullfile(dataFiledir, [num2str(Subject) '.edf']));

    disp(status);
    
    Eyelink('Shutdown');
end

ShowCursor;