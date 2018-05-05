function [robot_correct,robot_attempts] = update_block_score(block_usr_inp, robot_correct,robot_attempts)
    if block_usr_inp == 'y'
        robot_correct = robot_correct +1;
        robot_attempts = robot_attempts +1;
    elseif block_usr_inp == 'n'
        robot_attempts = robot_attempts +1;
    end
end