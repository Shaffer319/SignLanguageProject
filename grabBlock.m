close all;
mdl_cyton;
blockDim = 0.02; %20mm
bd = blockDim / 2;
blocks = [[0.34, 0,    0]; %abcd
          [0.26, 0,    0]; %efgh
          [0.18, 0,    0]; %ijkl
          [0.10, 0,    0]; %mnop
          [0.34, 0.08, 0]; %qrst
          [0.26, 0.08, 0]; %uvwx
          [0.18, 0.08, 0]; %yz .
          [0.10, 0.08, 0]];%!?,'

qh = [deg2rad(-80), pi/6, 0, 2*pi/3, 0, pi/6, deg2rad(10)]; %resting position above blocks
Ph = cyton.fkine(qh);
qu = [0, pi/6, 0, pi/3, 0, pi/2, pi/2];
Pu = cyton.fkine(qu);
gripO = 0.015;
gripC = 0.01;

cyton.plot(qh);
hold on;
cubePlot(blocks(1,:), blockDim,blockDim,blockDim, 'b');
cubePlot(blocks(2,:), blockDim,blockDim,blockDim, 'g');
cubePlot(blocks(3,:), blockDim,blockDim,blockDim, 'r');
cubePlot(blocks(4,:), blockDim,blockDim,blockDim, 'c');
cubePlot(blocks(5,:), blockDim,blockDim,blockDim, 'm');
cubePlot(blocks(6,:), blockDim,blockDim,blockDim, 'y');
cubePlot(blocks(7,:), blockDim,blockDim,blockDim, 'k');
cubePlot(blocks(8,:), blockDim,blockDim,blockDim, 'w');

% Time step is 0.05s, time arrays for 1, 2, and 5 second movements
dt = 0.05;
t1 = 0:dt:1;
t2 = 0:dt:2;
t5 = 0:dt:5;
gripS = (gripO - gripC) / length(t1);
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
    
    %Position 10cm above block, and point +Y axis in direction of letter face
    Pa = SE3(blocks(block,:) + [bd, bd, 0.1]) * SE3.Ry(pi) * SE3.Rz(-(pi/2)*double(face-1));
    %Position to grab block
    Pb = SE3(blocks(block,:) + [bd, bd, blockDim+0.001]) * SE3.Ry(pi) * SE3.Rz(-(pi/2)*double(face-1));
    
    T1 = ctraj(Ph, Pa, length(t2));
    q1 = [cyton.ikine(T1, 'q0', qh), gripO*ones(length(t2),1)];
    T2 = ctraj(Pa, Pb, length(t1));
    q2 = [cyton.ikine(T2, 'q0', q1(end,1:7)), gripO*ones(length(t1),1)];
    qg = [q2(end,1:7).*ones(length(grip),7), grip'];
    T3 = ctraj(Pb, Pa, length(t1));
    q3 = [cyton.ikine(T3, 'q0', q2(end,1:7)), gripC*ones(length(t1),1)];
    T4 = ctraj(Pa, Pu, length(t5));
    q4 = [cyton.ikine(T4, 'q0', q3(end,1:7)), gripC*ones(length(t5),1)];
    
    traj = [q1;q2;qg;q3;q4;flipud(q4);flipud(q3);flipud(qg);flipud(q2);flipud(q1)];
    cyton.plot(traj);
%     udp = PnetClass(8889, 8888, '127.0.0.1');
%     udp.initialize();
%     for t = traj.'
%         udp.putData(typecast(t','uint8'));
%         pause(dt);
%     end
%     udp.close();
end