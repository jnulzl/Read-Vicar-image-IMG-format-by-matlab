function imgPixels = demo(imgName,vicar)
%%��ȡvicarͼ��
%���룺
%   imgName:vicarͼ����������:"N1827817331_1.IMG"
%   scale:ͼ�����ű�����
%
%�����
%   imgPixels:2D��������Ϊuint16����uint8

% if(2 == nargin)
%     scale = 1;
% end
%     vicar = process_metadata(imgName);
    image_fd = fopen(imgName,'r');
    %���ļ���ʼ��������(vicar.LBLSIZE + vicar.NLB*vicar.RECSIZE)���ֽ�
    fread(image_fd,vicar.LBLSIZE + vicar.NLB*vicar.RECSIZE);
%     fseek(image_fd,vicar.LBLSIZE + vicar.NLB*vicar.RECSIZE,'bof');
    num_records = vicar.N2 * vicar.N3;%ÿ�е��ֽ���
    pixels = [];
    for i = 1:num_records
        fread(image_fd,vicar.NBB);
        if(strcmp('HALF',vicar.FORMAT))%��ʱ��ÿ������Ϊ�����ֽڣ���Ϊ�з����ͣ��ò����ʾ���Ҿ��д�С�˵�����
            pixel_data = fread(image_fd,vicar.N1,'int16',0,'b');
    %         if(strcmp('HIGH',vicar.INTFMT))
    %             pixel_data = fread(image_fd,vicar.N1,'int16',0,'b');
    %         else
    %             pixel_data = fread(image_fd,vicar.N1,'int16',0,'l');
    %         end
            pixel_data = pixel_data*32768*2/(4096.0);          
        elseif(strcmp('BYTE',vicar.FORMAT))%��ʱ��ÿ������Ϊһ���ֽڣ���Ϊ�޷�����(0~255)
    %         if(strcmp('HIGH',vicar.INTFMT))
    %             pixel_data = fread(image_fd,vicar.N1,'uint8',0,'b');
    %         else
    %             pixel_data = fread(image_fd,vicar.N1,'uint8',0,'l');
    %         end
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
%     imgPixels = imresize(imgPixels,scale);
end
