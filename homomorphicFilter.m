function [newImg] = homomorphicFilter(X,f_low,f_high,sigma)
% --------------------- 
% ���ߣ�ˮľ���� 
% ��Դ��CSDN 
% ԭ�ģ�https://blog.csdn.net/sinat_34035510/article/details/51337266 
% ��Ȩ����������Ϊ����ԭ�����£�ת���븽�ϲ������ӣ�


% f_high = 1.0;
% f_low = 0.8;
% sigma = 1.414

I = rgb2hsv(X);
H=I(:,:,1);
S=I(:,:,2);
V=I(:,:,3);

%?����һ����˹�˲���

% f_high = 1.0;
% f_low = 0.8;

%?�õ�һ����˹��ͨ�˲���
gauss_low_filter = fspecial('gaussian', [3 3], sigma);
matsize = size(gauss_low_filter);

%?����̬ͬ�˲���Ҫ�˳���Ƶ����,
%?���Եð������ͨ�˲���ת����һ����ͨ�˲���.
%?f_high?��?f_low?�ǿ��������ͨ�˲�����̬�Ĳ���.
gauss_high_filter = zeros(matsize);
gauss_high_filter(ceil(matsize(1,1)/2) , ceil(matsize(1,2)/2)) = 1.0;
gauss_high_filter = f_high*gauss_high_filter - (f_high-f_low)*gauss_low_filter;

%?���ö����任�������ͷ���ⲿ�ַֿ�
log_img = log(double(V)+eps);

%?����˹��ͨ�˲��������ת�����ͼ����
high_log_part = imfilter(log_img, gauss_high_filter, 'symmetric', 'conv');

%?���ڱ������ͼ���Ǿ��������任��,�����ݱ任��ͼ��ָ�����
high_part = exp(high_log_part);
minv = min(min(high_part));
maxv = max(max(high_part));

%?�õ��Ľ��ͼ��
temp=(high_part-minv)/(maxv-minv);
S=adapthisteq(S)*2.1;
HSV3(:,:,1)=H;%����H���䣬��ʼ�ϳ�
HSV3(:,:,2)=S;
HSV3(:,:,3)=temp;
rgb2=hsv2rgb(HSV3);%ת����RGB�ռ�

newImg = rgb2;

end
