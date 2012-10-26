% This will be a program to outline all moving objects

outmov = motmov;

% iterate therough the frames 
for frame = 2 : nFrames
    disp(['I am outlining frame ', num2str(frame), ' of ', num2str(nFrames)])
    % iterate through the colomns
    for height = 1 : vidHeight
        for width = 1 : vidWidth
            if motmov(1,frame).cdata(height,width,1) ~= ...
                    motmov(1,frame-1).cdata(height,width,1)
                outmov(1,frame).cdata(height,width,1) = 1;
                outmov(1,frame).cdata(height,width,2) = 128;
                outmov(1,frame).cdata(height,width,3) = 1;
            end
        end
    end
end


% Play the video
% playvideo(outmov, vidWidth, vidHeight, xyloObj)




            