clear all;
clc;

load('anecoicCystData.mat');

data = veraStrct.data;
fs = 20e6;
speed = 1540; %m/s in body
pixel_size_through_depth = 0.5*(speed/fs); 

for ii = 1:max(size(data))
    time_array_all(ii) = ii/fs;
end

for cc = 1:128
for bb = 1:128
    time_array(:,bb,cc) = time_array_all;
end
end

channel = [[-63.5:1:63.5]];

for beam = 1:128
    
for jj = 1:max(size(data)) %jj=row
    
depth = jj*pixel_size_through_depth; %m

data_matrix = data;
[rows_data_matrix col_data_matrix z_data_matrix] = size(data_matrix);

for ii = 1:(length(channel))
    xe(ii) = 0.1953e-3*abs(channel(ii)); 
    lateral_array(ii) = 0.1953e-3*channel(ii);
    d(ii) = (xe(ii)^2+depth^2)^0.5 + depth;
    time_to_point(ii) = d(ii)/speed;
end

delay_matrix(jj,:,beam) = time_to_point; %delays

end

for aa = 1:128
    delayed_channel(1:rows_data_matrix,aa,beam) = interp1(time_array(1:rows_data_matrix,aa,beam),data_matrix(1:rows_data_matrix,aa,beam),delay_matrix(1:rows_data_matrix,aa,beam),'linear');
end


end
axial_array = [1:rows_data_matrix]*pixel_size_through_depth;


for ll = 1:numel(delayed_channel)
    if isnan(delayed_channel(ll))==1
        delayed_channel(ll) = 0;
    end
end


%rectangular window

[num_rows num_col num_beams] = size(delayed_channel);

rect_win = rectwin(128);
rect_win = rect_win';
apod_rect = repmat(rect_win, [num_rows, 1, num_beams]);
data_rect = delayed_channel.*apod_rect;
summed_channels = sum(data_rect,2);
log_compressed_rect = 20*log10(abs(hilbert(summed_channels(:,:))));
figure;
imagesc(lateral_array, axial_array,log_compressed_rect,[30 80]);
axis image;
colormap('gray');
title('Rectangular aperture');

%blackman window
blackman_win = blackman(128);
blackman_win = blackman_win';
apod_blackman = repmat(blackman_win, [num_rows, 1, num_beams]);
data_blackman = delayed_channel.*apod_blackman;
summed_channels_bl = sum(data_blackman,2);
log_compressed_bl = 20*log10(abs(hilbert(summed_channels_bl(:,:))));
figure;
imagesc(lateral_array, axial_array,log_compressed_bl,[30 80]);
axis image;
colormap('gray');
title('Blackman window');

%window
k_win = kaiser(128);
k_win = k_win';
apod_k = repmat(k_win, [num_rows, 1, num_beams]);
data_k = delayed_channel.*apod_k;
summed_channels_k = sum(data_k,2);
log_compressed_k = 20*log10(abs(hilbert(summed_channels_k(:,:))));
figure;
imagesc(lateral_array, axial_array,log_compressed_k,[30 80]);
axis image;
colormap('gray');
title('Kaiser window');


%part b
figure;
mask_lesion = roipoly(log_compressed_rect);
mask_background = roipoly(log_compressed_rect);

%rect
lesion_rect = mask_lesion.*log_compressed_rect;
background_rect = mask_background.*log_compressed_rect;
mean_lesion_rect = mean(mean(lesion_rect));
mean_background_rect = mean(mean(background_rect));
var_lesion_rect = var(lesion_rect(:));
var_background_rect = var(background_rect(:));
contrast_rect = -20*log10(mean_lesion_rect/mean_background_rect)
CNR_rect = abs(mean_lesion_rect-mean_background_rect)/...
    (var_lesion_rect^2+var_background_rect^2)^0.5

%blackman
lesion_bl = mask_lesion.*log_compressed_bl;
background_bl = mask_background.*log_compressed_bl;
mean_lesion_bl = mean(mean(lesion_bl));
mean_background_bl = mean(mean(background_bl));
var_lesion_bl = var(lesion_bl(:));
var_background_bl = var(background_bl(:));
contrast_bl = -20*log10(mean_lesion_bl/mean_background_bl)
CNR_bl = abs(mean_lesion_bl-mean_background_bl)/...
    (var_lesion_bl^2+var_background_bl^2)^0.5

%kaiser
lesion_k = mask_lesion.*log_compressed_k;
background_k = mask_background.*log_compressed_k;
mean_lesion_k = mean(mean(lesion_k));
mean_background_k = mean(mean(background_k));
var_lesion_k = var(lesion_k(:));
var_background_k = var(background_k(:));
contrast_k = -20*log10(mean_lesion_k/mean_background_k)
CNR_k = abs(mean_lesion_k-mean_background_k)/...
    (var_lesion_k^2+var_background_k^2)^0.5