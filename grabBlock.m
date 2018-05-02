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

cyton.teach(qh);
hold on;
cubePlot(blocks(1,:), blockDim,blockDim,blockDim, 'b');
cubePlot(blocks(2,:), blockDim,blockDim,blockDim, 'g');
cubePlot(blocks(3,:), blockDim,blockDim,blockDim, 'r');
cubePlot(blocks(4,:), blockDim,blockDim,blockDim, 'c');
cubePlot(blocks(5,:), blockDim,blockDim,blockDim, 'm');
cubePlot(blocks(6,:), blockDim,blockDim,blockDim, 'y');
cubePlot(blocks(7,:), blockDim,blockDim,blockDim, 'k');
cubePlot(blocks(8,:), blockDim,blockDim,blockDim, 'w');

% Time step is 0.05s, time arrays
dt = 0.05;
t1 = 0:dt:4;
t2 = 0:dt:8;
t3 = 0:dt:8;
t4 = 0:dt:8;
gripS = (gripO - gripC) / 10;
grip = gripO:-gripS:gripC;

while 1
    c = input('', 's');
    c = c(1);
    block = 0;
    face = 0;
    
    %Determine which block and which face the letter is on
    switch uint8(c)
        case num2cell(uint8('a'):uint8('z'))
            block = idivide(uint8(c) - uint8('a'), 4, 'floor') + 1;
            face = mod(uint8(c) - uint8('a'),  4) + 1;
        case uint8('_') %input won't accept space so have to do underscore for now 
            block = uint8(7);
            face = uint8(3);
        case uint8('.')
            block = uint8(7);
            face = uint8(4);
        case uint8('!')
            block = uint8(8);
            face = uint8(1);
        case uint8('?')
            block = uint8(8);
            face = uint8(2);
        case uint8(',')
            block = uint8(8);
            face = uint8(3);
        case uint8('''')
            block = uint8(8);
            face = uint8(4);
    end
    disp(block);
    disp(face);
    rotate = false;
    if face == uint8(3)
        rotate = true;
        face = uint8(1);
    end
    
    %Position 10cm above block, and point +Y axis in direction of letter face
    Pa = SE3(blocks(block,:) + [bd, bd, 0.1]) * SE3.Rx(pi) * SE3.Rz(-(pi/2)*double(face-1));
    %Position to grab block
    Pb = SE3(blocks(block,:) + [bd, bd, 0.041]) * SE3.Rx(pi) * SE3.Rz(-(pi/2)*double(face-1));
    %User position
    Pu = SE3([0, -0.36, 0.18]) * SE3.Rx(pi);
    if rotate
        Pa = Pa * SE3.Rz(pi);
        Pb = Pb * SE3.Rz(pi);
    end
    
    T1 = ctraj(Ph, Pa, length(t2));
    q1 = [cyton.ikine(T1, 'q0', qh, 'tol', 0.0001), gripO*ones(length(t2),1)];
    [q,~,~] = jtraj(qh(7),q1(end,7), length(t2));
    q1(:,7) = q;
    
    T2 = ctraj(Pa, Pb, length(t1));
    q2 = [cyton.ikine(T2, 'q0', q1(end,1:7), 'tol', 0.00001), gripO*ones(length(t1),1)];
    
    qg = [q2(end,1:7).*ones(length(grip),7), grip'];
    q3 = [flipud(q2(:,1:7)), gripC*ones(length(t1),1)];
    
    rotation = cyton.ikine(Pu, 'q0', qu, 'tol', 0.0001);
    [qr,~,~] = jtraj(q3(end,1:7),[-pi/4, q3(end,2:6), rotation(7)], length(t3));
    qr = [qr, gripC*ones(length(t3),1)];
    
%     Pt = cyton.fkine(qr(end,1:7));
%     T4 = ctraj(Pt, Pu, length(t4));
%     q4 = [cyton.ikine(T4, 'q0', qr(end,1:7), 'tol', 0.01), gripC*ones(length(t4),1)];
%     [q,~,~] = jtraj(qr(end,7),q4(end,7), length(t4));
%     q4(:,7) = q;
    
    traj = [q1;q2;qg];%;q3;qr;flipud(qr);flipud(q3);flipud(qg);flipud(q2);flipud(q1)];
    %cyton.plot(traj(:,1:7));
    udp = PnetClass(8889, 8888, '127.0.0.1');
    udp.initialize();
    for t = traj.'
        udp.putData(typecast(t','uint8'));
        pause(dt);
    end
    udp.close();
end
