close all;
mdl_cyton;
load q1
load q2
blockDim = 0.02; %20mm
bd = blockDim / 2;
blocks = [[-0.40, -0.04, -0.015]; %abcd
          [-0.34, -0.04, -0.005]; %efgh
          [-0.28, -0.04, -0.000]; %ijkl
          [-0.40, -0.10, -0.015]; %mnop
          [-0.34, -0.10, -0.005]; %qrst
          [-0.28, -0.10, -0.000]; %uvwx
          [-0.34, -0.16, -0.007]; %yz .
          [-0.28, -0.16, -0.000]];%!?,'

qh = [deg2rad(-80), -pi/4, 0, -pi/2, 0, -pi/4, deg2rad(10)]; %resting position above blocks
qu = [0, -pi/4, 0, -pi/4, 0, -pi/2, 0];
Ph = cyton.fkine(qh);
gripO = 0.0125;
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
t1 = 0:dt:8;
t2 = 0:dt:4;
tr = 0:dt:2;
tr2 = 0:dt:4;
t3 = 0:dt:10;
t4 = 0:dt:10;
gripS = (gripO - gripC) / 10;
grip = gripO:-gripS:gripC;

% cmd = PnetClass(8890, 8891, '127.0.0.1');
% cmd.initialize();

while 1
    c = input('', 's');
    c = c(1);
    
%     c = [];
%     while isempty(c)
%         [c,~] = cmd.getData()
%     end
%     if c = 'quit'
%         break
%     end
    
    block = 0;
    face = 0;
    
    %Determine which block and which face the letter is on
    switch uint8(c)
        case num2cell(uint8('a'):uint8('z'))
            block = idivide(uint8(c) - uint8('a'), 4, 'floor') + 1;
            face = mod(uint8(c) - uint8('a'),  4) + 1;
        % !!!!!!!!!!!!!!!! CHANGE THIS FOR THE DEMO !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
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
    rotate = 0;
    if face == uint8(2)
        rotate = -pi/2;
    elseif face == uint8(3)
        rotate = pi;
    elseif face == uint8(4)
        rotate = pi/2;
    end
    
    %User position
    Pu = SE3([0, -0.4, 0.2]) * SE3.Rx(pi) * SE3.Rz(pi/2);
    
    if face == uint8(3)
        qr = [jtraj(q1(end,1:7,block), [q1(end,1:6,block), q1(end,7,block)+rotate], length(tr2)), gripO*ones(length(tr2),1)];
    else
        qr = [jtraj(q1(end,1:7,block), [q1(end,1:6,block), q1(end,7,block)+rotate], length(tr)), gripO*ones(length(tr),1)];
    end
    qd = [q2(:,1:6,block), q2(:,7,block)+rotate, q2(:,8,block)];
    
    qg = [qd(end,1:7).*ones(length(grip),7), grip'];
    qu = flipud([q2(:,1:6,block), q2(:,7,block)+rotate, gripC*ones(length(t2),1)]);
        
    q3 = [jtraj(qu(end,1:7), [qu(end,1)+pi/3, qu(end,2:3), qu(end,4)+pi/8, qu(end,5:6), qu(end,7)-rotate], length(t3)), gripC*ones(length(t3),1)];
        
    Pt = cyton.fkine(q3(end,1:7));
    T4 = ctraj(Pt, Pu, length(t4));
    q4 = [cyton.ikine(T4, 'q0', q3(end,1:7)), gripC*ones(length(t4),1)];
    
    if face == uint8(1)
        traj = [q1(:,:,block);qd;qg;qu;q3;q4];
    else
        traj = [q1(:,:,block);qr;qd;qg;qu;q3;q4];
    end
    cyton.plot(traj(:,1:7), 'delay', 0.01);
    trajectory = [traj; flipud(traj)];
    % PnetClass(localPort,remotePort,remoteIP);
%     udp = PnetClass(8889, 8888, '127.0.0.1');
%     udp.initialize();
%     for t = trajectory.'
%         udp.putData(typecast(t','uint8'));
%         pause(dt);
%     end
%     udp.close();
end
% cmd.close();