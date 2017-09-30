close all
clear all

FNames = {'leaves_gray.jpg'; 'flower_pot_gray.jpg'; 'orchid_gray.jpg'}

num_photo = size(FNames);

for i = 1 : num_photo
    pic = imread(FNames{i});
    sz = size(pic);
    hPic = zeros(sz(1), sz(2));
    h_before = zeros(1, 256);
    h_after = zeros(1, 256);
    
    for j = 1 : sz(1) 
        for k = 1 : sz(2)
            val = pic(j, k);
            h_before(val+1) = h_before(val+1) + 1;
        end
    end
    
    for j = 1 : sz(1)
        for k = 1 : sz(2)
            val = pic(j, k);
            if (val < 10) 
                hPic(j, k) = 0;
                h_after(1) = h_after(1) + 1;
            elseif (val > 150)
                hPic(j, k) = 255;
                h_after(256) = h_after(256) + 1;
            else
                newVal = round( (double(val) - 10) * 255 / 140);
                hPic(j, k) = newVal;
                h_after(newVal+1) = h_after(newVal+1) + 1;
            end
        end
    end
    
 
    figH = figure;
    subplot(3,2,1), imshow(pic,[0 255]);
    title('original image');
    subplot(3,2,2), imshow(hPic, [0 255]);
    title('stretched image');
    subplot(3,2,3), plot(h_before);
    title('original histogram');
    subplot(3,2,4), plot(h_after);
    title('contrasted histogram');
    
    baseName = FNames{i}(1:find(FNames{i} =='.')-1);
    figName = strcat(baseName, '_stretch.jpg');
    
    print(figH, '-djpeg', figName);
    
    
    
    pic = double(pic);
    hPic = zeros(sz(1) - 2, sz(2) - 2);
    
    sobel_x = [-1 -2 -1; 0 0 0; 1 2 1];
    sobel_y = [ -1 0 1; -2 0 2; -1 0 1];
    
    for j = 1 : sz(1) - 2
        for k = 1 : sz(2) - 2
            mat = [pic(j, k) pic(j, k+1) pic(j, k+2);
                   pic(j+1, k) pic(j+1, k+1) pic(j+1, k+2);
                   pic(j+2, k) pic(j+2, k+1) pic(j+2, k+2)];
            hori = sum(sum(sobel_x .* mat));
            verti = sum(sum(sobel_y .* mat));
            hPic(j, k) = sqrt(hori*hori + verti*verti);
        end
    end
    
    figH = figure;
    subplot(3,2,1), imshow(pic,[0 255]);
    title('original image');
    subplot(3,2,2), imagesc(hPic);
    title('edge-detected image');
    
    baseName = FNames{i}(1:find(FNames{i} =='.')-1);
    figName = strcat(baseName, '_edge_detected.jpg');
    
    print(figH, '-djpeg', figName);
end

