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

qb = [deg2rad(100), pi/4, 0, pi/2, 0, pi/4, deg2rad(-80)]; %resting position above blocks
Pb = cyton.fkine(qb);
cyton.plot(qb);
hold on;
cubePlot(blocks(1,:), blockDim,blockDim,blockDim, 'b');
cubePlot(blocks(2,:), blockDim,blockDim,blockDim, 'g');
cubePlot(blocks(3,:), blockDim,blockDim,blockDim, 'r');
cubePlot(blocks(4,:), blockDim,blockDim,blockDim, 'c');
cubePlot(blocks(5,:), blockDim,blockDim,blockDim, 'm');
cubePlot(blocks(6,:), blockDim,blockDim,blockDim, 'y');
cubePlot(blocks(7,:), blockDim,blockDim,blockDim, 'k');
cubePlot(blocks(8,:), blockDim,blockDim,blockDim, 'w');

t = 0:0.05:2;

while 1
    c = input('', 's');
    c = c(1);
    block = 0;
    face = 0;
    
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
    
    P = SE3(blocks(block,:) + [bd, bd, 0.1]) * SE3.Ry(pi) * SE3.Rz(-(pi/2)*double(face-1));
    T = ctraj(Pb, P, length(t));
    q = cyton.ikine(T, 'q0', qb);
    cyton.plot(q);
end