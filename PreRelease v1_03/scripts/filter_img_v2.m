%  DESCRIPTION:   Function written for NanoLocz: Localization Atomic Force Microscopy Analysis Platform
%  AUTHOR:        George Heath, University of Leeds,   g.r.heath@leeds.ac.uk,   30.06.2023         

function [r] = filter_img_v2(img, polyx, polyy, line_plane, imgt)
r = img;
if exist('imgt','var')
else
    imgt = img>-inf;
      
end
switch line_plane
    case 'plane'
%         imgt_2(imgt==0) = NaN;
%         imgt_2= imgt_2>0;
        xp = mean(imgt.*img,1,'omitnan');
        xf =  xp(~isnan(xp));
        xl =  1:numel(xp);
        xl =  xl(~isnan(xp));
        [p,~,mu] = polyfit(xl,xf,polyx);
        r = img - polyval(p,(1:numel(xp))',[],mu)';

        yp= mean(imgt.*r,2,'omitnan');
        yf =  yp(~isnan(yp));
        yl =  1:numel(yp);
        yl =  yl(~isnan(yp));
        [p,~,mu] = polyfit(yl,yf,polyy);
        r = r - polyval(p,(1:numel(yp))',[],mu);
    case 'line'
        if polyx>0
              % pos_m =  ~isnan(imgt);
              % level = median(pos_m.*img,'all');
            xl = 1:size(img,2);
            for i =1:size(img,1)
                pos = imgt(i,:)>0;
                if sum(pos)>polyx+5
                    y1 = img(i,pos);
                    x1 =  xl(pos);
                    [p,~,mu] = polyfit(x1,y1,polyx);
                    % if multilevel ==1
                    %     r(i,pos) = img(i,pos) - polyval(p,x1,[],mu)+mean(img(i,pos));
                    % else
                        r(i,:) = img(i,:) - polyval(p,1:size(img,2),[],mu);
                    % end
                else
                    r(i,pos) = img(i,pos);
                end
            end
            % if multilevel ==1
            %    %  pos_m =  isnan(imgt);
            %   %  level = median(pos_m.*img,'all');
            %     for i =1:size(img,1)
            %         pos =  isnan(imgt(i,:));
            % 
            %         if sum(pos)>polyx+5
            %             y1 = img(i,pos);
            %             x1 =  xl(pos);
            %             [p,~,mu] = polyfit(x1,y1,polyx);
            %             r(i,pos) = img(i,pos) - polyval(p,x1,[],mu) +mean(img(i,pos));
            %         else
            %             r(i,pos) = img(i,pos);
            %         end
            %     end
            % else
            % end

        end
        if polyy>0

            for i =1:size(img,2)
                yp = imgt(:,i).*r(:,i);
                yf =  yp(~isnan(yp));
                yl = (1:size(img,1));
                yl =  yl(~isnan(yp));
                if numel(yl)<polyy
                    r(i,:) = img(i,:);
                else
                    [p,~,mu] = polyfit(yl,yf,polyy);
                    r(:,i) = r(:,i) - polyval(p,(1:size(img,1))',[],mu);
                end
            end
        end
    case 'med_line'
        r = r - median(imgt.*r,2,'omitnan');
    case 'mean_plane'

        img = imgt.*r;
        r = r - mean(img(:),'omitnan');
end

end