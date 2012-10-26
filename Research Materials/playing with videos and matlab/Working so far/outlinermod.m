% This will be a program to reterive the outline of each video it will
% first convert the video to grayscale, then to binary and then I will use
% a matlab function to find the outlines in each one.

% greymov = mov;

% first convert to greyscale
for frame = 2 : nFrames
    disp(['I am detecting motion for frame ', num2str(frame), ' of ', num2str(nFrames)])
    % iterate through the colomns
    greymov(1,frame).cdata = rgb2grey(motmov(1,frame).cdata);
end

playvideo(outmov,vidWidth,vidHeight,xyloObj)