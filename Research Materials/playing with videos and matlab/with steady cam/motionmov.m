% This program will make a second movie which tracks the motion (as far as
% changing pixles goesin the first movie

motmov = mov;

% set some variables I will use
coloreuclid = 4;

% iterate therough the frames 
for frame = 2 : nFrames
    disp(['I am detecting motion for frame ', num2str(frame), ' of ', num2str(nFrames)])
    % iterate through the colomns
    for height = 1 : vidHeight
        for width = 1 : vidWidth
            colordist = sqrt(...
                (double(mov(1,frame).cdata(height,width,1)) +...
                double(mov(1,frame-1).cdata(height,width,1)))^2 +...
                (double(mov(1,frame).cdata(height,width,2)) +...
                double(mov(1,frame-1).cdata(height,width,2)))^2 +...
                (double(mov(1,frame).cdata(height,width,2)) +...
                double(mov(1,frame-1).cdata(height,width,2)))^2);
            if colordist < coloreuclid
                motmov(1,frame).cdata(height,width,1) = 128;
                motmov(1,frame).cdata(height,width,2) = 128;
                motmov(1,frame).cdata(height,width,3) = 128;
            else
                motmov(1,frame).cdata(height,width,1) = 1;
                motmov(1,frame).cdata(height,width,2) = 1;
                motmov(1,frame).cdata(height,width,3) = 1;
            end
        end
    end
end

% Play the video
% playvideo(motmov, vidWidth, vidHeight, xyloObj)





            