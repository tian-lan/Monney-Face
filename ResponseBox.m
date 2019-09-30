%% Response Box Setup

% Press = 0; Release = 1;

d = daq.getDevices;

s = daq.createSession('ni');


addDigitalChannel(s,'dev1','Port0/Line0:7','InputOnly');
addDigitalChannel(s,'dev1','Port1/Line0:7','OutputOnly');

out = [1 0 0 0 0 0 0 1];
outputSingleScan(s,out)    % Button 1 red, Button 8 blue

[in,triggerTime] = inputSingleScan(s);

%%% in(1) == 0  % Button 1 pressed  [0,1,1,1,1,1,1,1]
%%% in(4) == 0  % Button 8 pressed  [1,1,1,0,1,1,1,1]
%%% in(2)*in(3) == 0 % One of Button 2 and 4 is pressed