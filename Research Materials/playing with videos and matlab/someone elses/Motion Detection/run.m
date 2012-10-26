clear data
disp('input video');


avi = mmreader('samplevideo.avi');
video = {avi.cdata};
for a = 1:length(video)
    imagesc(video{a});
    axis image off
    drawnow;
end;
disp('output video');
tracking(video);
