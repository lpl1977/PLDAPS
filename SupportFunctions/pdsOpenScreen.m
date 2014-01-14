function ds = pdsOpenScreen(ds)
% ds = pdsOpenScreen(ds)
% Opens PsychImaging Window with preferences set for use with Datapixx 
% ds is the dv.disp struct in PLDAPS
% 
 
% 12/12/2013 jly wrote it   Mostly taken from Init_StereoDispPI without any
%                           of the switch-case in the front for each rig.
%                           This assumes you have set up your display
%                           struct before calling.
% InitializeMatlabOpenGL; 
AssertOpenGL;
% prevent splash screen
Screen('Preference','VisualDebugLevel',3);
% Initiate Psych Imaging screen configs
PsychImaging('PrepareConfiguration');

%% Setup Psych Imaging
% Add appropriate tasks to psych imaging pipeline

% set the size of the screen 
if ds.stereoMode >= 6 || ds.stereoMode <=1
    ds.width = 2*atand(ds.widthcm/2/ds.viewdist);
else
    ds.width = 2*atand((ds.widthcm/4)/ds.viewdist);
end


% if ds.normalizeColor == 1
%     disp('****************************************************************')
%     disp('****************************************************************')
%     disp('Turning on Normalized High res Color Range')
%     disp('Sets all displays to use color range from 0-1 (e.g. NOT 0-255)')
%     disp('Potential danger: this fxn sets color range to unclamped...don''t')
%     disp('know if this will cause issue. TBC 12-18-2012')
%     disp('****************************************************************')
% 	PsychImaging('AddTask', 'General', 'NormalizedHighresColorRange');
% end


if ds.useOverlay == 1 
    disp('****************************************************************')
    disp('****************************************************************')
    disp('Using overlay pointer')
    disp('Adds flags for UseDataPixx and EnableDataPixxM16OutputWithOverlay')
    disp('****************************************************************')
    % Tell PTB we are using Datapixx
    PsychImaging('AddTask', 'General', 'UseDataPixx');
    PsychImaging('AddTask', 'General', 'FloatingPoint32Bit');
    % Turn on the overlay
    PsychImaging('AddTask', 'General', 'EnableDataPixxM16OutputWithOverlay');
else
    disp('****************************************************************')
    disp('****************************************************************')
    disp('No overlay pointer')
    disp('****************************************************************')
    PsychImaging('AddTask', 'General', 'FloatingPoint32BitIfPossible');   
end


if strcmp(ds.stereoFlip,'right');
    disp('****************************************************************')
    disp('****************************************************************')
    disp('Setting stereo mode for use with planar')
    disp('Flipping the RIGHT monitor to be a mirror image')
    disp('****************************************************************')
    PsychImaging('AddTask', 'RightView', 'FlipHorizontal');
elseif strcmp(ds.stereoFlip,'left')
    disp('****************************************************************')
    disp('****************************************************************')
    disp('Setting stereo mode for use with planar')
    disp('Flipping the LEFT monitor to be a mirror image')
    disp('****************************************************************')
    PsychImaging('AddTask', 'LeftView', 'FlipHorizontal');
end

% fancy gamma table for each screen
% if 2 gamma tables
% PsychImaging('AddTask', 'LeftView', 'DisplayColorCorrection', 'LookupTable');
% PsychImaging('AddTask', 'RightView', 'DisplayColorCorrection', 'LookupTable');
% end        
disp('****************************************************************')
disp('****************************************************************')
disp('Adding DisplayColorCorrection LookUpTable to FinalFormatting')
disp('****************************************************************')
PsychImaging('AddTask', 'FinalFormatting', 'DisplayColorCorrection', 'LookupTable');
PsychImaging('AddTask', 'FinalFormatting', 'DisplayColorCorrection', 'SimpleGamma');


%% Open double-buffered onscreen window with the requested stereo mode
disp('****************************************************************')
disp('****************************************************************')
fprintf('Opening screen %d with background %d in stereo mode %d\r', ds.scrnNum, ds.bgColor(1), ds.stereoMode)
disp('****************************************************************')
[ds.ptr, ds.winRect]=PsychImaging('OpenWindow', ds.scrnNum, ds.bgColor, ds.screenSize, [], [], ds.stereoMode, 0);


% % Set gamma lookup table
if isfield(ds,'gamma')
    disp('****************************************************************')
    disp('****************************************************************')
    disp('Loading gamma correction')
    disp('****************************************************************')
    if isstruct(ds.gamma) 
        if isfield(ds.gamma, 'table')
            PsychColorCorrection('SetLookupTable', ds.ptr, ds.gamma.table, 'FinalFormatting');
        elseif isfield(ds.gamma, 'power')
            PsychColorCorrection('SetEncodingGamma', ds.ptr, ds.gamma.power, 'FinalFormatting');
        end
    else
        PsychColorCorrection('SetEncodingGamma', ds.ptr, ds.gamma, 'FinalFormatting');
    end

end


% % This seems redundant. Is it necessary?
if ds.normalizeColor == 1
    disp('****************************************************************')
    disp('****************************************************************')
    disp('clamping color range')
    disp('****************************************************************')
    Screen('ColorRange', ds.ptr, 1, 0);
end
 




%% Set some basic variables about the display
ds.ppd = ds.winRect(3)/ds.width;                        % calculate pixels per degree
ds.frate = round(1/Screen('GetFlipInterval',ds.ptr));   % frame rate (in Hz)
ds.ifi=Screen('GetFlipInterval', ds.ptr);               % Inter-frame interval (frame rate in seconds)
ds.ctr = [ds.winRect(3:4),ds.winRect(3:4)]./2;          % Rect defining screen center
ds.info = Screen('GetWindowInfo', ds.ptr);              % Record a bunch of general display settings

% Set screen rotation
ds.ltheta = 0.00*pi;                                    % Screen rotation to adjust for mirrors
ds.rtheta = -ds.ltheta;
ds.scr_rot = 0;                                         % Screen Rotation for opponency conditions


% Make text clean
Screen('TextFont',ds.ptr,'Helvetica'); 
Screen('TextSize',ds.ptr,16);
Screen('TextStyle',ds.ptr,1);

% Set up alpha-blending for smooth (anti-aliased) drawing 
disp('****************************************************************')
disp('****************************************************************')
fprintf('Setting Blend Function to %s,%s\r', ds.sourceFactorNew, ds.destinationFactorNew);
disp('****************************************************************')
Screen('BlendFunction', ds.ptr, ds.sourceFactorNew, ds.destinationFactorNew);  % alpha blending for anti-aliased dots


ds.t0 = Screen('Flip', ds.ptr); 