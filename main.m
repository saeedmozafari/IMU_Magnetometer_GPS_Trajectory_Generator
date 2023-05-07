
filename = 'otto_S_2000sec.csv';
Write_profile(filename,in_profile)
%% ========================================================================
IMU;
% Initialize IMU quantization residuals
quant_residuals = [0;0;0;0;0;0];

% Input truth motion profile filename
input_profile_name = 'otto_S_2000sec.csv';

% Input truth motion profile from .csv format file
[in_profile,no_epochs,ok] = Read_profile(input_profile_name);

% Initialize true navigation solution
old_time = in_profile(1,1);
old_true_L_b = in_profile(1,2);
old_true_lambda_b = in_profile(1,3);
old_true_h_b = in_profile(1,4);
old_true_v_eb_n = in_profile(1,5:7)';
old_true_eul_nb = in_profile(1,8:10)';
old_true_C_b_n = Euler_to_CTM(old_true_eul_nb)';




% Progress bar
dots = '....................';
bars = '||||||||||||||||||||';
rewind = '\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b';
fprintf(strcat('Processing: ',dots));
progress_mark = 0;
progress_epoch = 0;
for epoch = 2:no_epochs

    % Update progress bar
    if (epoch - progress_epoch) > (no_epochs/20)
        progress_mark = progress_mark + 1;
        progress_epoch = epoch;
        fprintf(strcat(rewind,bars(1:progress_mark),...
            dots(1:(20 - progress_mark))));
    end % if epoch    
    
    % Input data from motion profile
    time = in_profile(epoch,1);
    true_L_b = in_profile(epoch,2);
    true_lambda_b = in_profile(epoch,3);
    true_h_b = in_profile(epoch,4);
    true_v_eb_n = in_profile(epoch,5:7)';
    true_eul_nb = in_profile(epoch,8:10)';
    true_C_b_n = Euler_to_CTM(true_eul_nb)';
   
    % Time interval
    tor_i = time - old_time;
%     tor_i = 0.01;
    % Calculate true specific force and angular rate
    [true_f_ib_b,true_omega_ib_b] = Kinematics_NED(tor_i,true_C_b_n,...
        old_true_C_b_n,true_v_eb_n,old_true_v_eb_n,true_L_b,true_h_b,...
        old_true_L_b,old_true_h_b);
    
    % Simulate IMU errors
    [meas_f_ib_b,meas_omega_ib_b,quant_residuals] = IMU_model(tor_i,...
        true_f_ib_b,true_omega_ib_b,IMU_errors,quant_residuals);
    
    IMU_meas(epoch-1,1) = time;
    IMU_meas(epoch-1,2:4) = meas_f_ib_b';
    IMU_meas(epoch-1,5:7) = meas_omega_ib_b';
    
    % Reset old values
    old_time = time;
    old_true_L_b = true_L_b;
    old_true_lambda_b = true_lambda_b;
    old_true_h_b = true_h_b;
    old_true_v_eb_n = true_v_eb_n;
    old_true_C_b_n = true_C_b_n; 
end

% Complete progress bar
fprintf(strcat(rewind,bars,'\n'));