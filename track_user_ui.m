classdef track_user_ui < handle
    %TRACK_USER_UI Summary of this class goes here
    %   Detailed explanation goes here
    % 2.125 in
    % 2.5 in
    properties
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
        colorVid;
        depthVid;
        depthSrc;
        videoTimer;
        user_transform;
        
        % UI
        hFig;
    end
    
    methods
        function obj = track_user_ui()
            %TRACK_USER_UI Construct an instance of this class
            %   Detailed explanation goes here
            obj.user_transform = SE3(0,0,0);
            
        end
           
        function obj = start(obj)
            try
                obj.colorVid = videoinput('kinect',1);
            catch e
                disp(e)
                return
            end
            try
                obj.depthVid = videoinput('kinect',2);
            catch e
                disp(e)
                delete(obj.colorVid)
                return
            end
            
            % Get the VIDEOSOURCE object from the depth device's VIDEOINPUT object.
            obj.depthSrc = getselectedsource(obj.depthVid);

            % Turn on skeletal tracking.
            obj.depthSrc.EnableBodyTracking = 'on';
            % Using manual so that the memory does not fill automatically
            triggerconfig(obj.colorVid, 'manual');
            triggerconfig(obj.depthVid, 'manual');
            
            start([obj.colorVid, obj.depthVid]);
        end
        
        function view(obj)
            obj.hFig = figure('Toolbar','none',...
               'Menubar', 'none',...
               'NumberTitle','Off',...
               'Name','My Preview Window');
            % Create the image object in which you want to display 
            % the video preview data. Make the size of the image
            % object match the dimensions of the video frames.
               
            vidRes = obj.depthVid.VideoResolution;
            nBands = obj.depthVid.NumberOfBands;
            hImage = imagesc(zeros(vidRes(2), vidRes(1), nBands) );
 
            obj.videoTimer = timer('Name', 'videoTimer', ...
                'ExecutionMode', 'fixedSpacing', 'Period', 0.001,...
                'TimerFcn', @obj.updatePreview)
            obj.videoTimer.UserData = hImage;

            s = struct('hImage',hImage) % , 'p', p)

            obj.videoTimer.UserData = s 
            start(obj.videoTimer);
        end
        
        function updatePreview(obj, mTimer, ~)
            [colorFrameData, colorMetaData] = getsnapshot(obj.colorVid);
            [depthFrameData, depthMetaData] = getsnapshot(obj.depthVid);
            
            s = mTimer.UserData;
            s.hImage.CData = depthFrameData(:,:,:,1); 
            anyBodiesTracked = any(depthMetaData(1).IsBodyTracked ~= 0);
            hold on    
            
            % Clear all old lines
            h = findobj('type','line');
            delete(h);
            
            if anyBodiesTracked
                title('Tracking')
%                 disp('Tracking')
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
            
                
                for i = 1:24
                     % Draw full skeleton
                     for body = 1:nBodies
                         
%                          X1 = [colorJointIndices(obj.SkeletonConnectionMap(i,1),1,body) colorJointIndices(obj.SkeletonConnectionMap(i,2),1,body)];
%                          Y1 = [colorJointIndices(obj.SkeletonConnectionMap(i,1),2,body) colorJointIndices(obj.SkeletonConnectionMap(i,2),2,body)];
                         
                         X1 = [depthJointIndices(obj.SkeletonConnectionMap(i,1),1,body) depthJointIndices(obj.SkeletonConnectionMap(i,2),1,body)];
                         Y1 = [depthJointIndices(obj.SkeletonConnectionMap(i,1),2,body) depthJointIndices(obj.SkeletonConnectionMap(i,2),2,body)];
                         line(X1,Y1, 'LineWidth', 1.5, 'LineStyle', '-', 'Marker', '+', 'Color', obj.colors(body));
                     end

                end
                
                head_xyz = jointPosition(4,:);
                
                obj.user_transform = SE3(head_xyz);
                % Todo send udp of head_xyz
                
                c = [depthJointIndices(4, 1, 1) depthJointIndices(4, 2, 1)];
                
                r = 10;
                ang=0:0.01:2*pi; 
                xp=r*cos(ang);
                yp=r*sin(ang);
                plot(c(1)+xp,c(2)+yp, 'k');
                
                
                
            else                
                title('Not Tracking')
%                 disp('Not Tracking')
            end
            hold off
            
            % Update user data
            obj.videoTimer.UserData = s;
            
        end
        
        function stopView(obj)
            stop(obj.videoTimer)
        end
        
        function p = circle(obj, x, y, r)
            ang=0:0.01:2*pi; 
            xp=r*cos(ang);
            yp=r*sin(ang);
            p = plot(x+xp,y+yp);
        end
        
        function stop(obj)
            delete(obj.colorVid);
            delete(obj.depthVid);
            obj.colorVid = [];
            obj.depthVid = [];
            obj.depthSrc = [];
        end
    end
end

