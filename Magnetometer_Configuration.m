% Magnetometer Configuration

%Constants
deg_to_rad = 0.01745329252;

% Magnetometer bias (nT)
Mag_config.b_m = [50; 50; 50];

% Magnetometer scale factor and cross coupling errors
sm = 0.09E-2; %scale factor
m_m = 0.1 * deg_to_rad /3600; %input axis misalignment
Mag_config.SM_m =  [ sm,  m_m,   m_m;...
    m_m,   sm,   m_m;...
    m_m,   m_m,  sm] ;

% Magnetometer noise PSD (nT)
Mag_config.mag_RW = 1;

% Magnetometer quantization level (nT)
Mag_config.ql_m = 1E1;