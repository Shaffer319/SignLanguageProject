%TODO
%make it so no more examples of null are being added. might not be needed
%   until input check is done (wrong input values arent used)
%enable compile mode to reduce memory usage and run faster
%add code that makes sure the input is correct. might need to create matlab
%   functions



clear;
clc;

%ae, be, me, oe, ye
%a,b,c,d,e,f,g,h,i,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y, null

load('test.mat')

%initial settings
t=0;
k=0;
cyberglove_output = 'null';
truth_list = truth_data';
label_list = truth_classes;

%initialize matrixes
training_correct = 0;
training_attempts = 0;
ntraining_correct = 0;
ntraining_attempts = 0;
robot_correct = 0;
robot_attempts = 0;


%modified
%Setup CyberGlove
hGlove = Inputs.CyberGloveSerial(); % Create CyberGloveSerial object
hGlove.initialize('COM40');          % Connect device and get config

%Setup UDP
% UdpLocalPort = 56789;
% UdpDestinationPort = 25000; % 25100 = Left arm; 25000 = Right arm;
% UdpAddress = '127.0.0.1'; % IP address of the computer running vMPL
% 
% q = [0 -0.7 0 -0.7 0 -0.7 0];
% desiredAngles = [q, 0.01];
% udp.putData(typecast(desiredAngles,'uint8'))
% 
% udp = PnetClass(8889, 8888, '127.0.0.1');
% udp.initialize();
udp_port = 8000;
UdpAddress = '127.0.0.1';
echoudp('on', udp_port)
u = udp(UdpAddress, udp_port);
fopen(u)



%TODO
%Add real-time option
%CyberGlove readings
while k~=1
    clear raw_data;
    for i=1:90
        %modified
        raw_data(i,:) = hGlove.getRawData()';
    end
    
    
    %Prefiltering (remove outliers)
    
    %Average data
    data = mean(raw_data,1);
    
    %compare to truth data. Replace with NN if need to 
    tmp=sum(abs(truth_list-data),2);
    sorted_tmp = sort(tmp);
    estimates_classes = [""];

    counter = 0;
    i = 1;
    while counter < 3 || i > length(truth_list)
        el = find(tmp==sorted_tmp(i));
        
        
%         return;
        if ~ismember(label_list(el), estimates_classes)
            estimates_list(i) = el;
            estimates_classes(i) = label_list(estimates_list(i));
            counter = counter+1;
        end
        i = i+1;
    end
    
    %if training is done
    if t ==1
       %user input
       prompt = char(strcat('Did you mean:\n1)',estimates_classes(1),'\n2)',estimates_classes(2),'\n3)',estimates_classes(3),'\n4)none','\n'));
       usr_inp = lower(input(prompt,'s'));

       %analize input
       if usr_inp == '1'
           if ~ismember(data, truth_list,'rows')
               truth_list(end+1,:)=data;
               label_list(end+1)=estimates_classes(1);
           end
           training_correct = training_correct+1; training_attempts = training_attempts+1;
           cyberglove_output = estimates_classes(1);
       elseif usr_inp == '2'
           if ~ismember(data, truth_list,'rows')
               truth_list(end+1,:)=data;
               label_list(end+1)=estimates_classes(2);
           end
           training_attempts = training_attempts+1;
           cyberglove_output = estimates_classes(2);
       elseif usr_inp == '3'
           if ~ismember(data, truth_list,'rows')
               truth_list(end+1,:)=data;
               label_list(end+1)=estimates_classes(3);
           end
           training_attempts = training_attempts+1;
           cyberglove_output = estimates_classes(3);
       elseif usr_inp == '4'
           training_attempts = training_attempts+1;
           %do nothing
       elseif usr_inp == 'r'
           %Reset lists
           truth_list = truth_data';
           label_list = truth_classes;
       elseif usr_inp == 't'
           %Disable teaching mode
           t=0;
       elseif usr_inp == 'c'
           %TODO
           %compile data to reduce memory storage
           a=1;
       elseif strcmp(usr_inp,'score')
           %print out percent correct info
           print_score(training_correct,training_attempts,ntraining_correct,ntraining_attempts,robot_correct,robot_attempts)
       elseif usr_inp == 'end'
           %end the program
           break;
       else
           %TODO
           %incorrect input, try again
           a=1;
       end
       %end training
       
    %if not in training mode:
    else
       prompt = char(strcat('Did you mean: ',estimates_classes(1),'?[y/n]\n'));
       usr_inp = lower(input(prompt,'s'));
       
       if usr_inp == 'y'
           cyberglove_output = estimates_classes(1);
           ntraining_correct = ntraining_correct+1; ntraining_attempts = ntraining_attempts+1;
       elseif usr_inp == 'n'
           %TODO
           %skip;
           ntraining_attempts = ntraining_attempts+1;
           cyberglove_output = 'null';
       elseif usr_inp == 't'
           %enable teaching mode
           t = 1;
       elseif strcmp(usr_inp,'score')
           %print out percent correct info
           print_score(training_correct,training_attempts,ntraining_correct,ntraining_attempts,robot_correct,robot_attempts)
       elseif usr_inp == 'end'
           %end the program
           break;
       else
           %TODO
           wrong_input=1;
       end
       
    end 
    
    
    %Derek read here
    %Need to add call to get data from Myoband if Cyberglove output is null
    if cyberglove_output == 'null'
        output_to_robot = 'null';    %Change this to be letter from myoband
    else
        output_to_robot = cyberglove_output;
    end
    
    
    
    if output_to_robot ~= 'null'
        prompt2 = char(strcat('Do you want to transmit to robot?[y/n]\n'));
        usr_inp2 = lower(input(prompt2,'s'));
        if usr_inp2 == 'y'
            %TODO
            %Send to robot over UDP
            % output_to_robot = "UDP SOMETHING TODO";
            fprintf(u, output_to_robot);

            block_prompt = char(strcat('Is this the correct block?[y/n]\n'));
            block_usr_inp = lower(input(block_prompt,'s'));
            [robot_correct,robot_attempts] = update_block_score(block_usr_inp, robot_correct,robot_attempts);
            
        end
    end
end

%print out matrixes
print_score(training_correct,training_attempts,ntraining_correct,ntraining_attempts,robot_correct,robot_attempts)
