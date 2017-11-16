
%% program BPM data
%    play_gen_bpm_data(bpmidx,           offset, packets,  posx,  posy)
% Y plane
ibfb.play_gen_bpm_data(ibfb.BPMDOWNY1,       60,    10,  0.11, -0.1);
ibfb.play_gen_bpm_data(ibfb.BPMDOWNY2,       63,    10,  0.12, 0.2);
ibfb.play_gen_bpm_data(ibfb.BPMUPY1,         66,    10,  0.21, -0.21);
ibfb.play_gen_bpm_data(ibfb.BPMUPY2,         69,    10,  0.22, -0.22);
ibfb.play_gen_bpm_data(ibfb.BPMSASE1Y1,     232,   500,  1.11, -1.1);
ibfb.play_gen_bpm_data(ibfb.BPMSASE1Y2,     138,   500,  1.12,  0.8);
ibfb.play_gen_bpm_data(ibfb.BPMSASE2Y1,     142,   500,  1.11, -1.11);
ibfb.play_gen_bpm_data(ibfb.BPMSASE2Y2,     145,   500,  1.12, -1.12);
ibfb.play_gen_bpm_data(ibfb.BPMSASE3Y1,     232,   500,  1.11, -1.11);
ibfb.play_gen_bpm_data(ibfb.BPMSASE3Y2,     235,   500,  1.12, -1.12);
ibfb.play_gen_bpm_data(ibfb.BPMCOL1,        138,   500,  1.12, -1.12);

% X plane
ibfb.play_gen_bpm_data(ibfb.BPMDOWNX1,       38,    10,   2.3, -0.20);
ibfb.play_gen_bpm_data(ibfb.BPMDOWNX2,       41,    10,  -2.3,  0.50);
ibfb.play_gen_bpm_data(ibfb.BPMUPX1,         32,    10,  -2.3,  1.20);
ibfb.play_gen_bpm_data(ibfb.BPMUPX2,         35,    10,  -2.3,  1.20);
ibfb.play_gen_bpm_data(ibfb.BPMSASE1X1,     132,  500,  -2.3,  1.23);
ibfb.play_gen_bpm_data(ibfb.BPMSASE1X2,     135,  500,  -2.3,  1.33);
ibfb.play_gen_bpm_data(ibfb.BPMSASE2X1,     142,  500,  -2.3,  1.23);
ibfb.play_gen_bpm_data(ibfb.BPMSASE2X2,     145,  500,  -2.3,  1.33);
ibfb.play_gen_bpm_data(ibfb.BPMSASE3X1,     232,  500,  1.11, -1.11);
ibfb.play_gen_bpm_data(ibfb.BPMSASE3X2,     235,  500,  1.12, -1.12);

%% program players
% PLAY1 fast feedback Y plane
ibfb.play_program_mem(0, ibfb.SFPFASTFBY  , [ibfb.BPMDOWNY1 ibfb.BPMDOWNY2 ibfb.BPMUPY1 ibfb.BPMUPY2],   0);
ibfb.play_program_mem(0, ibfb.SFPFASTFBY  , [ibfb.BPMDOWNY1 ibfb.BPMDOWNY2 ],   0);
% PLAY1 - SASE1, SASE2
ibfb.play_program_mem(0, ibfb.SFPSASE1UP  , [ibfb.BPMSASE1Y1 ibfb.BPMSASE1Y2 ibfb.BPMSASE1Y2 ibfb.BPMSASE1X2],   0);
ibfb.play_program_mem(0, ibfb.SFPSASE1UP  , [ibfb.BPMSASE1Y1 ibfb.BPMSASE1Y2],   0);
ibfb.play_program_mem(0, ibfb.SFPSASE1UP  , [ibfb.BPMSASE1Y1 ],   0);
ibfb.play_program_mem(0, ibfb.SFPSASE1DOWN, [ibfb.BPMSASE1X1],   0);
ibfb.play_program_mem(0, ibfb.SFPSASE1UP  , [ibfb.BPMSASE1Y1 ibfb.BPMSASE1Y2],   0);
ibfb.play_program_mem(0, ibfb.SFPSASE1UP  , [ibfb.BPMSASE1Y1 ibfb.BPMSASE1Y2 ibfb.BPMSASE1X1],   0);
ibfb.play_program_mem(0, ibfb.SFPSASE1UP  , [ibfb.BPMSASE1Y1 ibfb.BPMSASE1Y2 ibfb.BPMSASE1X1 ibfb.BPMSASE1X2],   0);
ibfb.play_program_mem(0, ibfb.SFPSASE1DOWN, [ibfb.BPMSASE1Y1 ibfb.BPMSASE1Y2 ibfb.BPMSASE1X1 ibfb.BPMSASE1X2],   0);

ibfb.play_program_mem(0, ibfb.SFPSASE2UP  , [ibfb.BPMSASE2Y1],   0);
ibfb.play_program_mem(0, ibfb.SFPSASE2DOWN, [ibfb.BPMSASE2Y1],   0);
ibfb.play_program_mem(0, ibfb.SFPSASE2UP  , [ibfb.BPMSASE2Y1 ibfb.BPMSASE2Y2 ibfb.BPMSASE2X1 ibfb.BPMSASE2X2],   0);
ibfb.play_program_mem(0, ibfb.SFPSASE2DOWN, [ibfb.BPMSASE2Y1 ibfb.BPMSASE2Y2 ibfb.BPMSASE2X1 ibfb.BPMSASE2X2],   0);

% PLAY2 fast feedback X plane
ibfb.play_program_mem(1, ibfb.SFPFASTFBX  , [ibfb.BPMDOWNX1 ibfb.BPMDOWNX2 ibfb.BPMUPX1 ibfb.BPMUPX2],   0);
% PLAY2 - SASE3
ibfb.play_program_mem(1, ibfb.SFPSASE3UP  , [ibfb.BPMSASE3Y1 ibfb.BPMSASE3Y2 ibfb.BPMSASE3X1 ibfb.BPMSASE3X2],   0);
ibfb.play_program_mem(1, ibfb.SFPSASE3DOWN, [ibfb.BPMSASE3Y1 ibfb.BPMSASE3Y2 ibfb.BPMSASE3X1 ibfb.BPMSASE3X2],   0);
% PLAY2 - collimator
ibfb.play_program_mem(1, ibfb.SFPCOLLIMATOR, [ibfb.BPMCOL1],   0);

%% clear players
ibfb.play_program_mem(0, ibfb.SFPFASTFBY  , [], 0);

ibfb.play_program_mem(0, ibfb.SFPSASE1UP  , [], 0);
ibfb.play_program_mem(0, ibfb.SFPSASE1DOWN, [], 0);
ibfb.play_program_mem(0, ibfb.SFPSASE2UP  , [], 0);
ibfb.play_program_mem(0, ibfb.SFPSASE2DOWN, [], 0);
% 
ibfb.play_program_mem(1, ibfb.SFPFASTFBX   , [], 0);

ibfb.play_program_mem(1, ibfb.SFPSASE3UP   , [], 0);
ibfb.play_program_mem(1, ibfb.SFPSASE3DOWN , [], 0);
ibfb.play_program_mem(1, ibfb.SFPCOLLIMATOR, [], 0);

