close all
clear all

obj = VideoReader('traffic.mp4');
averagedVid = zeros(obj.Height, obj.Width);
firstVid = zeros(obj.Height, obj.Width);
lastVid = zeros(obj.Height, obj.Width);

cnt = 1;
nframes = obj.NumberOfFrames;

for i = 1 : nframes
    video = rgb2gray(read(obj, i));
    if i == 1 
        firstVid = video;
    elseif i == nframes
        lastVid = video;
    end    
    averagedVid = uint8(  ((cnt - 1) / cnt) * double(averagedVid) + double(video) / cnt);
    cnt = cnt + 1;
end

ave = mean(mean(averagedVid));

firstVid = firstVid - averagedVid;
lastVid = lastVid - averagedVid;

for i = 1 : obj.Height
    for j = 1 : obj.Width
        if(firstVid(i,j) < 40)
            firstVid(i,j) = 0;
        end
    end
end

figH = figure;
subplot(3,2,1), imshow(averagedVid);
title('stationary objects');
subplot(3,2,2), imshow(firstVid);
title('moving objects in first frame');
subplot(3,2,3), imshow(lastVid);
title('moving objects in last frame');
print(figH, '-djpeg', 'motion.jpg');
