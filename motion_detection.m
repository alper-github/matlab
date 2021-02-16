%-------------------------------------------------------------------------
%-----------------------------IMPORT PART---------------------------------
%-------------------------------------------------------------------------
%defining input object
vidobj = videoinput('winvideo');
%getting video resolution from the input object to create empty space live
%video display
vidRes = vidobj.VideoResolution;
%creating the figure which is the interface to observe and command on
f = figure('Name', 'Motion Detection', 'Visible', 'off');
%changing [1280,720] to [720,1280] because frames obtained from the
%camera are arrays as large as (720,1280,3)
imageRes = fliplr(vidRes);
%creating empty space for live video display
subplot(2,4,1);
    %displaying the empty space
	emptyspace = imshow(zeros(imageRes));
	axis image;
%previewing live video displayed on empty space
preview(vidobj, emptyspace);
%starting output video
CroppedVideo = VideoWriter('CroppedVideo.avi');
open(CroppedVideo)

timer = 0;
%loop to get frames processed, classified, and export required ones
while timer < 917
    RawFrameOne = getsnapshot(vidobj);
    pause(0.01); %in seconds
    RawFrameTwo = getsnapshot(vidobj);
%-------------------------------------------------------------------------
%-----------------------------PROCESS PART--------------------------------
%-------------------------------------------------------------------------

%for frame 1--------------------------------------------------------------
    %turning RGB frame to grayscale
	gsFrameOne = im2gray(RawFrameOne);
    %adjusting grayscale frame to partly prevent dragging of histogram
    %that occurs when camera adjusts brightness anytime it is needed
	gsAdjFrameOne = imadjust(gsFrameOne);
    %plotting histogram of the adjusted grayscale frame
	subplot(2,4,2);
	imhist(gsAdjFrameOne, 256);
    %getting values from the histogram to process
	[counts, binLocations] = imhist(gsAdjFrameOne, 256);
        %deleting 0s in counts to prevent false local maxima minima values
        %and get more stable array to be processed in the gaussian filter
        for i = 1:255
            j = i + 1;
            if counts(i) == 0
                counts(i) = counts(j);
            end
        end
    
    %gaussian filter
	gaussFilter = gausswin(55);
	gaussFilter = gaussFilter / sum(gaussFilter);
	%convolution of gaussian filter and counts gives low-pass filtered
	%counts values
	oversizedcounts = conv(gaussFilter,counts);
        %cropping oversizedcounts array to plot it against binLocations
        counts = oversizedcounts(1:256);
    
    %plotting gaussian filtered counts
	subplot(2,4,3);
	plot(binLocations, counts);
        %keeping the plot to overwrite local minima maxima values on it
        hold on
    
    %finding local maxima values
	[maxPeaks,maxLocs] = findpeaks(counts);
    
    %obtaining indexes of local minima values which are indexes of local 
    %maxima values of -counts and extracting local minima values from
    %counts by using their obtained indexes
	[minPeaksbutFalse,minLocs] = findpeaks(-counts);
	minPeaks = counts(minLocs);
    
    %plotting local maxima and minima values with asterisks over already
    %plotted gaussian filtered counts
	plot(maxLocs,maxPeaks,"b*",minLocs,minPeaks,"r*");
        
    %thresholds for display in figure
	plot(maxLocs,maxPeaks-100,"b_",minLocs,minPeaks-100,"r_");
	plot(maxLocs,maxPeaks+100,"b_",minLocs,minPeaks+100,"r_");    
	hold off
    
%for frame 2--------------------------------------------------------------
    %turning RGB frame to grayscale
	gsFrameTwo = im2gray(RawFrameTwo);
    %adjusting grayscale frame to partly prevent dragging of histogram
    %that occurs when camera adjusts brightness anytime it is needed
	gsAdjFrameTwo = imadjust(gsFrameTwo);
    %plotting histogram of the adjusted grayscale frame
	subplot(2,4,6);
	imhist(gsAdjFrameTwo, 256);
    %getting values from the histogram to process
	[countstwo, binLocationstwo] = imhist(gsAdjFrameTwo, 256);
        %deleting 0s in counts to prevent false local maxima minima values
        %and get more stable array to be processed in the gaussian filter
        for i = 1:255
        	j = i + 1;
            if countstwo(i) == 0
                countstwo(i) = countstwo(j);
            end
        end
    
    %gaussian filter
    %convolution of gaussian filter and counts gives low-pass filtered
	%counts values
    oversizedcountstwo = conv(gaussFilter,countstwo);
        %cropping oversizedcounts array to plot it against binLocations
        countstwo = oversizedcountstwo(1:256);
    
    %plotting gaussian filtered counts
    subplot(2,4,7);
    plot(binLocationstwo, countstwo);
        %keeping the plot to overwrite local minima maxima values on it
        hold on
    
    %finding local maxima values
    [maxPeakstwo,maxLocstwo] = findpeaks(countstwo);
    
    %obtaining indexes of local minima values which are indexes of local 
    %maxima values of -counts and extracting local minima values from
    %counts by using their obtained indexes
    [minPeaksbutFalsetwo,minLocstwo] = findpeaks(-countstwo);
    minPeakstwo = countstwo(minLocstwo);
    
    %plotting local maxima and minima values with asterisks over already
    %plotted gaussian filtered counts
        plot(maxLocstwo,maxPeakstwo,"b*",minLocstwo,minPeakstwo,"r*");
        
    %thresholds for display in figure
    plot(maxLocstwo,maxPeakstwo-100,"b_",minLocstwo,minPeakstwo-100,"r_");
    plot(maxLocstwo,maxPeakstwo+100,"b_",minLocstwo,minPeakstwo+100,"r_");
    hold off
%-------------------------------------------------------------------------
%-----------------------------CLASSIFY PART-------------------------------
%-------------------------------------------------------------------------
    %limiting indexmax values by choosing the lower one
    smx1 = size(maxLocs);
    smx2 = size(maxLocstwo);
    if smx1(1) < smx2(1)
        indexmax = smx1(1);
    else
        indexmax = smx2(1);
    end
    
    %limiting indexmin values by choosing the lower ones
    smn1 = size(minLocs);
    smn2 = size(minLocstwo);
    if smn1(1) < smn2(1)
        indexmin = smn1(1);
    else
        indexmin = smn2(1);
    end
    
    %=-=-=-=-=-=-=-=-here is where classification is done=-=-=-=-=-=-=-=-
    %taking absoulte value of difference between nth local maxima values
    %in both frames
    %taking absoulte value of difference between nth local minima values
    %in both frames
    %if any of those absolute values are more than threshold, it is decided
    %that there is a motion and both first frame and second frame obtained
    %in the current while loop are written in output video
    flag = 0;
    for a = 1:indexmax
        for b = 1:indexmin
        	localMaxDifference = abs(maxPeakstwo(a) - maxPeaks(a));
        	localMinDifference = abs(minPeakstwo(b) - minPeaks(b));
            	if localMaxDifference > 100 || localMinDifference > 100
                	motion = 1;
                    writeVideo(CroppedVideo,RawFrameOne)
                    pause(0.01); %in seconds
                    writeVideo(CroppedVideo,RawFrameTwo)
                    flag = 1;
                    break
                else
                	motion = 0;
            	end
        end
        if flag == 1
            break
        end
    end
    
    %display of motion
    str = ['Motion: ',num2str(motion)];
    delete(findall(gcf,'type','annotation'))
    annotation('textbox', [0.2 0.2 0.2 0.2], 'string', str, 'linestyle',...
    'none')
    
    %repeating display
	drawnow;
	%stops writing over the same plot in the end of every loop
	hold off
    timer = timer + 1;
end
%stopping output video
close(CroppedVideo)