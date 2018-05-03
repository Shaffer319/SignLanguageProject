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

deg = pi/180;

linksR1 = [
    % Create the robot using RVC tools
    RevoluteMDH('d', 0.12435000000000002,    'a', 0,                      'alpha', 0,     'offset', pi/2,  'qlim', [-150 150]*deg);
    RevoluteMDH('d', 0.0010000000000004658,  'a', 7.757919228897728e-18,  'alpha', -pi/2, 'offset', -pi/2, 'qlim', [-110 110]*deg);
    RevoluteMDH('d', 0.0010000000000022803,  'a', 0.12550000000000006,    'alpha', -pi/2, 'offset', 0,     'qlim', [-110 110]*deg);
    RevoluteMDH('d', 0.0004417705383168262,  'a', 0.11580000000000001,    'alpha', pi/2,  'offset', 0,     'qlim', [-110 110]*deg);
    RevoluteMDH('d', 2.8553548414578245e-15, 'a', 0.09745694175448363,    'alpha', -pi/2, 'offset', 0,     'qlim', [-110 110]*deg);
    RevoluteMDH('d', 1.6757428777935957e-15, 'a', 0.07180000000000028,    'alpha', pi/2,  'offset', pi/2,  'qlim', [-114 114]*deg);
    RevoluteMDH('d', 0.05142499999999982,    'a', 2.8518063219589436e-17, 'alpha', pi/2,  'offset', 0,     'qlim', [-170 169]*deg);
];

cytonR1 = SerialLink(linksR1, 'name', 'Cyton Epsilon 1500', 'manufacturer', 'Cyton');
cytonR1.base = transl(0.0, 0.0, 0.0)*rpy2tr(0, 0, 0, 'xyz');

linksR2 = [
    % Create the robot using RVC tools
    RevoluteMDH('d', 0.12270000000000003,     'a', 0,                     'alpha', 0,     'offset', pi/2,  'qlim', [-150 150]*deg);
    RevoluteMDH('d', -1.2247147740396258e-15, 'a', 5.854647580881709e-16, 'alpha', -pi/2, 'offset', -pi/2, 'qlim', [-110 110]*deg);
    RevoluteMDH('d', 3.7816971776294395e-16,  'a', 0.12950000000000003,   'alpha', -pi/2, 'offset', 0,     'qlim', [-110 110]*deg);
    RevoluteMDH('d', 8.049116928532385e-16,   'a', 0.12199999999999966,   'alpha', pi/2,  'offset', 0,     'qlim', [-110 110]*deg);
    RevoluteMDH('d', -2.1510571102112408e-16, 'a', 0.12130000000000041,   'alpha', -pi/2, 'offset', 0,     'qlim', [-110 110]*deg);
    RevoluteMDH('d', 4.961309141293668e-16,   'a', 0.08469999999999993,   'alpha', pi/2,  'offset', pi/2,  'qlim', [-114 114]*deg);
    RevoluteMDH('d', 0.05742500000000015,     'a', 8.465526395203e-16,    'alpha', pi/2,  'offset', 0,     'qlim', [-170 169]*deg);
];

linksRBob = [
    % Create the robot using RVC tools
    RevoluteMDH('d', 0.1227,   'a', 0,      'alpha', 0,     'offset', pi/2,  'qlim', [-150 150]*deg);
    RevoluteMDH('d', 0,        'a', 0,      'alpha', -pi/2, 'offset', -pi/2, 'qlim', [-110 110]*deg);
    RevoluteMDH('d', 0,        'a', 0.1295, 'alpha', -pi/2, 'offset', 0,     'qlim', [-110 110]*deg);
    RevoluteMDH('d', 0,        'a', 0.122,  'alpha', pi/2,  'offset', 0,     'qlim', [-110 110]*deg);
    RevoluteMDH('d', 0,        'a', 0.1213, 'alpha', -pi/2, 'offset', 0,     'qlim', [-110 110]*deg);
    RevoluteMDH('d', 0,        'a', 0.0847, 'alpha', pi/2,  'offset', pi/2,  'qlim', [-114 114]*deg);
    RevoluteMDH('d', 0.057425, 'a', 0,      'alpha', pi/2,  'offset', 0,     'qlim', [-170 169]*deg);
];

cyton = SerialLink(linksRBob, 'name', 'Cyton Epsilon 1500 RBob', 'manufacturer', 'Cyton');
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
