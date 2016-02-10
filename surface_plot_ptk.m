%%% -----------------------------------------------------------------------
%%% This script will generate surface plot and output file for Origin
%%% Input           : textfile given in filename
%%% Input format    : col1(X values) col2(Y Values: repeating for each X)
%%%                 : col3(Z values)
%%% Example Data    : X  Y      Z
%%%                 : 1  1      11
%%%                 : 1  2      22
%%%                 : 2  1      33
%%%                 : 2  2      44
%%% Author: Bishwajit, May 2015. bdebn001@ucr.edu
%%%         Protik, Aug 2015. pdas001@ucr.edu
%%% Version: 1.2
%%% -----------------------------------------------------------------------

clearvars;
close;
clc;
% Delay time
td=0.15;
% Read data from existing file
filename='pi_integral.txt';
fid=fopen(filename,'r');

if (fopen(filename,'r')==-1)
    disp('Cannot open file. Check name and working directory.');
    disp(2,'Exiting script');
    pause(td);
    disp('-------------------------------------------------------');
    pause(td);
    return;
else
    fid=fopen(filename,'r');
    pause(td);
    disp('Opened data file successfully.')
    pause(td/2);
    disp('-------------------------------------------------------');
end

% Set Axis Label
x_label         = 'K (A^{-1})';
y_label         = '\theta (rad)';
z_label         = 'Integral of \pi(q)';

% If no axis label
if isempty(x_label)     x_label='X axis'; end
if isempty(y_label)     y_label='Y axis'; end
if isempty(z_label)     z_label='Z axis'; end

c = textscan(fid,'%f %f %f');
fclose(fid);

% Checking if it have 3 columns.
[sizeRow,sizeColumn]=size(c);

if (sizeColumn ~=3)
    pause(td);
    disp(['There should be 3 columns. Number of columns are' num2str(sizeColumn) '.']);
    pause(td);
    disp(2, 'Exiting script');
    disp('-------------------------------------------------------');
    return;
end
    

col1=c{1};
col2=c{2};
col3=c{3};

% if ~isnumeric(col1)
%     pause(td);
%     disp('First column is not numeric');
%     pause(td);
%     disp('Exiting script');
%     pause(td/2);
%     disp('-------------------------------------------------------');
%     return;
% elseif ~isnumeric(col2)
%     pause(td);
%     disp('Second column is not numeric');
%     pause(td);
%     disp('Exiting script');
%     pause(td/2);
%     disp('-------------------------------------------------------');
%     return;
% elseif ~isnumeric(col3)
%     pause(td);
%     disp('Third column is not numeric');
%     pause(td);
%     disp('Exiting script');
%     pause(td/2);
%     disp('-------------------------------------------------------');
%     return;
% end

for ii=1:length(col3)
    if isinf(col3(ii))
        pause(td);
        fprintf(2,'Warning: There are infinite values in f(x,y).\n');
        pause(td/2);
        disp('-------------------------------------------------------');
    end
end


% Checking if data columns are of equal length
if (isnan(col1(end)) || isnan(col2(end)) || isnan(col3(end)))
    pause(td);
    disp('Length of data columns are not equal.');
    pause(td);
%     disp(2, 'Exiting script...');
    pause(td/2);
    disp('-------------------------------------------------------');
    return;
end



% Number of Y points

if col1(1)==col1(2)
    pause(td);
    disp('Second column varying first');
    pause(td);
    disp('-------------------------------------------------------');
    
    numY = 0;
    for i=2:length(col1)
        numY = numY + 1;
        if(col2(i)==col2(1)) break; end;

    end
    % check
    if (col2(numY+1)==col2(2*numY+1) && col2(1)==col2(2*numY+1))
        pause(td);
        disp(['Periodicity found after ' num2str(numY) ' numbers of Y (same X)']);
        pause(td);
        disp(['1st Periodic element: ' num2str(col2(numY+1))]);
    else
        pause(td);
        disp('Periodicity can not be determined > Enter numY manually');
        pause(td);
        disp(2, 'Exiting script...');
        pause(td/2);
        disp('-------------------------------------------------------');
        return;
        % numY = 202;
    end
    pause(td/2);
    disp('-------------------------------------------------------');
    fprintf('Rearranging the matrix');
    pause(td/3);
    fprintf('.');
    pause(td/3);
    fprintf('.');
    pause(td/3);
    fprintf('.');
    pause(td/3);
    fprintf('.');
    pause(td/3);
    fprintf('.');
    
    y = col2(1:numY);
    count = 1;
    for i=1:numY:length(col1)
        x(count)    = col1(i);
        z(count,:)  = col3(i:numY+i-1)';
        count = count + 1;
    end

    pause(td);
    fprintf(' Done \n');
    disp('-------------------------------------------------------');
    pause(td);
    fprintf('### X-Y Grid: %d x %d ### \n', count-1, numY);
    
    flag=1;
    
elseif (col2(1)==col2(2))
    pause(td);
    disp('First column varying first');
    pause(td/2);
    disp('-------------------------------------------------------');
    numX = 0;
    for i=2:length(col1)
        numX = numX + 1;
        if(col1(i)==col1(1)) break; end;

    end
    % check
    if (col1(numX+1)==col1(2*numX+1) && col1(1)==col1(2*numX+1))
        pause(td);
        disp(['Periodicity found after ' num2str(numX) ' numbers of X (same Y)']);
        pause(td);
        disp(['1st Periodic element: ' num2str(col2(numX+1))]);
    else
        pause(td);
        disp('Periodicity can not be determined > Enter numX manually');
        pause(td);
        disp(2, 'Exiting script...');
        pause(td/2);
        disp('-------------------------------------------------------');
        return;
        % numY = 202;
    end
    pause(td/2)
    disp('-------------------------------------------------------');
    fprintf('Rearranging the matrix');
    pause(td/3);
    fprintf('.');
    pause(td/3);
    fprintf('.');
    pause(td/3);
    fprintf('.');
    pause(td/3);
    fprintf('.');
    pause(td/3);
    fprintf('.');
    
    x = col1(1:numX);
    count = 1;
    for i=1:numX:length(col2)
        y(count)    = col2(i);
        z(count,:)  = col3(i:numX+i-1)';
        count = count + 1;
    end

    pause(td);
    fprintf(' Done \n');
    disp('-------------------------------------------------------');
    fprintf('### X-Y Grid: %d x %d ### \n', numX, count-1);
    pause(td/2);
    disp('-------------------------------------------------------');
    
    flag=2;
    
else
    disp('None of the columns are varying');
    pause(td);
    disp(2, 'Exiting script');
    pause(td/2);
    disp('-------------------------------------------------------');
    return;
    
end

if flag==1
    fprintf('Plotting data....');
    mesh(y,x,z);
elseif flag==2
    fprintf('Plotting data....');
    mesh(x,y,z);
else
    return;
end

xlim=0.19;
ylim=xlim;
zlim=0.105;

% axis([-xlim xlim -ylim ylim]);
% axis([-xlim xlim -ylim ylim 0 zlim]);

% colormap hsv;
colorbar;


xlabel(y_label, 'FontSize',14);
ylabel(x_label, 'FontSize',14);
zlabel(z_label, 'FontSize',14);

if flag==1 || flag==2
    fprintf(' Done\n');
    disp('-------------------------------------------------------');
end