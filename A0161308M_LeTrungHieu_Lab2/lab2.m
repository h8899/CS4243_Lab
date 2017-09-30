close all
clear all

FNames = {'leaves_gray.jpg'; 'flower_pot_gray.jpg'; 'orchid_gray.jpg'};

num_photo = size(FNames);

for i = 1 : num_photo
    photo = FNames{i};
    pic = imread(photo);
    sz = size(pic);
    hPic = zeros(sz(1), sz(2));
    h_before = zeros(1, 257);
    h_after = zeros(1, 257);
    c_before = zeros(1, 257);
    c_after = zeros(1, 257);
    
    for j = 1 : sz(1)
        for k = 1 : sz(2)
            val = pic(j, k);
            h_before(val+1) = h_before(val+1) + 1;      
        end
    end
    
    c_before(1) = h_before(1); 
    
    for j = 2 : 257
        c_before(j) = c_before(j - 1) + h_before(j); 
    end    
        
    population_size = sz(1) * sz(2);
    
    for j = 1 : sz(1)
        for k = 1 : sz(2)
            val = pic(j, k);
            hPic(j, k) = round(c_before(val + 1) / population_size * 255);
            newVal = hPic(j, k);
            h_after(newVal + 1) = h_after(newVal + 1) + 1;
        end    
    end
    
    c_after(1) = h_after(1); 
    
    for j = 2 : 257
        c_after(j) = c_after(j - 1) + h_after(j); 
    end 
    
    figH = figure;
    subplot(3,2,1), imshow(pic,[0 255]);
    title('original image');
    subplot(3,2,2), imshow(hPic, [0 255]);
    title('hist equalized image');
    subplot(3,2,3), plot(h_before);
    title('original histogram');
    subplot(3,2,4), plot(h_after);
    title('equalized hist');
    subplot(3,2,5), plot(c_before);
    title('original cumu hist');
    subplot(3,2,6), plot(c_after);
    title('equalized cumu hist');
    
    baseName = FNames{i}(1:find(FNames{i}=='.')-1);
    figName = strcat(baseName, '_histogram_eq_results.jpg');
    
    print(figH,'-djpeg',figName);
end

