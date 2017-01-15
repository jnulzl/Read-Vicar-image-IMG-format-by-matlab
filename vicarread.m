function [imgPixels,vicarProperty] = vicarread(imgName,scale)
%%��ȡvicarͼ��
%���룺
%   imgName:vicarͼ����������:"N1827817331_1.IMG"
%   scale:ͼ�����ű�������ΧΪ:[0,1]
%
%�����
%   imgPixels:2D��������Ϊuint16����uint8
%   vicarProperty:�ṹ�壬������vicarͼ��Labels�е��������

%����:
% [imgPixels,vicarProperty] = vicarread('N1827817331_1.IMG',0.5);
% imshow(imgPixels)

%�ο����ף�http://www-mipl.jpl.nasa.gov/external/VICAR_file_fmt.pdf
%����:������
%ʱ��:2016.11

if(1 == nargin)
    scale = 1;
end
    vicar = getLabels(imgName);
    vicarProperty = vicar;
    image_fd = fopen(imgName,'r');
    %���ļ���ʼ��������(vicar.LBLSIZE + vicar.NLB*vicar.RECSIZE)���ֽ�
    fseek(image_fd,vicar.LBLSIZE + vicar.NLB*vicar.RECSIZE,'bof');
    num_records = vicar.N2 * vicar.N3;%ÿ�е��ֽ���
    pixels = [];
    for i = 1:num_records
        fread(image_fd,vicar.NBB);
        if(strcmp('HALF',vicar.FORMAT))%��ʱ��ÿ������Ϊ�����ֽڣ���Ϊ�з����ͣ��ò����ʾ���Ҿ��д�С�˵�����
            pixel_data = fread(image_fd,vicar.N1,'int16',0,'b');
            pixel_data = pixel_data*32768*2/(4096.0);          
        elseif(strcmp('BYTE',vicar.FORMAT))%��ʱ��ÿ������Ϊһ���ֽڣ���Ϊ�޷�����(0~255)
            pixel_data = fread(image_fd,vicar.N1,'uint8',0,'b');
        end    
        pixels = [pixels;pixel_data'];
    end
    fclose(image_fd);

    if(strcmp('HALF',vicar.FORMAT))
        imgPixels = uint16(pixels);
    else
        imgPixels = uint8(pixels);
    end
    imgPixels = imresize(imgPixels,scale);
end


function metadata_dict = getLabels(imgName)
%     imgName: vicarͼ����������:"N1827817331_1.IMG"
% 
%     metadata_dict: VICARMetadata��ʵ��.

lblsize = getLBLSIZE(imgName);
metadata_fd = fopen(imgName,'r');
metadata = fread(metadata_fd,[1,lblsize],'*char');
has_lquote = false;
has_lparen = false;
tag_buf = [];
metadata_dict = struct();
for i = 1:length(metadata)
    ch = metadata(i);
    if(strcmp('''',ch))
        if(has_lquote && ~has_lparen)
            [tag,value] = strSplit(tag_buf,'=');
            tag = strtrim(tag);
            metadata_dict = setfield(metadata_dict,tag,value);
            has_lquote = false;
            has_lparen = false;
            tag_buf = [];
        else
            has_lquote = true;
        end
    elseif(strcmp('(',ch))
        has_lparen = true;
        tag_buf = [tag_buf,ch];
    elseif(strcmp(')',ch))     
        tag_buf = [tag_buf,ch];
        [tag,value] = strSplit(tag_buf,'=');   
        tag = strtrim(tag);
        metadata_dict = setfield(metadata_dict,tag,value);
        has_lquote = false;
        has_lparen = false;
        tag_buf = [];
    elseif(strcmp(' ',ch) && ~isempty(tag_buf) && ~(has_lquote || has_lparen))            
        [tag,value] = strSplit(tag_buf,'=');   
        tag = strtrim(tag);
        metadata_dict = setfield(metadata_dict,tag,value);
        has_lquote = false;
        has_lparen = false;
        tag_buf = [];
    elseif(strcmp(' ',ch))
        continue
    else
        tag_buf = [tag_buf,ch];
    end
end
fclose(metadata_fd);
end

function [tag,value] = strSplit(str,ch)
    %�����ַ�ch���ַ���str�ֳ�����

    id = strfind(str,ch);
    tag = str(1:id-1);
    value = str(id+1:end);
    if(~isnan(str2double(value)))
        value = str2double(value);
    end
end

function lblsize = getLBLSIZE(imgName)
%%��ȡvicarͼ��
%���룺
%   imgName:vicarͼ����������:"N1827817331_1.IMG"
%
%�����
%   lblsize:����������Ϊdouble

metadata_fd = fopen(imgName,'r');
fread(metadata_fd,8,'*char');
lblsize = [];
while(1)
    ch = fread(metadata_fd,1,'*char');
    if(strcmp(ch,' '))
        break
    else
        lblsize = [lblsize,ch];
    end
end
fclose(metadata_fd);
lblsize = str2double(lblsize);
end
