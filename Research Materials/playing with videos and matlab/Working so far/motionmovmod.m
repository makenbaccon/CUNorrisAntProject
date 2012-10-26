% This program will try to speed up the motion detection process by using
% the built in functions in matlab (if I figure out how to use them...)

motmov = mov;

for frame = 2 : nFrames
    disp(['I am detecting motion for frame ', num2str(frame), ' of ', num2str(nFrames)])
    % iterate through the colomns
    motmov(1,frame).cdata = imabsdiff(mov(1,frame).cdata,mov(1,frame-1).cdata);
end



