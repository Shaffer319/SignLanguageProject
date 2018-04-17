%MDL_CYTON Kinematic model of the Cyton Epsilon 1500 Robot Arm
%
% MDL_CYTON is a script that creates the workspace variables left and
% right which describes the kinematic characteristics of the 7-joint
% arm of a Cyton Epsilon 1500 robot using standard DH conventions.
%
% Also define the workspace vectors:
%   qz         zero joint angle configuration
%   qr         vertical 'READY' configuration
%
% Notes:
% - Link lengths are in units METERS.
%
% See also mdl_puma560, SerialLink.
%
% Revisions:
%
% 2017MAR06 Armiger: Created
% 2018APR03 Armiger: Added endpoint animation demo

% MODEL: Epsilon 1500, Cyton, 7DOF, standard_DH

%     th  d  a  alpha

links = [
    % Create the robot using RVC tools
    Revolute('d', 0.2,  'a', 0,     'alpha', pi/2,  'offset', pi/2);
    Revolute('d', 0,    'a', 0.135, 'alpha', -pi/2, 'offset', pi/2);
    Revolute('d', 0,    'a', 0.125, 'alpha', pi/2,  'offset', 0);
    Revolute('d', 0,    'a', 0.125, 'alpha', -pi/2, 'offset', 0);
    Revolute('d', 0,    'a', 0.135, 'alpha', pi/2,  'offset', 0);
    Revolute('d', 0,    'a', 0,     'alpha', pi/2,  'offset', pi/2);
    Revolute('d', 0.09, 'a', 0,     'alpha', 0,     'offset', pi/2);
];

cyton = SerialLink(links, 'name', 'Cyton Epsilon 1500', 'manufacturer', 'Cyton');

cyton.base = transl(0.0, 0.0, 0.0)*rpy2tr(0, 0, 0, 'xyz');

% define the workspace vectors:
%   qz         zero joint angle configuration
%   qr         vertical 'READY' configuration
%   qstretch   arm is stretched out in the X direction
%   qn         arm is at a nominal non-singular configuration
%
qz = [0 0 0 0 0 0 0]; % zero angles, arm up (given joint offsets)
qr = [pi/2 pi/4 0 pi/4 0 0 0]; % ready pose, arm slightly bent
qstretch = [pi/2 pi/2  0 0 0 0 0];
qn = qr;

% cyton.plot(qz)
% % cyton.teach()
% 
% axis([-.5 1 -0.5 0.5 -.1 1.2])
% view(3)
% 
% %
% cyton.plot(qr)
% F_r = cyton.fkine(qr)
% q_initial = qr
% 
% 
% %%
% 
% F_new = makehgtform('translate',[0.4 0 0.4],'zrotate',pi/2,'yrotate',0,'xrotate',pi/2);
% 
% tic
% q = cyton.ikine(F_new,'q0',q_initial,'pinv');
% toc
% if isempty(q)
%     error('Failed to converge')
% else
%     cyton.plot(q)
%     q_initial = q;
% end
% 
% %%  Compute a trajectory between poses:
% 
% T1 = cyton.fkine(qz);
% T2 = SE3(transl(0.4, 0, 0.4) * trotz(pi/2) * trotx(pi/2));
% T = ctraj(T1, T2, 50); 	% compute a Cartesian path
% 
% q = cyton.ikine(T);
% 
% %% Animate the pose from zero position to object position
% cyton.plot(q)
