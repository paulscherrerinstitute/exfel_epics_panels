
load 170613/kick1_y_full_range_scan.mat
mk1 = m;

clear m

DAC_R = 32767;

mk1.kick1_out = double(mk1.kick1_out)./DAC_R;
mk2.kick2_out = double(mk2.kick2_out)./DAC_R;
mk1.bpm1_down_pos = double(mk1.bpm1_down_pos);
mk1.bpm2_down_pos = double(mk1.bpm2_down_pos);
mk2.bpm1_down_pos = double(mk2.bpm1_down_pos);
mk2.bpm2_down_pos = double(mk2.bpm2_down_pos);

% least squares method
S   = length(mk1.kick1_out);
Sx  = sum(mk1.kick1_out);
Sy  = sum(mk1.bpm1_down_pos);
Sxx = sum(mk1.kick1_out.^2);
Sxy = sum(mk1.kick1_out.*mk1.bpm1_down_pos);
Syy = sum(mk1.bpm1_down_pos.^2);
D   = S * Sxx - Sx^2;

a = (S   * Sxy - Sx * Sy )/D
b = (Sxx * Sy  - Sx * Sxy)/D

