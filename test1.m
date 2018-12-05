clear all;
close all;

for name = 1 : 20% for name = 2 : 2
% name = 10;//16
% for name = 16 : 16
figure(name)

filename = ['test' num2str(name)  '.jpg'];
% filename = [num2str(name)  '.bmp'];
img_rgb = imread(filename);
% rgb ת hsv �ռ�
img_hsv = rgb2hsv(img_rgb);

%****************** ��ȡ��ɫ ******************%
[height,width,c]= size(img_hsv);
for i=1:height
    for j=1:width
        h=img_hsv(i,j,1);
        s=img_hsv(i,j,2);
        v=img_hsv(i,j,3);
        %ͨ����hͨ����ɫֵ�ض���Χ�ڱ��Ͷ���Ϊ0��������Χ����ɫֵ
        if ( h > 156/180 || h < 10/180 ) && s > 43/255  && v > 46/255
%         if ( h > 156/180 || h < 10/180 ) && s > 60/255  && v > 60/255
            img_hsv(i,j,1) = 0;
            img_hsv(i,j,2) = 0;
            img_hsv(i,j,3) = 1;
        else 
            img_hsv(i,j,1) = 0;
            img_hsv(i,j,2) = 0;
            img_hsv(i,j,3) = 0;
        end
    end
end
img_red = hsv2rgb(img_hsv);

%****************** ��ֵ�� ******************%
level=graythresh(img_red);
% img_bw = img_red;
img_bw = im2bw(img_red,level);

% % subplot(221),imshow(img_rgb);
% % subplot(222),imshow(img_red)
% % subplot(223),imshow(img_bw);



%****************** ���ͺ���� ******************%
se_dilate_fill = strel('disk',3);
img_dilate = imdilate(img_bw,se_dilate_fill);
img_dilate_closed = bwfill(img_dilate,'holes');

%****************** ��ʴ�ؽ�������� ******************%
se_erode_restruct = strel('disk',5);
img_bw_eroded = imerode(img_dilate_closed,se_erode_restruct);
img_eroded_restruct = imreconstruct(img_bw_eroded,img_dilate_closed);
img_eroded_restruct_fill = bwfill(img_eroded_restruct,'holes');

%****************** ������ ******************%
se_open = strel('disk',10);
img_eroded_restruct_fill_open = imopen(img_eroded_restruct_fill,se_open);

% % subplot(221),imshow(img_rgb);
% % subplot(222),imshow(img_red)
% % subplot(223),imshow(img_eroded_restruct_fill_open);

% %****************** ���������Ϣ�ٸ�ʴ ******************%
region = regionprops(bwlabel(img_eroded_restruct_fill_open),'Area','Perimeter','Centroid','Boundingbox');

%%% ����Ӧ����ṹԪ��

%%% ȡǰ��������Բ��������ƽ�����
CIRCLESIMLIAR = 0.6;
WEIGHTMINCOMPUTERATE = 0.2;
RADIUSRATE = 2/3;

Circle_simliarity_result = zeros(1,size(region,1));
maxarea = 0;

for i = 1 : size(region,1)
    
    circle_simliarity = 4*pi*region(i).Area/(region(i).Perimeter^2);    
    Circle_simliarity_result(1,i) = circle_simliarity;
    
    if region(i).Area > maxarea
        maxarea = region(i).Area;
    end
    
end

[Circle_simliarity,Circle_simliarity_index] = sort(-Circle_simliarity_result);


area = 0;i  = 0;
for i = 1 : size(region,1)
%     if i > maxcount || -Circle_simliarity(i) < CIRCLESIMLIAR
%     if -Circle_simliarity(i) < CIRCLESIMLIAR || region( Circle_simliarity_index(i)  ).Area/maxarea < WEIGHTMINCOMPUTERATE
    if -Circle_simliarity(i) < CIRCLESIMLIAR && region( Circle_simliarity_index(i)  ).Area/maxarea > WEIGHTMINCOMPUTERATE
        break;
    end
    area = area + region( Circle_simliarity_index(i)  ).Area;
end

radius = floor(sqrt( area/i/pi  ) * RADIUSRATE );   
se_better_erode = strel('disk',radius);
img_better_eroded = imerode(img_eroded_restruct_fill_open,se_better_erode);
img_better_eroded_restruct = imreconstruct(img_better_eroded,img_eroded_restruct_fill_open);


% subplot(221),imshow(img_rgb);
% subplot(222),imshow(img_eroded_restruct_fill_open)
% subplot(223),imshow(img_better_eroded_restruct);
% 
% % %****************** ��ȡĿ������ ******************%
CIRCLEWEIGHT = 0.7;
CIRCLESIMILARITYTHRESHOLD = 0.9;
AREAWEIGHTTHRESHOLD = 0.2;
WEIGHTTHRESHOLD = 0.7;

[region,result] = detectTarget(img_better_eroded_restruct,CIRCLEWEIGHT,CIRCLESIMILARITYTHRESHOLD,AREAWEIGHTTHRESHOLD);
[target_num,Target_index] = drawTarget(img_rgb,region,result,WEIGHTTHRESHOLD);

% subplot(221),imshow(img_rgb);
% subplot(222),imshow(img_eroded_restruct_fill_open)
% subplot(223),imshow(img_better_eroded_restruct);

% % % �궨����
for i = 1 : target_num
    tmpimg = img_rgb;

    rectanglesize = region(Target_index(i)).BoundingBox;
        
    [height,width,c]= size(img_hsv);
    for m = 1 : height
        for n = 1 : width
            if ( ~( n > rectanglesize(1) && n < rectanglesize(1)+rectanglesize(3) && m > rectanglesize(2) && m < rectanglesize(2) + rectanglesize(4)) ...
                || img_better_eroded_restruct(m,n) == 0  || img_bw(m,n) ) 
               tmpimg(m,n,:) = [255 255 255];               
            end
        end
    end
    tmpimg = tmpimg(rectanglesize(2) : rectanglesize(2) + rectanglesize(4) ,rectanglesize(1):rectanglesize(1)+rectanglesize(3) );  

    len = rectanglesize(3)+rectanglesize(4);
    
    %%% ˫����ֵ�ָ�
    h = imhist(tmpimg);
    % �󼫴�ֵ ���Ե�����һ�� 
    [cnt,x] = findpeaks(h,'minpeakdistance',40,'minpeakheight',20);
    
    if cnt > 2
        n = length(x);
        yu = x(1)+x(n)-2;
        img_num_bw = ~im2bw(tmpimg,yu/510);
    else
%         level = graythresh(tmpimg);
%         img_num_bw = ~im2bw(tmpimg,level);
        
%         subplot(221),imhist(tmpimg);
%         subplot(222),imshow(img_num_bw)
%         subplot(223),imshow(sep_2)
        continue
    end
        
    
    se_sep = strel('rectangle',[1,min(15,floor(len/20))] );
    sep_1 = imerode(img_num_bw,se_sep);
    sep_2 = imreconstruct(sep_1,img_num_bw);
    
    sep_region = regionprops(bwlabel(sep_2),'Area','Perimeter','Centroid','Boundingbox');
    
    for k = 1 : size(sep_region)
        subplot(224)
        rectangle('Position',sep_region(k).BoundingBox + [rectanglesize(1) rectanglesize(2) 0 0],'Curvature',[0,0],'LineWidth',2 ,'LineStyle','-','EdgeColor','r');
        hold on
        subplot(221),imhist(tmpimg);
        subplot(222),imshow(img_num_bw)
        subplot(223),imshow(sep_2)
    
    end
% %     sep_2 = bwfill(sep_2,'holes');


end

if target_num > 0 || maxarea == 0
    continue;
end

% û����Ŀ��,�����ڿ���Ŀ��飬��ΪĿ�����λ��������
% 
% %****************** ��ȡ���ɫ�� ******************%

[Area,Area_index]=sort(-[region.Area]);
maxarea = 0;
if size(region,1) > 1
    maxarea = -Area(1);
end

rectanglesize = region(Area_index(1)).BoundingBox;
[height,width,c]= size(img_hsv);
for i=1:height
    for j=1:width
        if ~( j > rectanglesize(1) && j < rectanglesize(1)+rectanglesize(3) && i > rectanglesize(2) && i < rectanglesize(2) + rectanglesize(4))
            img_bw(i,j) = 0;
        end
    end
end


img_bigest_eroded = imerode(img_bw,se_better_erode);
img_bigest_eroded_restruct = imreconstruct(img_bigest_eroded,img_bw);

img_dilate = imdilate(img_bw,se_better_erode);
img_bigest_eroded_restruct_fill = bwfill(img_bigest_eroded_restruct,'holes');

% subplot(224),imshow(img_red);
% subplot(224),imshow(img_bigest_eroded_restruct_fill);
% subplot(221),imshow(img_bw);


% %****************** ��ȡĿ������ ******************%
CIRCLEWEIGHT = 0.7;
CIRCLESIMILARITYTHRESHOLD = 0.1;
AREAWEIGHTTHRESHOLD = 0.2;
WEIGHTTHRESHOLD = 0.5;
[region,result] = detectTarget(img_bigest_eroded_restruct_fill,CIRCLEWEIGHT,CIRCLESIMILARITYTHRESHOLD,AREAWEIGHTTHRESHOLD);
[target_num,index] = drawTarget(img_rgb,region,result,WEIGHTTHRESHOLD);   

end

