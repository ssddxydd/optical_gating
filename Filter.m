1

fprintf('This program allows you to filter an arbitrary signal and displays the output\n');
option = 0;
while option == 0
    clear;
    option = 0;
    num = input('Enter SDF number: ');
    filename = strcat(num2str(num,'%04.f'),'.sdf');

    data = GetDataSDF(filename);
    x = data.Grid.Grid.x;

    xmin = x(1);
    xmax = x(length(x));
    range = abs(xmax-xmin);
    lambda = 1e-6;


exit = 0;
    
    while exit == 0
        
        fprintf('Choose component to transform. Options given below\n\n');
    
        fprintf('------------------------------\n');
        fprintf('| 1 - ex | 2 - ey | 3 - ez |\n');
        fprintf('------------------------------\n\n');
        c = input('Enter component: ');
        switch c
            case 1
                fprintf('\n\n............Transforming Ex............\n');
                F = data.Electric_Field.Ex.data;
            
                nfft = length(F);
                exit = 1;
            case 2
                fprintf('\n\n............Transforming Ey............\n');
                F = data.Electric_Field.Ey.data;
            
                nfft = length(F);
                exit = 1;
            case 3
            fprintf('\n\n............Transforming Ez............\n');
                F = data.Electric_Field.Ez.data;
            
                nfft = length(F);
                exit = 1;
            otherwise 
                exit = 0;
        end
    end %prompt user to select component to display

    grid = length(x);
    G = F;


    if (grid~=nfft) %check for equal length delete last point
        x(length(x)) = [];
        grid = length(x);
    end
    Fs = grid/range;

    Y = fft(F,nfft); %transforming signal
    Y = Y(1:nfft/2); %cut off negative frequencies

    T(1:nfft/2) = 0; 
    k =lambda*(0:nfft/2-1)*Fs/nfft; %derive axis of transform


    fprintf('How would you like to filter the transform?\n');
    fprintf('Currently available options are as follows. \n');
    
   exit = 0;
    while exit==0
        
        fprintf('------------------------------\n');
        fprintf('| 1 - Square filter | 2 - Gaussian| 3 - Filter n harmonics |\n ');
        fprintf('------------------------------\n');
        c = input('Enter your choice: ');
        if (c==1)||(c==2)||(c==3)
            exit = 1;
        end
    end %prompt user to select filter type

    exit = 0;


    fprintf('Choose the center position of the filter and the width. \n');
    fprintf('For the gaussian filter the width is the sigma value of a normal dist.\n\n');
    fprintf('Values must be within %g and %g \n',k(1),k(end));
    if c==3
        width = 0;
        fprintf('This option filters the first n harmonic modes\n');
        center = input('Enter n: ');
    else
        width = input('Enter the width of the filter: ');
        fprintf('\n');
        center = input('Enter the center of the filter: ');
    end
    
    
    filt(1:nfft/2) = 0; 
    
    

    switch c %filter setup
            case 1
                for i = 1:(nfft/2) 
                    if k(i)>(center-width/2) && k(i)<(center+width/2)
                        filt(i) = 1;
                    else 
                        filt(i) = 0; 
                    end
               
                end
            case 2
                filt = normpdf(k,center,width);
            case 3
                for i = 1:(nfft/2)
                    if k(i)< center
                        filt(i)=0;
                    else
                        filt(i)=1;
                    end
                end      
        otherwise
                fprintf('Error in filter setup');
    end
    
    for i = 1:(nfft/2)
        T(i) = Y(i)*filt(i); %apply filter to all values in the transform 
    end

  
 
    figure(1);
    
    subplot(2,2,1) % 
    plot(k,filt);
    title('Filter');
    xlabel('Harmonic Order'); ylabel('Scale Factor'); 
    
    subplot(2,2,2)
    plot(k,abs(Y));
    title('Original Transform'); 
    xlabel('Harmonic Order'); ylabel('Intensity');
    
    subplot(2,2,3)
    plot(k,abs(T));
    title('Filtered Transform') ;
    xlabel('Harmonic Order'); ylabel('Intensity');
    
    subplot(2,2,4)
    plot(x,G);
    title('Electric Field') ;
    xlabel('Position'); ylabel('E');

    fprintf('\nPerforming inverse\n');
    
    %flip the filtered transform and join it with itself
    L = conj(T);
    L = flip(L);
    S = [T,L];
    I = real(ifft(S));
    figure(2);
    plot(x,I);
    title('Filtered Pulse');
    xlabel('Position');ylabel('Electric Field');
    
    
    exit = 0;
    while exit==0
        
        fprintf('------------------------------\n');
        fprintf('| 1 - New Transform | 2 - Quit|\n ');
        fprintf('------------------------------\n');
        
        switch c
            case 1   
                option = 0;
                exit=1;
            case 2
                return;
            otherwise
                exit = 0;
        end
    end
end


fclose('all');
