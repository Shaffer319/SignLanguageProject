close all;
mdl_cyton;
blockDim = 0.02; %20mm
bd = blockDim / 2;
blocks = [[-0.40, -0.04, 0]; %abcd
          [-0.34, -0.04, 0]; %efgh
          [-0.28, -0.04, 0]; %ijkl
          [-0.40, -0.10, 0]; %mnop
          [-0.34, -0.10, 0]; %qrst
          [-0.28, -0.10, 0]; %uvwx
          [-0.34, -0.16, 0]; %yz .
          [-0.28, -0.16, 0]];%!?,'

qh = [deg2rad(-80), -pi/4, 0, -pi/2, 0, -pi/4, deg2rad(10)]; %resting position above blocks
qu = [0, -pi/4, 0, -pi/4, 0, -pi/2, 0];
Ph = cyton.fkine(qh);
gripO = 0.0101;
gripC = 0.009;

% Time step is 0.05s, time arrays
dt = 0.05;
t1 = 0:dt:4;
t2 = 0:dt:8;
t3 = 0:dt:10;
gripS = (gripO - gripC) / 10;
grip = gripO:-gripS:gripC;

traj = zeros(length(t2) + length(t1)*2 + length(t3) + length(grip), 8, 8*4);

parfor i=1:8*4
    block = uint8(floor((i-1) / 4)) + 1;
    face = uint8(mod(i-1, 4)) +1;
    
    rotate = false;
    if face == uint8(3)
        rotate = true;
        face = uint8(1);
    end
    
    %Position 10cm above block, and point +Y axis in direction of letter face
    Pa = SE3(blocks(block,:) + [bd, bd, 0.1]) * SE3.Rx(pi) * SE3.Rz(-(pi/2)*double(face-1));
    %Position to grab block
    Pb = SE3(blocks(block,:) + [bd, bd, 0.0401]) * SE3.Rx(pi) * SE3.Rz(-(pi/2)*double(face-1));
    %User position
    Pu = SE3([-0.20, -0.20, 0.20]) * SE3.Rx(pi);
    if rotate
        Pu = Pu * SE3.Rz(pi);
    end
    
    T1 = ctraj(Ph, Pa, length(t2));
    q1 = [real(cyton.ikcon(T1, qh)), gripO*ones(length(t2),1)];
    
    T2 = ctraj(Pa, Pb, length(t1));
    q2 = [real(cyton.ikcon(T2, q1(end,1:7))), gripO*ones(length(t1),1)];
    
    qg = [q2(end,1:7).*ones(length(grip),7), grip'];
    q3 = [flipud(q2(:,1:7)), gripC*ones(length(t1),1)];
    
    T4 = ctraj(Pa, Pu, length(t3));
    q4 = [real(cyton.ikcon(T4, q3(end,1:7))), gripC*ones(length(t3),1)];
    
    traj(:,:,i) = [q1;q2;qg;q3;q4];
end
save ('./traj', 'traj');