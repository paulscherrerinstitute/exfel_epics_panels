
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% List of the DAQ signals
% RXDAQ0 - GTX RX upstream BPM1
% RXDAQ1 - GTX RX upstream BPM2
% RXDAQ2 - GTX RX downstream BPM1
% RXDAQ3 - GTX RX downstream BPM2
% RXDAQ4 - GTX RX SASE BPM1
% RXDAQ5 - GTX RX SASE BPM2
% RXDAQ6 - GTX RX collimator BPM
%
% DAQ00  - BPM position after BPM mux       single
% DAQ01  - Integrator output gated          single
% DAQ02  - Kicker output                    integer
% DAQ10  - Position error                   single
% DAQ11  - Feedback kick (single)           single
% DAQ12  - FF table                         integer
% DAQ20  - Integrator output                single
% DAQ21  - PI output                        single
% DAQ22  - BPM position before mux          single
% DAQ30  - Feedback kick (int)              integer
% DAQ31  - FF table                         integer
% DAQ32  - Kicker output                    integer
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function test_comp_pipe(ibfb)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Checking downstream BPMs against BPM mux output
  % RXDAQ0 == DAQ22
  %  DAQ22 == DAQ00
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  myplots=0;
  SP_POS = 1;
  SP_ANGLE = -1;
  FB_KI = 0.02;
  FB_KP = 0.1;
  %FB_KICK = [0.2 0.3 0.4 0.5];
  FB_KICK = [1 0 0 1];
  %FB_KICK = [1 -1 -1 1];
  DAQ_SCA = 32768;
  FF_ON = 1;
  FB_ON = 1;
  smp = 256;
  bkts = 2708;
  plane = 'Y';

  CMP1 = 0;  % [ DAQ00  DAQ10  DAQ22  DAQ30 ] passed
  CMP2 = 0;  % [ DAQ00  DAQ10  DAQ21  DAQ30 ] passed
  CMP3 = 1;  % [ DAQ01  DAQ10  DAQ20  DAQ30 ] passed
  CMP4 = 0;  % [ DAQ01  DAQ10  DAQ21  DAQ30 ] passed
  CMP5 = 0;  % [ DAQ01  DAQ11  DAQ21  DAQ32 ] passed
  CMP6 = 0;  % [ DAQ02  DAQ12  DAQ20  DAQ32 ] passed
  
  t=0:1:(smp-1);
  
  fprintf('Settings initialization...\n') 
  ibfb.ctrl.y_fb_params_mode.put(uint32(2));  % manual mode
  ibfb.ctrl.y_trg_mode.put(uint32(1));
  ibfb.ctrl.y_fb_sp_pos.put(single(SP_POS));
  ibfb.ctrl.y_fb_sp_angle.put(single(SP_ANGLE));
  ibfb.ctrl.y_fb_fast_ki.put(single(FB_KI));
  ibfb.ctrl.y_fb_fast_kp.put(single(FB_KP));
  ibfb.ctrl.y_fb_kicker_m11.put(single(FB_KICK(1)));
  ibfb.ctrl.y_fb_kicker_m12.put(single(FB_KICK(2)));
  ibfb.ctrl.y_fb_kicker_m21.put(single(FB_KICK(3)));
  ibfb.ctrl.y_fb_kicker_m22.put(single(FB_KICK(4)));
  ibfb.ctrl.y_fb_fast_on.put(uint32(FB_ON));
  ibfb.ctrl.y_ff_fast_on.put(uint32(FF_ON));
  pause(0.3);

  % generate bunch trains mask vector
  st.s1_start = ibfb.ctrl.y_sase1_bucket_start.get()+1; % matlab indexing from 1
  st.s1_stop  = ibfb.ctrl.y_sase1_bucket_stop.get() +1;
  st.s1_space = ibfb.ctrl.y_sase1_bunch_space.get()   ;
  st.s1_num   = ibfb.ctrl.y_sase1_bunch_num.get()     ;
  st.s2_start = ibfb.ctrl.y_sase2_bucket_start.get()+1; % matlab indexing from 1
  st.s2_stop  = ibfb.ctrl.y_sase2_bucket_stop.get() +1;
  st.s2_space = ibfb.ctrl.y_sase2_bunch_space.get()   ;
  st.s2_num   = ibfb.ctrl.y_sase2_bunch_num.get()     ;
  st.s3_start = ibfb.ctrl.y_sase3_bucket_start.get()+1; % matlab indexing from 1
  st.s3_stop  = ibfb.ctrl.y_sase3_bucket_stop.get() +1;
  st.s3_space = ibfb.ctrl.y_sase3_bunch_space.get()   ;
  st.s3_num   = ibfb.ctrl.y_sase3_bunch_num.get()     ;
  bt_p = zeros(1, bkts);
  bt_p_del = zeros(1, bkts);
  if st.s1_start < bkts
    bt_p(st.s1_start:st.s1_stop) = 1;    
    bt_p_del(st.s1_start:st.s1_stop+1) = 1; 
  end
  if st.s2_start < bkts
    bt_p(st.s2_start:st.s2_stop) = 1;    
    bt_p_del(st.s2_start+1:st.s2_stop+1) = 1; 
  end
  if st.s3_start < bkts
    bt_p(st.s3_start:st.s3_stop) = 1;    
    bt_p_del(st.s3_start+1:st.s3_stop+1) = 1;    
  end
  d=double(ibfb.ctrl.y_fast_fb_del.get());
  bs = ibfb.ctrl.y_sase1_bunch_space.get();
  i_smp_apply = ibfb.ctrl.y_fb_i_smp_apply.get();

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  if CMP1
    [err daq] = retrieve_daq_data(ibfb, [0 0 2 0], plane, 1, t);
    
    fprintf('Data cross-check...\n') 
    fprintf('  Measured latency: %d\n', d);
    rx_down_bpm1 = zeros(1, length(daq.rx_down_bpm1));
    rx_down_bpm1(d+1:end) = daq.rx_down_bpm1(1:end-d);
    rx_down_bpm1(1:d) = zeros(1,d);
    rx_down_bpm2 = zeros(1, length(daq.rx_down_bpm2));
    rx_down_bpm2(d+1:end) = daq.rx_down_bpm2(1:end-d);
    rx_down_bpm2(1:d) = zeros(1,d);
    if bs > 1
      for i=d+1:4:smp
        rx_down_bpm1(i:i+3) = rx_down_bpm1(i);
        rx_down_bpm2(i:i+3) = rx_down_bpm2(i);
      end
    end
    rx_down_bpm1 = rx_down_bpm1(1:smp);
    rx_down_bpm2 = rx_down_bpm2(1:smp);
    
    fprintf('  Comparing RXDAQ0 == DAQ22 ...');
    if vect_not_equal(rx_down_bpm1(d+1:end), daq.ch00(d+1:end)) | vect_not_equal(rx_down_bpm2(d+1:end), daq.ch01(d+1:end))
      plot_wrong_waves(t, rx_down_bpm1, daq.ch00, 'RXDAQ0', 'DAQ22');
      fprintf(2, 'ERROR: Waveforms do not match\n');
      return;
    else
      fprintf('OK\n')
    end

    fprintf('  Comparing DAQ22 == DAQ00 ...');
    if vect_not_equal(daq.ch20, daq.ch00) | vect_not_equal(daq.ch21, daq.ch01)
      plot_wrong_waves(t, daq.ch20, daq.ch00, 'DAQ00', 'DAQ22');
      fprintf(2, 'ERROR: Waveforms do not match\n');
      return;
    else
      fprintf('OK\n');
    end

    fprintf('  Comparing SP-DAQ10 == DAQ00 ...');
    fb_err = single(zeros(2, smp));
    fb_err(1, :) = single(single(SP_POS)-daq.ch10);
    fb_err(2, :) = single(single(SP_ANGLE)-daq.ch11);
    if vect_not_equal(fb_err(1, d+1:end), daq.ch00(d+1:end)) | vect_not_equal(fb_err(2, d+1:end), daq.ch01(d+1:end))
      plot_wrong_waves(t, fb_err(2, :), daq.ch01, 'SP-DAQ10', 'DAQ00');
      fprintf(2, 'ERROR: Waveforms do not match\n');
      return;
    else
      fprintf('OK\n');
    end
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  if CMP2
    ibfb.ctrl.y_fb_fast_ki.put(single(0));
    ibfb.ctrl.y_fb_fast_kp.put(single(0));
    [err daq] = retrieve_daq_data(ibfb, [0 0 1 0], plane, 1, t);
    
    fprintf('  Comparing DAQ10 == DAQ21 ...');
    if vect_not_equal(daq.ch10(d+1:end), daq.ch20(d+1:end)) | vect_not_equal(daq.ch11(d+1:end), daq.ch21(d+1:end))
      fprintf(2, 'ERROR: Waveforms do not match\n');
      plot_wrong_waves(t, daq.ch10, daq.ch20, 'DAQ10', 'DAQ21');
      return;
    else
      fprintf('OK\n');
    end  
  end


  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  if CMP3
    ibfb.ctrl.y_fb_fast_ki.put(single(FB_KI));
    ibfb.ctrl.y_fb_fast_kp.put(single(FB_KP));
    [err daq] = retrieve_daq_data(ibfb, [1 0 0 0], plane, 1, t);

    % check integrator
    fprintf('  Comparing DAQ10 == DAQ20 ...');
    ctrl_err = single(zeros(2, smp));
    ctrl_err(1, :) = daq.ch10;
    ctrl_err(2, :) = daq.ch11;
    ctrl_err(:, 1:d) = 0;
    ctrl_i = zeros(2, smp);
    for i=d+1:bs:smp
      ctrl_i(1, i:i+bs-1) = single(FB_KI).*ctrl_err(1,i) + ctrl_i(1, i-1);  %.*single(bt_p_del(1:smp)));
      ctrl_i(2, i:i+bs-1) = single(FB_KI).*ctrl_err(2,i) + ctrl_i(2, i-1);  %.*single(bt_p_del(1:smp)));
    end
    ctrl_i = ctrl_i(:,1:smp);
    ctrl_i(1,:) = ctrl_i(1,:).*sign(daq.ch20(1:smp));
    ctrl_i(2,:) = ctrl_i(2,:).*sign(daq.ch20(1:smp));
    if vect_not_equal(ctrl_i(1,:), daq.ch20) | vect_not_equal(ctrl_i(2,:), daq.ch21)
      fprintf(2, 'ERROR: Waveforms do not match\n');
      plot_wrong_waves(t, ctrl_i(1,:), daq.ch20, 'DAQ10', 'DAQ20');
      %return;
    else
      fprintf('OK\n');
    end
    
    % check gated integrator
    fprintf('  Comparing DAQ20 == DAQ01 ...');
    ctrl_i_g = zeros(2, smp);    
    for i=d+i_smp_apply+1:i_smp_apply:smp
      ctrl_i_g(1,i:i+i_smp_apply-1) = daq.ch20(i-1);
      ctrl_i_g(2,i:i+i_smp_apply-1) = daq.ch21(i-1);
    end
    ctrl_i_g = ctrl_i_g(:,1:smp);
    ctrl_i_g(1,:) = ctrl_i_g(1,:).*sign(daq.ch00(1:smp));
    ctrl_i_g(2,:) = ctrl_i_g(2,:).*sign(daq.ch00(1:smp));
    if vect_not_equal(ctrl_i_g(1,:), daq.ch00) | vect_not_equal(ctrl_i_g(2,:), daq.ch01)
      plot_wrong_waves(t, ctrl_i_g(1,:), daq.ch00, 'DAQ20', 'DAQ01');
      fprintf(2, 'ERROR: Waveforms do not match\n');
      return;
    else
      fprintf('OK\n');
    end

  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  if CMP4
    [err daq] = retrieve_daq_data(ibfb, [1 0 1 0], plane, 1, t);
    
    % check P+I
    fprintf('  Comparing DAQ10 + DAQ01 == DAQ21 ...');
    ctrl_pi = single(zeros(2, smp));
    ctrl_pi(1,:) = single(daq.ch00 + daq.ch10);
    ctrl_pi(2,:) = single(daq.ch01 + daq.ch11);
    if vect_not_equal(ctrl_pi(1,:), daq.ch20) | vect_not_equal(ctrl_pi(2,:), daq.ch21)
      plot_wrong_waves(t, ctrl_pi(1,:), daq.ch20, 'DAQ01+DAQ10', 'DAQ21');
      fprintf(2, 'ERROR: Waveforms do not match\n');
      return;
    else
      fprintf('OK\n');
    end

  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  if CMP5
    [err daq] = retrieve_daq_data(ibfb, [1 1 1 0], plane, 1, t);
    % check kick matrix
    fprintf('  Comparing DAQ21 == DAQ11 ...');
    kick = single(zeros(2, smp));
    kick(1,:) = single(single(FB_KP).*single(FB_KICK(1)).*daq.ch20 + single(FB_KP).*single(FB_KICK(2)).*daq.ch21);
    kick(2,:) = single(single(FB_KP).*single(FB_KICK(3)).*daq.ch20 + single(FB_KP).*single(FB_KICK(4)).*daq.ch21);
    if vect_not_equal(kick(1,:), daq.ch10) | vect_not_equal(kick(2,:), daq.ch11)
      plot_wrong_waves(t, kick(1,:), daq.ch10, 'DAQ21', 'DAQ11');
      fprintf(2, 'ERROR: Waveforms do not match\n');
      return;
    else
      fprintf('OK\n');
    end
    % check float to integer conversion
    fprintf('  Comparing DAQ11 == DAQ30 ...');
    kick_int = int32(zeros(2, smp));
    kick_int(1, :) = int32(DAQ_SCA.*daq.ch10); 
    kick_int(2, :) = int32(DAQ_SCA.*daq.ch11);
    if vect_not_equal(kick_int(1,:), daq.ch30) | vect_not_equal(kick_int(2,:), daq.ch31)
      plot_wrong_waves(t, kick_int(1,:), daq.ch30, 'DAQ11', 'DAQ30');
      fprintf(2, 'ERROR: Waveforms do not match\n');
      return;
    else
      fprintf('OK\n');
    end
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  if CMP6
    [err daq] = retrieve_daq_data(ibfb, [2 2 0 2], plane, 1, t);
    
    % check FF+FB
    fprintf('  Comparing DAQ02 + DAQ12 == DAQ32 ...');
    kick_out = int32(zeros(2, smp));
    kick_out(1,:) = int32(daq.ch00.*int32(bt_p_del(1:smp)) + int32(FF_ON).*daq.ch10);
    kick_out(2,:) = int32(daq.ch01.*int32(bt_p_del(1:smp)) + int32(FF_ON).*daq.ch11);
    kick_out(1,1:d) = 0;
    kick_out(2,1:d) = 0;
    %kick_out(1,:) = int32(daq.ch00 + int32(FF_ON).*daq.ch10);
    %kick_out(2,:) = int32(daq.ch01 + int32(FF_ON).*daq.ch11);
    bunch = zeros(1, smp);
    bunch(1:bs:end) = 1;
    kick_out(1,:) = kick_out(1,:).*int32(bunch);
    kick_out(2,:) = kick_out(2,:).*int32(bunch);
    if vect_not_equal(kick_out(1,:), daq.ch30) | vect_not_equal(kick_out(2,:), daq.ch31)
      plot_wrong_waves(t, kick_out(1,:), daq.ch30, 'DAQ02+DAQ12', 'DAQ32');
      fprintf(2, 'ERROR: Waveforms do not match\n');
      return;
    else
      fprintf('OK\n');
    end

  end

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % set back old parameters
  ibfb.ctrl.y_trg_mode.put(uint32(0));

  if myplots
    figure(1)
    clf
    plot(rx_down_bpm1, 'b')
    hold on
    plot(daq.ch00, 'r')
    title(['Latency: ' num2str(d) ' buckets']);
    plot(daq.ch20, 'g')
    plot(daq.ch10, 'k')
    legend('RXDAQ0', 'DAQ00', 'DAQ22', 'DAQ10');
  end
  fprintf('done.\n')
  
end

function res = vect_not_equal(a, b)
  res = sum((a-b)>1e-6);
end

function plot_wrong_waves(t, w1, w2, leg1, leg2)
  figure(1)
  clf
  plot(t, w1, 'b')
  hold on
  plot(t, w2, 'r')
  legend(leg1, leg2)
  grid on
end

function plot_daq(t, daq, lgd)
  figure(2)
  clf
  subplot(2,2,1)
  plot(t, daq.ch00, 'r')
  hold on  
  plot(t, daq.ch10, 'g')
  plot(t, daq.ch20, 'b')
  grid on;
  legend(lgd{1}, lgd{2}, lgd{3});
  subplot(2,2,2)
  plot(t, daq.ch30, 'k');
  grid on;
  legend(lgd{4})
  
  subplot(2,2,3)
  plot(t, daq.ch01, 'r')
  hold on
  plot(t, daq.ch11, 'g')
  plot(t, daq.ch21, 'b')
  grid on;
  legend(lgd{1}, lgd{2}, lgd{3});
  subplot(2,2,4)
  plot(t, daq.ch31, 'k')
  grid on;
  legend(lgd{4})
end

function [err daq] = retrieve_daq_data(ibfb, mux, plane, pl, t)
  err=0;
  lgd = {['DAQ0' num2str(mux(1))], ['DAQ1' num2str(mux(2))], ['DAQ2' num2str(mux(3))], ['DAQ3' num2str(mux(4))]};
  fprintf('Retrevieng new data [%s %s %s %s]...\n', lgd{1}, lgd{2}, lgd{3}, lgd{4}) 
  ibfb.ctrl_daq_set_mux(plane, mux);
  pause(0.3);
  fprintf('  trigger once...\n');
  ibfb.ctrl.y_trg_single.put(uint32(1));
  pause(0.3);
  ibfb.ctrl.y_trg_single.put(uint32(0));
  pause(0.3);
  ibfb.ctrl.y_trg_single.put(uint32(1));
  pause(0.3);
  ibfb.ctrl.y_trg_single.put(uint32(0));
  pause(2);
  fprintf('  read DAQ data...\n');
  [err daq] = ibfb.ctrl_read_daq(plane);
  fprintf('done.\n'); 
  if pl
    plot_daq(t, daq, lgd)
  end
end