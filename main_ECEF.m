%% Configuration ==========================================================
% Input truth motion profile filename
input_profile_name = 'Profile_3.csv';
% Sensor configurations
IMU_Configuration;
GNSS_Configuration;
Magnetometer_Configuration;
%% ========================================================================
% Initialize IMU quantization residuals
quant_residuals = [0;0;0;0;0;0];
qrm = zeros(3,1);
R2D = 180/pi;
D2R = pi/180;
% Input truth motion profile from .csv format file
[in_profile,no_epochs,ok] = Read_profile(input_profile_name);

IMU_true = zeros(length(in_profile(:,1))-1,7);
IMU_meas = zeros(length(in_profile(:,1))-1,7);
MAG_true = zeros(length(in_profile(:,1))-1,4);
MAG_meas = zeros(length(in_profile(:,1))-1,4);

% Initialize true navigation solution
old_time = in_profile(1,1);
old_true_L_b = in_profile(1,2);
old_true_lambda_b = in_profile(1,3);
old_true_h_b = in_profile(1,4);
old_true_v_eb_n = in_profile(1,5:7)';
old_true_eul_nb = in_profile(1,8:10)';
old_true_C_b_n = Euler_to_CTM(old_true_eul_nb)';

[old_true_r_eb_e,old_true_v_eb_e,old_true_C_b_e] =...
    NED_to_ECEF(old_true_L_b,old_true_lambda_b,old_true_h_b,...
    old_true_v_eb_n,old_true_C_b_n);
%% IMU and Magnetometer simulation ========================================
% Progress bar
dots = '....................';
bars = '||||||||||||||||||||';
rewind = '\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b';
fprintf(strcat('IMU & Magnetometer Processing: ',dots));
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
    [true_r_eb_e,true_v_eb_e,true_C_b_e] =...
        NED_to_ECEF(true_L_b,true_lambda_b,true_h_b,true_v_eb_n,true_C_b_n);
    
    % Time interval
    tor_i = time - old_time;
    
    % Calculate specific force and angular rate
    [true_f_ib_b,true_omega_ib_b] = Kinematics_ECEF(tor_i,true_C_b_e,...
        old_true_C_b_e,true_v_eb_e,old_true_v_eb_e,old_true_r_eb_e);
    
    % Record IMU outputs
    IMU_true(epoch-1,1) = time;
    IMU_true(epoch-1,2:4) = true_f_ib_b';
    IMU_true(epoch-1,5:7) = true_omega_ib_b';
    
    % Simulate IMU errors
    [meas_f_ib_b,meas_omega_ib_b,quant_residuals] = IMU_model(tor_i,...
        true_f_ib_b,true_omega_ib_b,IMU_errors,quant_residuals);
    % Record IMU outputs
    IMU_meas(epoch-1,1) = time;
    IMU_meas(epoch-1,2:4) = meas_f_ib_b';
    IMU_meas(epoch-1,5:7) = meas_omega_ib_b';
    
    % Simulate Magnetometer
    [M_n,~,d,~,~] = igrfmagm(true_h_b,true_L_b*R2D,true_lambda_b*R2D,2019);
    declination = d*D2R;
    M_b = (true_C_b_n')*(M_n');
    
    MAG_true(epoch-1,1) = time;
    MAG_true(epoch-1,2:4) = M_b';
    MAG_true(epoch-1,5) = declination;
    
    [meas_mag,qrm] = Mag_model(tor_i,M_n',Mag_config,qrm);
    meas_M_b = (true_C_b_n')*meas_mag;
    
    MAG_meas(epoch-1,1) = time;
    MAG_meas(epoch-1,2:4) = meas_M_b';
    MAG_meas(epoch-1,5) = declination;
    
    % Reset old values
    old_time = time;
    %     old_true_L_b = true_L_b;
    %     old_true_lambda_b = true_lambda_b;
    %     old_true_h_b = true_h_b;
    %     old_true_v_eb_n = true_v_eb_n;
    %     old_true_C_b_n = true_C_b_n;
    
    old_true_r_eb_e = true_r_eb_e;
    old_true_v_eb_e = true_v_eb_e;
    old_true_C_b_e = true_C_b_e;
    
end
% Complete progress bar
fprintf(strcat(rewind,bars,'\n'));
%% GPS simulation =========================================================
[GPS_meas,GPS_errors,GPS_clock] = GNSS_Least_Squares(in_profile,...
    no_epochs,GNSS_config);
%--------------------------------------------------------------------------