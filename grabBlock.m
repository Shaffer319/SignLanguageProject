close all;
mdl_cyton;
blockDim = 0.02; %20mm
bd = blockDim / 2;
blocks = [[0.44, 0,   0]; %abcd
          [0.36, 0,   0]; %efgh
          [0.28, 0,   0]; %ijkl
          [0.2,  0,   0]; %mnop
          [0.44, 0.1, 0]; %qrst
          [0.36, 0.1, 0]; %uvwx
          [0.28, 0.1, 0]; %yz .
          [0.2,  0.1, 0]];%!?,'

qh = [deg2rad(100), pi/4, 0, pi/2, 0, pi/4, deg2rad(-80)]; %resting position above blocks
Ph = cyton.fkine(qh);
qu = [0, -pi/6, 0, -pi/3, 0, -pi/2, pi];
Pu = cyton.fkine(qu);
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

t = 20;

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
    
    T1 = ctraj(Ph, Pa, t);
    q1 = cyton.ikine(T1, 'q0', qh);
    T2 = ctraj(Pa, Pb, t/2);
    q2 = cyton.ikine(T2, 'q0', q1(end,:));
    T3 = ctraj(Pb, Pa, t/2);
    q3 = cyton.ikine(T3, 'q0', q2(end,:));
    T4 = ctraj(Pa, Pu, t);
    q4 = cyton.ikine(T4, 'q0', q3(end,:));
    
    cyton.plot([q1;q2;q3;q4;flipud(q4);flipud(q3);flipud(q2);flipud(q1)]);
end