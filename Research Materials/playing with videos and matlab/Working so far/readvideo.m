xyloObj = VideoReader('experiment.avi');

nFrames = xyloObj.NumberOfFrames;
vidHeight = xyloObj.Height;
vidWidth = xyloObj.Width;
% 
% % Preallocate movie structure.
% mov(1:nFrames) = ...
%     struct('cdata', zeros(vidHeight, vidWidth, 3, 'uint8'),...
%            'colormap', []);

       
% Preallocate movie structure.
mov(1:nFrames) = ...
    struct('cdata', zeros(vidHeight, vidWidth, 3),...
           'colormap', []);       
       
% Read one frame at a time.
parfor k = 1 : nFrames
    mov(k).cdata = read(xyloObj, k);
    clc
    disp(['I have read ', num2str(k), ' of ', num2str(nFrames), 'Frames.'])
end

% Play the video
% playvideo(mov, vidWidth, vidHeight, xyloObj)