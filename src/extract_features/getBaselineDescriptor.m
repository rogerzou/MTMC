function [mean_hsv] = getBaselineDescriptor(thisModel)

n_f = 50;
bins_hsv = [16 4 4];
%parts = [0 0.15 0.5 1];
parts = [0 0.15 0.5 1];

% compute bin centers
min_max_hsv = [0   1;    0   1;    0   1]; centers_hsv = cell(1, 3);
for i = 1 : 3, centers_hsv{i} = min_max_hsv(i, 1) + (min_max_hsv(i, 2)-min_max_hsv(i, 1))/bins_hsv(i)/2 : (min_max_hsv(i, 2)-min_max_hsv(i, 1))/bins_hsv(i) : min_max_hsv(i, 2); end
mean_hsv = zeros(1, sum(bins_hsv)*(numel(parts)-1));

% sanity check
if isempty(thisModel), return; end

% select subset of frames to average
select = round(linspace(1, numel(thisModel), n_f));

for i = select
    m = thisModel{i};
    
    img = loadImage(m.frame, m.camera);
    msk = loadMask(m.frame, m.camera);
    
    try
        img = img(m.bb(1):m.bb(2), m.bb(3):m.bb(4), :);
        msk = msk(m.bb(1):m.bb(2), m.bb(3):m.bb(4));
        % get hsv and lab images
        hsv__ = rgb2hsv(img);
        
        % split BB in 3 parts
        for j = 1 : numel(parts)-1
            hsv_ = hsv__(round(1+parts(j)*size(hsv__, 1)) : round(parts(j+1)*size(hsv__, 1)), :, :);
            msk_ = msk  (round(1+parts(j)*size(msk, 1))   : round(parts(j+1)*size(msk, 1)), :);
            
            % mask images
            h = hsv_(:,:,1); s = hsv_(:,:,2); v = hsv_(:,:,3);
            
            % from RGB to HSV
            hsv_hist = [hist(h(msk_==1), centers_hsv{1}) hist(s(msk_==1), centers_hsv{2}) hist(v(msk_==1), centers_hsv{3})];
            
            % smooth histograms
            hsv_hist = smoothHist(hsv_hist, bins_hsv);
            
            % add to the average histogram
            mean_hsv(1+(j-1)*sum(bins_hsv) : j*sum(bins_hsv)) = ...
                mean_hsv(1+(j-1)*sum(bins_hsv) : j*sum(bins_hsv)) + hsv_hist;
        end
    catch
    end
end

% normalization
for j = 1 : numel(parts)-1
    mean_hsv(1+(j-1)*sum(bins_hsv) : j*sum(bins_hsv)) = ...
        mean_hsv(1+(j-1)*sum(bins_hsv) : j*sum(bins_hsv)) ./ (eps+sum(mean_hsv(1+(j-1)*sum(bins_hsv) : j*sum(bins_hsv)))) / (numel(parts)-1);
end

end