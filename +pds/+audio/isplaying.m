function output = isplaying(p,sound_name)
%pds.audio.isplaying(p,sound_name) return true if sound associated with the
%name sound_name is still playing
%
%  In pds.audio.setup, the tones in beepsounds were loaded and teh handles
%  to the virtual sound devices were stored in p.trial.sound.wavfiles as a
%  series of fields which here we can reference as
%  p.trial.sound.wavfiles.(sound_name)
%
%  This function checks the status of the pahandle and returns true if it
%  is still playing.
%
%  Lee Lovejoy
%  ll2833@columbia.edu
%  March 15, 2019

%  Virtual device handle
[~,name] = fileparts(p.trial.sound.wavfiles.(sound_name));
pahandle = p.trial.sound.(name);

%  Find out if there is currently a sound playing on that device
status = PsychPortAudio('GetStatus',pahandle);

%  Return true if status is active
output = status.Active;