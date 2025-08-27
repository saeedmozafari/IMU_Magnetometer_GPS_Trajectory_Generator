# Sensor data generator: A Toolbox for Reliable IMU, Magnetometer and GNSS Trajectories

To create robust navigation algorithms, having a platform to generate 
dependable IMU (Inertial Measurement Unit) and GNSS (Global Navigation 
Satellite System) trajectories is imperative. This toolbox facilitates the 
provision of arbitrary data for your algorithm, drawing from the equations
 outlined in "Principles of GNSS, Inertial, and Multisensor Integrated 
Navigation Systems, 2nd Edition" authored by Professor Groves.

Usage Instructions:

To employ this toolbox, follow the instructions below:

1. Generating CSV File

   * Generate a csv file from carrier motion with the following format:

   % Column 1: time (sec)

   % Column 2: latitude (deg)

   % Column 3: longitude (deg)

   % Column 4: height (m)

   % Column 5: north velocity (m/s)

   % Column 6: east velocity (m/s)

   % Column 7: down velocity (m/s)

   % Column 8: roll angle of body w.r.t NED (deg)

   % Column 9: pitch angle of body w.r.t NED (deg)

   % Column 10: yaw angle of body w.r.t NED (deg)

2. Configuring Input File

   * Open the main_ECEF.m or main_NED.mfile.
   * In the configuration section, specify the generated file's name in the
     "input_profile_name" variable.

3. Sensor Configuration

   * Within the configuration section of related scripts ('IMU_Configuration',
     'GNSS_Configuration', 'Magnetometer_Configuration'), input desired sensor 
     configurations.

4- Running the program.

   * Execute the program.
   * Recorded data:
      * IMU data: "IMU_true" and "IMU_meas" matrices.
      * Magnetometer data: "MAG_true" and "MAG_meas" matrices.
      * GPS data: "GNSS_meas" matrice.
      * Note: "true" and "meas" denote ground truth and error-included data
        respectively.

## Note
Ensure to review and modify the configurations as needed before running the program.

For any issues or inquiries, please refer to the documentation or contact the maintainers.
