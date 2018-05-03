close all;
mdl_cyton;
blockDim = 0.02; %20mm
bd = blockDim / 2;
blocks = [[-0.40, -0.04, -0.020]; %abcd
          [-0.34, -0.04, -0.010]; %efgh
          [-0.28, -0.04, -0.000]; %ijkl
          [-0.40, -0.10, -0.015]; %mnop
          [-0.34, -0.10, -0.010]; %qrst
          [-0.28, -0.10, -0.000]; %uvwx
          [-0.34, -0.16, -0.015]; %yz .
          [-0.28, -0.16, -0.002]];%!?,'

qh = [deg2rad(-80), -pi/4, 0, -pi/2, 0, -pi/4, deg2rad(10)]; %resting position above blocks
Ph = cyton.fkine(qh);
gripO = 0.0101;
gripC = 0.009;

% Time step is 0.05s, time arrays
dt = 0.05;
t1 = 0:dt:8;
t2 = 0:dt:4;

for i=1:8
    %Position 10cm above block
    Pa = SE3(blocks(i,:) + [bd, bd, 0.1]) * SE3.Rx(pi) * SE3.Rz(pi/2);
    %Position to grab block
    Pb = SE3(blocks(i,:) + [bd, bd, 0.041]) * SE3.Rx(pi) * SE3.Rz(pi/2);
    
    T1 = ctraj(Ph, Pa, length(t1));
    q1(:,:,i) = [cyton.ikcon(T1, qh), gripO*ones(length(t1),1)];
    
    T2 = ctraj(Pa, Pb, length(t2));
    q2(:,:,i) = [cyton.ikcon(T2, q1(end,1:7,i)), gripO*ones(length(t2),1)];
end
save('./q1', 'q1');
save('./q2', 'q2');