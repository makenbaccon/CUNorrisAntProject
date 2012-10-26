% This will be a quick script I can call to play any of my movies that the
% other programs make, it will assume that the nframes height and width and
% all that jaz are stored in variables in the workspace at the time.

function[] = playvideo(videotitle, vidWidth, vidHeight, xyloObj)

% Size a figure based on the video's width and height.
hf = figure;
set(hf, 'position', [150 150 vidWidth vidHeight])

% Play back the movie once at the video's frame rate.
movie(hf, videotitle, 1, xyloObj.FrameRate);

end