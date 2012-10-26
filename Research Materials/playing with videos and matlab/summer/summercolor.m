% This program will make a second movie which tracks the motion (as far as
% changing pixles goesin the first movie

summov = mov;

% set some variables I will use
colormin = 320;

% iterate therough the frames 
for frame = 1 : nFrames
    disp(['I am detecting motion for frame ', num2str(frame), ' of ', num2str(nFrames)])
    % iterate through the colomns
    for height = 1 : vidHeight
        for width = 1 : vidWidth
            colortot = (...
                double(mov(1,frame).cdata(height,width,1)) +...
                double(mov(1,frame).cdata(height,width,2)) +...
                double(mov(1,frame).cdata(height,width,3))) ;

            if colormin <= colortot
                summov(1,frame).cdata(height,width,1) = 128;
                summov(1,frame).cdata(height,width,2) = 128;
                summov(1,frame).cdata(height,width,3) = 128;
            else
                summov(1,frame).cdata(height,width,1) = 1;
                summov(1,frame).cdata(height,width,2) = 1;
                summov(1,frame).cdata(height,width,3) = 1;
            end
        end
    end
end

% Play the video
% playvideo(motmov, vidWidth, vidHeight, xyloObj)





            