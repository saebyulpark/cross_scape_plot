function d = dursec(nmat);
% Note durations in seconds
% function d = dursec(nmat);
% Returns the durations in seconds of the notes in NMAT
%
% Input argument:
%	NMAT = notematrix
%
% Output:
%	D = note durations in seconds
%
% Comment: Auxiliary function that resides in private directory
%
%  Date		Time	Prog	Note
% 4.6.2002	18:36	TE	Created under MATLAB 5.3 (Mac)
%� Part of the MIDI Toolbox, Copyright � 2004, University of Jyv�skyl�, Finland
% See License.txt
d = nmat(:,7);
