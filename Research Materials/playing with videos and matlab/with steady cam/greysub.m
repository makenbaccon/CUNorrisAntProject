


% first convert to greyscale
for frame = 2 : nFrames
    disp(['I am detecting motion for frame ', num2str(frame), ' of ', num2str(nFrames)])
    % iterate through the colomns
    greymov(1,frame).cdata = rgb2gray(mov(1,frame).cdata);
end

playvideo(greymov, vidWidth, vidHeight, xyloObj)

% use that nice little function
motmov = greymov;

for frame = 2 : nFrames
    disp(['I am detecting motion for frame ', num2str(frame), ' of ', num2str(nFrames)])
    % iterate through the colomns
    motmov(1,frame) = imabsdiff(greymov(1,frame),greymov(1,frame-1));
end


playvideo(motmov, vidWidth, vidHeight, xyloObj)





