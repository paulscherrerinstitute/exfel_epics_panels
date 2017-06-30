function [err, r] = ibfb_fb_find_corr_matrix(fkick1, fkick2, pl)

err=0;
%load 170613/kick1_y_full_range_scan.mat
load(fkick1);
mk1 = m;
%load 170613/kick2_y_full_range_scan.mat
load(fkick2);
mk2 = m;

clear m

DAC_R = 32767;

mk1.kick1_out = double(mk1.kick1_out)./DAC_R;
mk2.kick2_out = double(mk2.kick2_out)./DAC_R;
mk1.bpm1_down_pos = double(mk1.bpm1_down_pos);
mk1.bpm2_down_pos = double(mk1.bpm2_down_pos);
mk2.bpm1_down_pos = double(mk2.bpm1_down_pos);
mk2.bpm2_down_pos = double(mk2.bpm2_down_pos);

r.k1bpm1 = polyfit(mk1.kick1_out, mk1.bpm1_down_pos, 1);
r.k1bpm2 = polyfit(mk1.kick1_out, mk1.bpm2_down_pos, 1);
r.k2bpm1 = polyfit(mk2.kick2_out, mk2.bpm1_down_pos, 1);
r.k2bpm2 = polyfit(mk2.kick2_out, mk2.bpm2_down_pos, 1);
r.k1bpm1r = (max(mk1.bpm1_down_pos) - min(mk1.bpm1_down_pos))*1e3;
r.k1bpm2r = (max(mk1.bpm2_down_pos) - min(mk1.bpm2_down_pos))*1e3;
r.k2bpm1r = (max(mk2.bpm1_down_pos) - min(mk2.bpm1_down_pos))*1e3;
r.k2bpm2r = (max(mk2.bpm2_down_pos) - min(mk2.bpm2_down_pos))*1e3;

ms = [r.k1bpm1(1) r.k2bpm1(1); r.k1bpm2(1) r.k2bpm2(1)]
mr = ms.^(-1)
mr = inv(ms)

if pl
  figure(1)
  clf;
  subplot(2,2,1)
  plot(mk1.kick1_out, mk1.bpm1_down_pos);
  hold on
  plot(mk1.kick1_out, mk1.kick1_out.*r.k1bpm1(1)  + r.k1bpm1(2) , 'r')
  grid on
  mystr = sprintf('KICK1->BPM1: %f, Dynamic range: %f [um]', r.k1bpm1(1), r.k1bpm1r);
  title(mystr)
  xlabel('DAC1-2 output [V]')
  ylabel('BPM1 position [mm]')

  subplot(2,2,2)
  plot(mk1.kick1_out, mk1.bpm2_down_pos);
  hold on
  plot(mk1.kick1_out, mk1.kick1_out.*r.k1bpm2(1)  + r.k1bpm2(2) , 'r')
  grid on
  mystr = sprintf('KICK1->BPM2: %f, Dynamic range: %f [um]', r.k1bpm2(1), r.k1bpm2r);
  title(mystr)
  xlabel('DAC1-2 output [V]')
  ylabel('BPM2 position [mm]')

  subplot(2,2,3)
  plot(mk2.kick2_out, mk2.bpm1_down_pos);
  hold on
  plot(mk2.kick2_out, mk2.kick2_out.*r.k2bpm1(1)  + r.k2bpm1(2) , 'r')
  grid on
  mystr = sprintf('KICK2->BPM1: %f, Dynamic range: %f [um]', r.k2bpm1(1), r.k2bpm1r);
  title(mystr)
  xlabel('DAC3-4 output [V]')
  ylabel('BPM1 position [mm]')

  subplot(2,2,4)
  plot(mk2.kick2_out, mk2.bpm2_down_pos);
  hold on
  plot(mk2.kick2_out, mk2.kick2_out.*r.k2bpm2(1)  + r.k2bpm2(2) , 'r')
  grid on
  mystr = sprintf('KICK2->BPM2: %f, Dynamic range: %f [um]', r.k2bpm2(1), r.k2bpm2r);
  title(mystr)
  xlabel('DAC3-4 output [V]')
  ylabel('BPM2 position [mm]')
end