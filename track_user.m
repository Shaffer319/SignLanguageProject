% Plot the skeleton over the RGB image

% Create skeleton connection map to link the joints.
SkeletonConnectionMap = [ [4 3];  % Neck
                          [3 21]; % Head
                          [21 2]; % Right Leg
                          [2 1];  
                          [21 9];
                          [9 10];  % Hip
                          [10 11];
                          [11 12]; % Left Leg
                          [12 24];
                          [12 25];
                          [21 5];  % Spine
                          [5 6];
                          [6 7];   % Left Hand 
                          [7 8];    
                          [8 22];
                          [8 23];
                          [1 17];
                          [17 18];
                          [18 19];  % Right Hand
                          [19 20];
                          [1 13];
                          [13 14];
                          [14 15];
                          [15 16];                          
                        ];

% Marker colors for up to 6 bodies.
colors = ['r';'g';'b';'c';'y';'m'];

colorVid = videoinput('kinect',1);
depthVid = videoinput('kinect',2);

% Get the VIDEOSOURCE object from the depth device's VIDEOINPUT object.
depthSrc = getselectedsource(depthVid);

% Turn on skeletal tracking.
depthSrc.EnableBodyTracking = 'on';

% Using manual so that the memory does not fill automatically
triggerconfig(colorVid, 'manual');
triggerconfig(depthVid, 'manual');

% Now that the device is configured for manual triggering, call START.
% This will cause the device to send data back to MATLAB, but will not log
% frames to memory at this point.
start([colorVid, depthVid])

% Measure the time to acquire 20 frames.
% tic

% Create a single figure to update
figure(1)
try
    for i = 1:200
    %     trigger([colorVid depthVid]);
        [colorFrameData, colorMetaData] = getsnapshot(colorVid);
        [depthFrameData, depthMetaData] = getsnapshot(depthVid);

        subplot(2, 1, 1);
        imagesc(colorFrameData(:, :, :, 1)); 
        axis equal tight;
        subplot(2, 1, 2);
        imagesc(depthFrameData(:, :, :, 1)); axis equal tight;
        
    %     pause(.001)

        anyBodiesTracked = any(depthMetaData(1).IsBodyTracked ~= 0);
%         depthMetaData
        
        if anyBodiesTracked
            subplot(2, 1, 1);
            trackedBodies = find(depthMetaData(1).IsBodyTracked);
            
            % Find number of Skeletons tracked
            nBodies = length(trackedBodies);
            % Skeleton's joint indices with respect to the color image
            % This V1 uses JointDepthIndices and JointImageIndices
            colorJointIndices = depthMetaData(1).ColorJointIndices(:, :, trackedBodies);
            depthJointIndices = depthMetaData(1).DepthJointIndices(:, :, trackedBodies);
                        
            % https://www.mathworks.com/help/supportpkg/kinectforwindowsruntime/ug/acquire-image-and-skeletal-data-using-kinect-v1.html?searchHighlight=Image%20and%20Skeletal%20Data%20Using%20Kinect&s_tid=doc_srchtitle
            % https://www.mathworks.com/help/supportpkg/kinectforwindowsruntime/ug/acquire-image-and-body-data-using-kinect-v2.html
            jointPosition = depthMetaData(1).JointPositions(:, :, trackedBodies);

            % metaData = 
            %  
            % 11x1 struct array with fields:
            %     IsBodyTracked: [1x6 logical]
            %     BodyTrackingID: [1x6 double]
            %     BodyIndexFrame: [424x512 double]
            %     ColorJointIndices: [25x2x6 double]
            %     DepthJointIndices: [25x2x6 double]
            %     HandLeftState: [1x6 double] 
            %     HandRightState: [1x6 double]
            %     HandLeftConfidence: [1x6 double]
            %     HandRightConfidence: [1x6 double]
            %     JointTrackingStates: [25x6 double]
            %     JointPositions: [25x3x6 double]

            disp('TRACKING')
            hold on;
            
            % Overlay the skeleton on this RGB frame.
            for i = 1:24
%                  % Draw full skeleton
%                  for body = 1:nBodies
%                      X1 = [colorJointIndices(SkeletonConnectionMap(i,1),1,body) colorJointIndices(SkeletonConnectionMap(i,2),1,body)];
%                      Y1 = [colorJointIndices(SkeletonConnectionMap(i,1),2,body) colorJointIndices(SkeletonConnectionMap(i,2),2,body)];
%                      line(X1,Y1, 'LineWidth', 1.5, 'LineStyle', '-', 'Marker', '+', 'Color', colors(body));
%                  end
                 
            end
             c = [colorJointIndices(4, 1, 1) colorJointIndices(4, 2, 1)];
             circle(c, 100, 'r')
            hold off;
        else
            disp('No Tracking')
        end
        drawnow
    end
catch exception
    disp(exception)
end
% elapsedTime = toc

% Compute the time per frame and effective frame rate.
% timePerFrame = elapsedTime/60
% effectiveFrameRate = 1/timePerFrame

%% Call the STOP function to stop the device.
stop([colorVid, depthVid])

delete(colorVid)
delete(depthVid)
clear colorVid
clear depthVid
clear depthSrc
