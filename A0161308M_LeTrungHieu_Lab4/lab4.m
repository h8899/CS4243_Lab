close all
clear all

FNames = {'leaves_gray.jpg'; 'flower_pot_gray.jpg'; 'orchid_gray.jpg'}

num_photo = size(FNames);

for i = 1 : num_photo
   pic = imread(FNames{i});
   sz = size(pic);
   gx = zeros(sz(1), sz(2));
   gy = zeros(sz(1), sz(2));
   Ixx = zeros(sz(1), sz(2));
   Ixy = zeros(sz(1), sz(2));
   Iyy = zeros(sz(1), sz(2));
    
   for j = 1 : sz(1) 
       for k = 1 : sz(2)
           if(j == sz(1) || k == sz(2))
               gx(j, k) = 0;
           else    
               gx(j, k) = pic(j+1,k) - pic(j,k);
               gy(j, k) = pic(j,k+1) - pic(j,k);
           end
           Ixx(j, k) = gx(j,k) * gx(j,k);
           Iyy(j, k) = gy(j,k) * gy(j,k);
           Ixy(j, k) = gx(j,k) * gy(j,k);
       end
   end
   
   fullwin = 13;
   gkern = gausswin(fullwin) * gausswin(fullwin).';

   % convolution step. Each dimension of the output matrix will be
   % larger than the old dimension by 12 .   
   Wxx = conv2(Ixx, gkern);
   Wxy = conv2(Ixy, gkern);
   Wyy = conv2(Iyy, gkern);
   
   % calculate eigMin matrix
   eig_min = zeros(sz(1) + fullwin - 1, sz(2) + fullwin - 1);
   for j = 1 : sz(1) + fullwin - 1
       for k = 1 : sz(2) + fullwin - 1
            W = [Wxx(j, k) Wxy(j, k); Wxy(j, k) Wyy(j, k)];
            eig_min(j, k) = min(eig(W));
       end
   end
   
   % divide into mosaic of 13*13 regions
   for j = 1 : sz(1) + fullwin - 1
       row_len = min(13, sz(1) + fullwin - j);
       last_row = j + row_len - 1;
       for k = 1 : sz(2) + fullwin - 1
            col_len = min(13, sz(2) + fullwin - k);
            last_col = k + col_len - 1;
            current_mosaic = eig_min(j : last_row, k : last_col);
            local_max = max(current_mosaic(:));
            eig_min(j : last_row, k : last_col) = zeros(row_len, col_len);
            [r, c] = find(current_mosaic == local_max);
            eig_min(j + r - 1, k + c - 1) = local_max;
            k = last_col;
       end
       j = last_row;
   end
  
   % get the cut-off value to select top 200 eigmin values
   eig_size = (sz(1) + fullwin - 1) * (sz(2) + fullwin - 1);
   eig_arr = reshape(eig_min, [1, eig_size]);
   eig_arr = sort(eig_arr);
   cut_off = eig_arr(1, eig_size - 200);
   [r, c] = find(eig_min > cut_off);
   
   figH = figure;
   imshow(pic);
   
   % mapping these spotted corner pieces back to the original image
   r_sz = size(r);
   for j = 1 : r_sz(1)
       current_r = r(j,1) - 6;
       current_c = c(j,1) - 6;      
       if (current_r >= 1 && current_r <= sz(1) && current_c >= 1 && current_c <= sz(2))
           rectangle('position', [current_c, current_r, 1, 1], 'edgecolor', 'r');
       end
   end
   
    baseName = FNames{i}(1:find(FNames{i} =='.')-1);
    figName = strcat(baseName, '_corner_detected.jpg');
    
    print(figH, '-djpeg', figName);

    %{ 
	Answer for the essay question: Actually we do not miss the mentioned double summation,
	because it's what implicitly done when we apply the convolution step over our picture.
	Moreover, the reason why we use Gaussian filter instead of just a 0-1 mask matrix is to average out
	all pixels inside the window to reduce noise effects.
    %}
end    
