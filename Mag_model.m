function [meas_mag,qr1] = Mag_model(Ts,true_mag,IMU,qr0)
%% Simulates an inertial measurement unit model
%--------------------------------------------------------------------------
% Inputs:
%   Ts             time interval between epochs (s)
%   true_fBIB      true specific force of Body w.r.t. ECI expressed in the Body frame (m/s^2)
%   true_wBIB      true angular rate of Body w.r.t. ECI expressed in the Body frame (rad/s)
%   true_mag       Earth's magnetic field
%   IMU            error Sources of IMU Sensors 
%   qr0            residuals of previous output quantization process
%--------------------------------------------------------------------------
% Outputs:
%   meas_fBIB      measured specific force of Body w.r.t. ECI expressed in the Body frame (m/s^2)
%   meas_wBIB      measured angular rate of Body w.r.t. ECI expressed in the Body frame (rad/s)
%   meas_mag       measured magnetic field of Earth
%   qr1            residuals of output quantization process
%==========================================================================
%% Generate noise
if Ts > 0 
    mag_noise   = randn(3,1) * IMU.mag_RW / sqrt(Ts);
else
    mag_noise =[0;0;0];
end 
%==========================================================================
%% Calculate magnetometer outputs 
%magnetometer output
uq_mag = IMU.b_m + (eye(3) + IMU.SM_m) * true_mag + mag_noise;
%==========================================================================   
%% Quantize magnetometer outputs
%magnetometer quantization level (nT)
q_m = IMU.ql_m;
if q_m>0
    meas_mag  = q_m * round((uq_mag + qr0(1:3)) / q_m);
    qr1(7:9,1) = uq_mag + qr0(1:3) - meas_mag;
else
    meas_mag = uq_mag;
    qr1(7:9,1) = [0;0;0];
end 
%==========================================================================
end
