close all;
clearvars;
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

load angle_all.mat;

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
    stim{i,4} = angle_all(i);
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

% angle_all = repmat(angle,numel(PicPath)/5,1);
% % angle_all = angle_all(randperm(size(angle_all,1)),1);
% angle_all = [angle_all(randperm(size(angle_all,1)/num_blocks),1);
%              angle_all(randperm(size(angle_all,1)/num_blocks),1);
%              angle_all(randperm(size(angle_all,1)/num_blocks),1);
%              angle_all(randperm(size(angle_all,1)/num_blocks),1);
%              angle_all(randperm(size(angle_all,1)/num_blocks),1);
%              angle_all(randperm(size(angle_all,1)/num_blocks),1)];

%%%%Stimulus set to display%%%%
for i = 1:numel(PicPath)
    stim_dis{i,1} = stim{i,1};
    stim_dis{i,2} = stim{i,2};
    stim_dis{i,3} = stim{i,3};
    stim_dis{i,4} = stim{i,4};
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



% Load reminder image
FACE_LEFT = imread('FACE_LEFT.png');
FACE_LEFT = Screen('MakeTexture',w,FACE_LEFT);

FACE_RIGHT = imread('FACE_RIGHT.png');
FACE_RIGHT = Screen('MakeTexture',w,FACE_RIGHT);



% Get the size of the screen window in pixels
[screenXpixels, screenYpixels] = Screen('WindowSize', w);

PPI = sqrt(screenXpixels^2 + screenYpixels^2)/ScreenSize;


%Calculate actual display height of images in pixels and DrawTexture

for i = 1:numel(PicPath)
stim_dis{i,5} = dis2scr*PPI*tand(stim_dis{i,4})*2;
stim_dis{i,6} = imresize(stim_dis{i,1},[stim_dis{i,5} NaN]);
stim_dis{i,6} = round(stim_dis{i,6}./255).*255;  % Sharpen
stim_dis{i,7} = Screen('MakeTexture',w,stim_dis{i,6});
end


% actual display for practice 

for i = 1:numel(PicPath_practice)
stim_dis_practice{i,5} = dis2scr*PPI*tand(stim_dis_practice{i,4})*2;
stim_dis_practice{i,6} = imresize(stim_dis_practice{i,1},[stim_dis_practice{i,5} NaN]);
stim_dis_practice{i,6} = round(stim_dis_practice{i,6}./255).*255;  % Sharpen
stim_dis_practice{i,7} = Screen('MakeTexture',w,stim_dis_practice{i,6});
end


% actual display for browsing
for i = 1:numel(PicPath_browse)
stim_browse{i,4} = Screen('MakeTexture',w,stim_browse{i,1});
end



%% Eyelink prep

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


%% Browsing

% counterbalance response
if rand(1) >= 0.5
    key_yes = 'j';
    key_no  = 'f';
    key_yes_cap = 'J';
    key_no_cap = 'F';
else
    key_yes = 'f';
    key_no  = 'j';
    key_yes_cap = 'F';
    key_no_cap = 'J';
end


   message_intro=['Welcome to the perceptual gist study!\n'...
    '\n'...
    '\n'...
    '\n'...
    '\n'...
    'In this experiment, you will be asked to select buttons'...
    '\n'...
    '\n'...
    'to answer questions about the images you see.'...
    '\n'...
    '\n'...
    '\n'...
    'Below are the 3 steps in this study:'...
    '\n'...
    '\n'...   
    '\n'... 
    '\n'...
    '1. There will be a browsing session to get a preview of the types of images to be shown.'...
    '\n'...
    '\n'...  
    '\n'...
    '2. Then there will be a practice session to get used to pushing the correct button.'...
    '\n'...
    '\n'...
    '\n'...   
    '3. The study will begin. It consists of 6 blocks with a break between each block.'...
    '\n'...
    '\n'...   
    '\n'...
    '\n'...
    'Press the space bar to view the instructions.'];

    Screen('TextSize', w, 20);
    DrawFormattedText(w, message_intro, 'center', 'center' , white);
    Screen('Flip',w);
    
    press = true;   
    while press
        [~, keyCode, ~] = KbWait;
        pressedKey = KbName(keyCode) ;
        if  strcmpi(pressedKey, 'space') == 1
            press = false;
        end
        
    end
    waitKeyRelease;
    
    message_browse = ['Browsing Session'...
    '\n'...   
    '\n'...
    '\n'... 
    '\n'...
    'Look at some sample images and decide if you perceived a face.'...
    '\n'...   
    '\n'...
    'The images are of different sizes.'...
    '\n'...   
    '\n'...
    '\n'...
    'Place your right index on BUTTON "J" and'...
    '\n'...
    '\n'... 
    'left index on BUTTON "F" to be prepared to respond.'...
    '\n'...
    '\n'...   
    '\n'...
    'Press "' num2str(key_yes_cap) '" if you perceived a face,'...
    '\n'...
    '\n'... 
    'press "' num2str(key_no_cap) '" if you didn''t.'...
    '\n'...   
    '\n'...
    '\n'...
    'There is no correct answer and'...
    '\n'...   
    '\n'...
    'you will not receive feedback about your answer.'...
    '\n'...   
    '\n'...
    '\n'...
    '\n'...
    'Press the space bar to start the browsing session'];

    DrawFormattedText(w, message_browse, 'center', 'center' , white);
    Screen('Flip',w);
    WaitSecs(1);
    
    press = true;   
    while press
        [~, keyCode, ~] = KbWait;
        pressedKey = KbName(keyCode) ;
        if  strcmpi(pressedKey, 'space') == 1
            press = false;
        end
        
    end
    waitKeyRelease;
    
    if key_yes_cap == 'F'
        Screen('DrawTexture',w,FACE_LEFT);
    elseif key_yes_cap == 'J'
        Screen('DrawTexture',w,FACE_RIGHT);
    end
    
    DrawFormattedText(w, 'Press the space bar to proceed when you are ready.', 'center', 0.8*winRect(4) , white);
    Screen('Flip',w);
    WaitSecs(0.5);
    
    press1 = true;   
    while press1
        [~, keyCode, ~] = KbWait;
        pressedKey = KbName(keyCode) ;
        if  strcmpi(pressedKey, 'space') == 1
            press1 = false;
        end
        
    end    
    waitKeyRelease;
    
    
for i = 1:size(stim_browse,1)
    
    Screen('DrawTexture',w,stim_browse{i,4});
    Screen('Flip', w) ;
    WaitSecs(0.3);
    
    
    press = true;   
    while press
        [~, keyCode, ~] = KbWait;
        pressedKey = KbName(keyCode) ;
        if  strcmpi(pressedKey, 'j') == 1||strcmpi(pressedKey, 'f') == 1
            press = false;
        end
        
    end
    waitKeyRelease;
      
    
end


%% Practice
 
    if ET == 1 % Start a new recording for practice
        EyelinkDoDriftCorrection(el);
        Eyelink('StartRecording');
        % mark zero-plot time in data file
        Eyelink('Message', 'SYNCTIME');
        WaitSecs(0.1);
        
        Eyelink('Message', 'Practice Starts');
        Eyelink('Command', 'record_status_message "Practice"');
    end

    
    if  ET == 1
    Screen('FillRect', w,black, winRect); 
    Screen('Flip', w) ;
    end
    
    
       %%%%%%%%%% Instructions %%%%%%%%%%%
   message_practice = ['Practice Session'...
       '\n'...
       '\n'...
       '\n'...
       '\n'...
       'Now you will do a practice task.'...
       '\n'...
       '\n'...       
       '\n'...
       'This is to practice using the buttons to respond at the speed the study will be running.'...
       '\n'...
       '\n'...
       '\n'...      
       'Leave your left index on "F" and right index on "J" to be prepared to respond.'...
       '\n'...
       '\n'...         
       'First, you will see a "+" in the middle of the screen during each trial.'...
       '\n'...
       '\n'... 
       'Please focus on the "+" to prepare for the image.'...
       '\n'...
       '\n'...           
       'Then the target image will appear and stay for a short period of time.'...
       '\n'...
       '\n'... 
       'When the image disappears, you can respond to whether you peceived a face or not'...
       '\n'...
       '\n'... 
       'by pressing F or J,'...
       '\n'...
       '\n'... 
       'and you have 2 seconds to respond.'...
       '\n'...
       '\n'... 
       '\n'...
       'If no response is detected within 2 seconds,'...
       '\n'...
       '\n'... 
       'the screen will turn red for a moment and move on to the "+" screen and the next image.'...
       '\n'...
       '\n'... 
       '\n'... 
       '\n'... 
       'Press the space bar to start the practice session when you are ready.'];
       

    DrawFormattedText(w, message_practice, 'center', 'center' , white);
    Screen('Flip',w);
    WaitSecs(0.1);
 
    press = true;
while press
    [~, keyCode, ~] = KbWait;
    pressedKey = KbName(keyCode) ;
    if  strcmpi(pressedKey, 'space') == 1
        press = false;
    end
    
end
waitKeyRelease;

    
    if key_yes_cap == 'F'
        Screen('DrawTexture',w,FACE_LEFT);
    elseif key_yes_cap == 'J'
        Screen('DrawTexture',w,FACE_RIGHT);
    end
    
    DrawFormattedText(w, 'Press the space bar to proceed when you are ready.', 'center', 0.8*winRect(4) , white);
    Screen('Flip',w);
    WaitSecs(0.5);
    
    press2 = true;
while press2
    [~, keyCode, ~] = KbWait;
    pressedKey = KbName(keyCode) ;
    if  strcmpi(pressedKey, 'space') == 1
        press2 = false;
    end
    
end
waitKeyRelease;

   Screen('TextSize', w, 60);

for i = 1:size(stim_dis_practice,1)
    DrawFormattedText(w, '+', 'center', 'center' , white);
    Screen('Flip',w);
    WaitSecs(pre_stim_practice(i,1));
    
    
    Screen('DrawTexture',w,stim_dis_practice{i,7});
    Screen('Flip', w);
    WaitSecs(0.25);
    
    Screen('FillRect', w, black);
    Screen('FillRect', w, black); 
    stim_dis_practice{i,8} = Screen('Flip',w);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     bb=1;
     aaa=zeros(1000,1);
     keyisdown  = zeros(size(stim_dis_practice,1),1);
     Time_Press = zeros(size(stim_dis_practice,1),1);
     
     Timewait = true;
     while Timewait
         [keypress,Time_keypress,keyCode, ~] = KbCheck;
         
         if keypress
             aaa(bb)  = Time_keypress;
             keyisdown(i,1) = 1;
             bb = bb + 1;
             Time_Press(i,1) = aaa(1);
             pressedKey = KbName(keyCode);
             stim_dis_practice{i,9} = GetSecs;
             
             DrawFormattedText(w, '+', 'center', 'center' , white);
             Screen('Flip',w);
             WaitSecs(2);
        
         end
         
         if( (Time_keypress - stim_dis_practice{i,8}) > 2)
             Timewait = false;  
         end
     end
     waitKeyRelease;


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    
    if ~isempty(stim_dis_practice{i,9})
    stim_dis_practice{i,10} = stim_dis_practice{i,9} - stim_dis_practice{i,8};
    else
    stim_dis_practice{i,10} = [];
    
    Screen('FillRect', w,red, winRect); 
    Screen('Flip', w) ;
    WaitSecs(4);
    Screen('FillRect', w,black, winRect); 
    Screen('Flip', w) ;
    WaitSecs(1);
    end
    
    %     if ~exist('pressedKey','var')
      if isempty(stim_dis_practice{i,10})
        stim_dis_practice{i,10} = NaN;
        stim_dis_practice{i,11} = 2;
      elseif strcmpi(pressedKey, key_yes) == 1
        stim_dis_practice{i,11} = 1;
      elseif strcmpi(pressedKey, key_no) == 1
        stim_dis_practice{i,11} = 0;    
      else
        stim_dis_practice{i,11} = 2; 

      end

   
end
    if (ET == 1)
        Eyelink('Message', 'Practice ends');     
        Eyelink('StopRecording');
    end
%%%%%%%%%%%%%%%%%%%%%% Practice ends %%%%%%%%%%%%%%%%%%%%%%


%% Experiment

   %%%%%%%%%% Instructions %%%%%%%%%%%
   message_exp = ['Experiment Session'...
    '\n'...   
    '\n'...
    '\n'...
    '\n'...
    'Now you will start the experiment sets.'...
    '\n'...
    '\n'...
    '\n'...
    'Each set will be about 5 minutes long.'...
    '\n'...
    '\n'...
    'Once you start a set, keep going until the break.'...
    '\n'...
    '\n'...
    '\n'...
    '\n'...
    'Press the space bar when you are ready to start.'];

    Screen('TextSize', w, 24);
    DrawFormattedText(w, message_exp, 'center', 'center' , white);
    Screen('Flip',w);
    WaitSecs(0.1);
    
    
    press = true;
while press
    [~, keyCode, ~] = KbWait;
    pressedKey = KbName(keyCode) ;
    if  strcmpi(pressedKey, 'space') == 1
        press = false;
    end
    
end
waitKeyRelease;


    if key_yes_cap == 'F'
        Screen('DrawTexture',w,FACE_LEFT);
    elseif key_yes_cap == 'J'
        Screen('DrawTexture',w,FACE_RIGHT);
    end
    
    DrawFormattedText(w, 'Press the space bar to proceed when you are ready.', 'center', 0.8*winRect(4) , white);
    Screen('Flip',w);
    WaitSecs(0.5);
    
    
    press = true;
while press
    [~, keyCode, ~] = KbWait;
    pressedKey = KbName(keyCode) ;
    if  strcmpi(pressedKey, 'space') == 1
        press = false;
    end
    
end
waitKeyRelease;


%%
%%%%% Start Task %%%%%

for i = 1:size(stim_dis,1)
    

    
    if i>1&&mod(i,50) == 1  % Take a break each 50 trials
        Screen('TextSize', w, 20);
        DrawFormattedText(w, 'Please take a break.\n\n\n Press the space bar when you are ready to continue the task.\n\n If you need more time, let the experimenter know.', 'center', 'center' , white);
        Screen('Flip',w);
        
        press = true;
        while press
            [~, keyCode, ~] = KbWait;
            pressedKey = KbName(keyCode) ;
            if  strcmpi(pressedKey, 'space') == 1
                press = false;
            end
        end
        waitKeyRelease;
        
        
        if key_yes_cap == 'F'
            Screen('DrawTexture',w,FACE_LEFT);
        elseif key_yes_cap == 'J'
            Screen('DrawTexture',w,FACE_RIGHT);
        end
        
    DrawFormattedText(w, 'Press the space bar to proceed when you are ready.', 'center', 0.8*winRect(4) , white);
    Screen('Flip',w);
    WaitSecs(0.1);
    
    
    
    press_reminder = true;
while press_reminder
    [~, keyCode, ~] = KbWait;
    pressedKey = KbName(keyCode) ;
    if  strcmpi(pressedKey, 'space') == 1
        press_reminder = false;
    end
    
end
waitKeyRelease;
        
        
    end %% mod(i,50) = 0
       
    %%%% Break ends
    
        Screen('TextSize', w, 60);
    
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
    if ET == 1
    Eyelink('Message', 'Stimulus appears');
    end

    Screen('Flip', w) ;
    WaitSecs(0.25);
    
    Screen('FillRect', w, black); 
    stim_dis{i,8} = Screen('Flip',w);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     bb=1;
     aaa=zeros(1000,1);
     keyisdown  = zeros(size(stim_dis,1),1);
     Time_Press = zeros(size(stim_dis,1),1);
     
     Timewait = true;
     while Timewait
         [keypress,Time_keypress,keyCode, ~] = KbCheck;
         
         if keypress
             aaa(bb)  = Time_keypress;
             keyisdown(i,1) = 1;
             bb = bb + 1;
             Time_Press(i,1) = aaa(1);
             pressedKey = KbName(keyCode);
             stim_dis{i,9} = GetSecs;
             
             DrawFormattedText(w, '+', 'center', 'center' , white);
             Screen('Flip',w);
             WaitSecs(2);
        
         end
         
         if( (Time_keypress - stim_dis{i,8}) > 2)
             Timewait = false;  
         end
     end
     waitKeyRelease;


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
    WaitSecs(1);
    end
    
    %     if ~exist('pressedKey','var')
      if isempty(stim_dis{i,10})
        stim_dis{i,10} = NaN;
        stim_dis{i,11} = 2;
      elseif strcmpi(pressedKey, key_yes) == 1
        stim_dis{i,11} = 1;
      elseif strcmpi(pressedKey, key_no) == 1
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
    
    
    
    if (mod(i,50)==0)  % savc data each block
        formatOut = 'yymmdd';
        date = datestr(now,formatOut);
        filename = sprintf('%s%c%s_%s.mat', ResPath, filesep, date, Subject);
        save(filename);
    end
    
    
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
Screen('TextSize', w, 20);
DrawFormattedText(w, message_end, 'center', 'center' , white) ;
Screen('Flip', w) ;

        press = true;
        while press
            [~, keyCode, ~] = KbWait;
            pressedKey = KbName(keyCode) ;
            if  strcmpi(pressedKey, 'space') == 1
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
BehavResults{i,2} = stim_dis{i,4}*2;
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