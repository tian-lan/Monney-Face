function t=waitKeyRelease
%
% function t=waitKeyRelease
%
% Same thing as clear_KbCheck
%
	[keyIsDown,t,keyCode] = KbCheck(-3);
	while keyIsDown
		[keyIsDown,t,keyCode] = KbCheck(-3);
	end
