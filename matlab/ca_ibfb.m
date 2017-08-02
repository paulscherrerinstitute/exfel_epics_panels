classdef ca_ibfb < handle
    
   properties (Constant = true)
      TRG_CONTINUOUS = 0;
      TRG_SINGLE = 1;
      XLS_SECTION = 1;
      XLS_NAME1 = 3;
      XLS_NAME2 = 4;
      XLS_GROUP = 5;
      XLS_TYPE = 7;
      XLS_X = 15;
      XLS_Y = 16;
      XLS_Z = 17;
      XLS_BETX = 28;
      XLS_ALFX = 29;
      XLS_MUX = 30;
      XLS_BETY = 31;
      XLS_ALFY = 32;
      XLS_MUY = 33;
      BPM_ID_CL = 10;
      BPM_ID_TL = 30;
      KICK_ID_KFBX = 50;
      KICK_ID_KFBY = 60;
      BPM_ID_SA1 = 12;
      BPM_ID_SA2 = 150;
      BPM_ID_SA3 = 200;
      ADC_RANGE = 32768;
      Fs = 1.3e9/6;
      LATTICE_FILE_NAME = 'XFEL_component_list_8.4.8.xls';
      EMITTANCE = 0.14e-6;
      EPICS_PLAY = 'IBFBPLAY:';
      EPICS_CTRL = 'IBFBCTRL:';
      EPICS_MON = 'IBFBMON:';
      EPICS_SW = 'IBFBSW:';
      BUCKET_SPACE = 48;
      BUCKET_NUMBER = 2700;
      PLAYER_EOP = int32(-16777216);
      VALID_X = int32(2^24);
      VALID_Y = int32(2^25);      
      SFPSASE1UP    = 0;
      SFPSASE2UP    = 1;
      SFPSASE1DOWN  = 2;
      SFPSASE2DOWN  = 3;
      SFPFASTFBY    = 4;
      SFPSASE3UP    = 0;
      SFPCOLLIMATOR = 1;
      SFPSASE3DOWN  = 2;
      SFPFASTFBX    = 4;
      KICKX1      =   1;
      KICKX2      =   2;
      KICKY1      =   3;
      KICKY2      =   4;;
      BPMUPY1     =   5;
      BPMUPX1     =   6;
      BPMUPY2     =   7;
      BPMUPX2     =   8;
      BPMDOWNY1   =   9;
      BPMDOWNX1   =  10;
      BPMDOWNY2   =  11;
      BPMDOWNX2   =  12;      
      BPMSASE1Y1  =  15;
      BPMSASE1X1  =  16;
      BPMSASE1Y2  =  17;
      BPMSASE1X2  =  18;
      BPMSASE2Y1  =  52;
      BPMSASE2X1  =  53;
      BPMSASE2Y2  =  54;
      BPMSASE2X2  =  55;
      BPMSASE3Y1  =  89;
      BPMSASE3X1  =  90;
      BPMSASE3Y2  =  91;
      BPMSASE3X2  =  92;
      BPMCOL1     = 113; 
   end

  properties (Access = private)
    hostname = '';
    context
    sw;    
    ff_tab1 = 0.0001;
    ff_tab2 = 0.0001;
    use_player = 0;
  end
   
   properties 
      ctrl;
      play;
      bpms;
      xls
      mon;
      mem;
      doocs;
      bpm_e;
   end

  methods
    % Constructor of class
    function obj = ca_ibfb(context)
      import ch.psi.jcae.*;

      obj.context = context;
      [res, obj.hostname] = system('hostname');
            
      fprintf('Initializing IBFB object...\n');

      if strncmp(obj.hostname, 'xfelpsiibfb', 11)
        addpath('/local/lib');
      else
        obj.use_player = 1;
      end
      
      % inittialize filter used to search for the components in the Excel sheet
      obj.xls.filters(1).section = 'TL';
      obj.xls.filters(1).group = 'FASTKICK';
      obj.xls.filters(1).type = 'KFBX';
      obj.xls.filters(2).section = 'TL';
      obj.xls.filters(2).group = 'FASTKICK';
      obj.xls.filters(2).type = 'KFBY';
      obj.xls.filters(3).section = 'TL';
      obj.xls.filters(3).group = 'DIAG';
      obj.xls.filters(3).type = 'BPMI';
      obj.xls.filters(4).section = 'SA1';
      obj.xls.filters(4).group = 'DIAG';
      obj.xls.filters(4).type = 'BPME';
      obj.xls.filters(5).section = 'SA2';
      obj.xls.filters(5).group = 'DIAG';
      obj.xls.filters(5).type = 'BPME';
      obj.xls.filters(6).section = 'SA3';
      obj.xls.filters(6).group = 'DIAG';
      obj.xls.filters(6).type = 'BPME';      
      obj.xls.filters(7).section = 'CL';
      obj.xls.filters(7).group = 'DIAG';
      obj.xls.filters(7).type = 'BPMI';
      
      
      % this is initial assigment of BPMs ID numbers which are allowed
      % to transmit position
      % These values can be changed in the controller in run-time
      %obj.bpms(obj.BPMCOL1   ).bpmid = 60;
      %obj.bpms(obj.BPMUPY1   ).bpmid = 40;
      %obj.bpms(obj.BPMUPX1   ).bpmid = 42;
      %obj.bpms(obj.BPMUPY2   ).bpmid = 41;
      %obj.bpms(obj.BPMUPX2   ).bpmid = 43;
      %obj.bpms(obj.BPMDOWNY1 ).bpmid = 50;
      %obj.bpms(obj.BPMDOWNX1 ).bpmid = 52;
      %obj.bpms(obj.BPMDOWNY2 ).bpmid = 51;
      %obj.bpms(obj.BPMDOWNX2 ).bpmid = 53;
      %obj.bpms(obj.BPMSASE1X1).bpmid = 12;
      %obj.bpms(obj.BPMSASE1X2).bpmid = 13;
      %obj.bpms(obj.BPMSASE2X1).bpmid = 22;
      %obj.bpms(obj.BPMSASE2X2).bpmid = 23;
      %obj.bpms(obj.BPMSASE3X1).bpmid = 32;
      %obj.bpms(obj.BPMSASE3X2).bpmid = 33;
      %obj.bpms(obj.BPMSASE1Y1).bpmid = 10;
      %obj.bpms(obj.BPMSASE1Y2).bpmid = 11;
      %obj.bpms(obj.BPMSASE2Y1).bpmid = 20;
      %obj.bpms(obj.BPMSASE2Y2).bpmid = 21;
      %obj.bpms(obj.BPMSASE3Y1).bpmid = 30;
      %obj.bpms(obj.BPMSASE3Y2).bpmid = 31;
      %obj.bpms(obj.KICKY1).bpmid = 1;
      %obj.bpms(obj.KICKY2).bpmid = 2;
      %obj.bpms(obj.KICKX1).bpmid = 3;
      %obj.bpms(obj.KICKX2).bpmid = 4;
      %
      %obj.bpms(obj.BPMCOL1   ).name  = 'BPMI.1837.CL';
      %obj.bpms(obj.BPMCOL1   ).plane = 'Y';
      %obj.bpms(obj.BPMUPY1   ).name  = 'BPMI.1860.TL';
      %obj.bpms(obj.BPMUPY1   ).plane = 'Y';
      %obj.bpms(obj.BPMUPX1   ).name  = 'BPMI.1863.TL';
      %obj.bpms(obj.BPMUPX1   ).plane = 'X';
      %obj.bpms(obj.BPMUPY2   ).name  = 'BPMI.1878.TL';
      %obj.bpms(obj.BPMUPY2   ).plane = 'Y';
      %obj.bpms(obj.BPMUPX2   ).name  = 'BPMI.1889.TL';
      %obj.bpms(obj.BPMUPX2   ).plane = 'X';
      %obj.bpms(obj.BPMDOWNY1 ).name  = 'BPMI.1910.TL';
      %obj.bpms(obj.BPMDOWNY1 ).plane = 'Y';
      %obj.bpms(obj.BPMDOWNX1 ).name  = 'BPMI.1925.TL';
      %obj.bpms(obj.BPMDOWNX1 ).plane = 'X';
      %obj.bpms(obj.BPMDOWNY2 ).name  = 'BPMI.1930.TL';
      %obj.bpms(obj.BPMDOWNY2 ).plane = 'Y';
      %obj.bpms(obj.BPMDOWNX2 ).name  = 'BPMI.1939.TL';
      %obj.bpms(obj.BPMDOWNX2 ).plane = 'X';
      %
      %obj.bpms(obj.BPMSASE1X1).name   = 'BPME.2247.SA1';
      %obj.bpms(obj.BPMSASE1X1 ).plane = 'X';
      %obj.bpms(obj.BPMSASE1X2).name   = 'BPME.2259.SA1';
      %obj.bpms(obj.BPMSASE1X2 ).plane = 'X';
      %obj.bpms(obj.BPMSASE1Y1).name   = 'BPME.2241.SA1';
      %obj.bpms(obj.BPMSASE1Y1 ).plane = 'Y';
      %obj.bpms(obj.BPMSASE1Y2).name   = 'BPME.2253.SA1';
      %obj.bpms(obj.BPMSASE1Y2 ).plane = 'Y';
      %
      %obj.bpms(obj.BPMSASE2X1).name   = 'BPME.2209.SA2';
      %obj.bpms(obj.BPMSASE2X1 ).plane = 'X';
      %obj.bpms(obj.BPMSASE2Y1).name   = 'BPME.2221.SA2';
      %obj.bpms(obj.BPMSASE2Y1 ).plane = 'Y';
      %obj.bpms(obj.BPMSASE2X2).name   = 'BPME.2203.SA2';
      %obj.bpms(obj.BPMSASE2X2 ).plane = 'X';
      %obj.bpms(obj.BPMSASE2Y2).name   = 'BPME.2215.SA2';
      %obj.bpms(obj.BPMSASE2Y2 ).plane = 'Y';
      %
      %obj.bpms(obj.BPMSASE3X1).name   = 'BPME.2812.SA3';    
      %obj.bpms(obj.BPMSASE3X1 ).plane = 'X';
      %obj.bpms(obj.BPMSASE3Y1).name   = 'BPME.2824.SA3';    
      %obj.bpms(obj.BPMSASE3Y1 ).plane = 'Y';
      %obj.bpms(obj.BPMSASE3X2).name   = 'BPME.2806.SA3';    
      %obj.bpms(obj.BPMSASE3X2 ).plane = 'X';
      %obj.bpms(obj.BPMSASE3Y2).name   = 'BPME.2818.SA3';    
      %obj.bpms(obj.BPMSASE3Y2 ).plane = 'Y';
      %
      %obj.bpms(obj.KICKY1).name      = 'KFBY.1883.TL';    
      %obj.bpms(obj.KICKY1).plane     = 'Y';
      %obj.bpms(obj.KICKY2).name      = 'KFBY.1908.TL';    
      %obj.bpms(obj.KICKY2).plane     = 'Y';
      %obj.bpms(obj.KICKX1).name      = 'KFBX.1893.TL';    
      %obj.bpms(obj.KICKX1).plane     = 'X';
      %obj.bpms(obj.KICKX2).name      = 'KFBX.1923.TL';    
      %obj.bpms(obj.KICKX2).plane     = 'X';
      
      % Open Excel sheet with XFEL lattice and find the components by
      % name. Read all necessary parameters
      fprintf('  reading lattice parameters...');
      res = lattice_find_components_in_xfel_list(obj);
      if res
          errmsg = sprintf('ERROR %d: Cannot load lattice parameters', res);
          error(errmsg);
          return;
      end
      lattice_process(obj);
      %fprintf('done\n');
      
      for i=1:length(obj.bpms)
          obj.bpms(i).packets.num = 0;
          obj.bpms(i).packets.timestamp = zeros(1, obj.BUCKET_NUMBER);
          obj.bpms(i).packets.control = zeros(1, obj.BUCKET_NUMBER);
          obj.bpms(i).packets.x = zeros(1, obj.BUCKET_NUMBER);
          obj.bpms(i).packets.y = zeros(1, obj.BUCKET_NUMBER);
      end
      
      obj.play.trgdel = 65536;
      % open EPICS channels
      fprintf('  initializing EPICS channel access...');
      %%  BPMs %%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
      if strncmp(obj.hostname, 'xfelpsiibfb', 12) % we are at DESY
        obj.bpm_e.bpmi_1925_tl_wav_x     = Channels.create(context, ChannelDescriptor('float[]'   , ['BPMI-1925-TL:WAV-X'     ]));
        obj.bpm_e.bpmi_1939_tl_wav_x     = Channels.create(context, ChannelDescriptor('float[]'   , ['BPMI-1939-TL:WAV-X'     ]));
        obj.bpm_e.bpmi_1910_tl_wav_y     = Channels.create(context, ChannelDescriptor('float[]'   , ['BPMI-1910-TL:WAV-Y'     ]));
        obj.bpm_e.bpmi_1930_tl_wav_y     = Channels.create(context, ChannelDescriptor('float[]'   , ['BPMI-1930-TL:WAV-Y'     ]));
        obj.bpm_e.bpmi_1925_tl_wav_y     = Channels.create(context, ChannelDescriptor('float[]'   , ['BPMI-1925-TL:WAV-Y'     ]));
        obj.bpm_e.bpmi_1939_tl_wav_y     = Channels.create(context, ChannelDescriptor('float[]'   , ['BPMI-1939-TL:WAV-Y'     ]));
        obj.bpm_e.bpmi_1910_tl_wav_x     = Channels.create(context, ChannelDescriptor('float[]'   , ['BPMI-1910-TL:WAV-X'     ]));
        obj.bpm_e.bpmi_1930_tl_wav_x     = Channels.create(context, ChannelDescriptor('float[]'   , ['BPMI-1930-TL:WAV-X'     ]));
      end
      
      %%  CONTROLLER  %%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
      %          COMMON             %
      %obj.ctrl.xfeltim_      = Channels.create(context, ChannelDescriptor('integer'   , [obj.EPICS_CTRL 'Y-UPDOWN-PACKETS'      ]));
      %             Y               %
      obj.ctrl.y_updown_packets      = Channels.create(context, ChannelDescriptor('integer'   , [obj.EPICS_CTRL 'Y-UPDOWN-PACKETS'      ]));
      obj.ctrl.y_sase_packets        = Channels.create(context, ChannelDescriptor('integer'   , [obj.EPICS_CTRL 'Y-SASE-PACKETS'        ]));
      obj.ctrl.y_ff_fast_mode        = Channels.create(context, ChannelDescriptor('integer'   , [obj.EPICS_CTRL 'Y-FF-FAST-MODE'        ]));
      obj.ctrl.y_fb_cmd              = Channels.create(context, ChannelDescriptor('integer'   , [obj.EPICS_CTRL 'Y-FB-CMD'              ]));
      obj.ctrl.y_ff_table_cnt        = Channels.create(context, ChannelDescriptor('integer'   , [obj.EPICS_CTRL 'Y-FF-TABLE-CNT'        ]));
      %obj.ctrl.y_kick1_p_pattern     = Channels.create(context, ChannelDescriptor('integer[]' , [obj.EPICS_CTRL 'Y-KICK1-P-PATTERN'     ]));
      %obj.ctrl.y_kick1_n_pattern     = Channels.create(context, ChannelDescriptor('integer[]' , [obj.EPICS_CTRL 'Y-KICK1-N-PATTERN'     ]));
      %obj.ctrl.y_kick2_p_pattern     = Channels.create(context, ChannelDescriptor('integer[]' , [obj.EPICS_CTRL 'Y-KICK2-P-PATTERN'     ]));
      %obj.ctrl.y_kick2_n_pattern     = Channels.create(context, ChannelDescriptor('integer[]' , [obj.EPICS_CTRL 'Y-KICK2-N-PATTERN'     ]));
      obj.ctrl.y_dac_wave_freq_2     = Channels.create(context, ChannelDescriptor('float'     , [obj.EPICS_CTRL 'Y-DAC-WAVE-FREQ-2'     ]));
      obj.ctrl.y_dac_pattern_apply   = Channels.create(context, ChannelDescriptor('integer'   , [obj.EPICS_CTRL 'Y-DAC-PATTERN-APPLY'   ]));
      obj.ctrl.y_dcm_ps_cmd          = Channels.create(context, ChannelDescriptor('integer'   , [obj.EPICS_CTRL 'Y-DCM-PS-CMD'          ]));
      obj.ctrl.y_dac_mode_m          = Channels.create(context, ChannelDescriptor('integer'   , [obj.EPICS_CTRL 'Y-DAC-MODE-M'          ]));
      obj.ctrl.y_bpm1_up_pos_wav     = Channels.create(context, ChannelDescriptor('float'     , [obj.EPICS_CTRL 'Y-BPM1-UP-POS-WAV'     ]));
      obj.ctrl.y_bpm2_up_pos_wav     = Channels.create(context, ChannelDescriptor('float'     , [obj.EPICS_CTRL 'Y-BPM2-UP-POS-WAV'     ]));
      obj.ctrl.y_bpm1_down_pos_wav   = Channels.create(context, ChannelDescriptor('float[]'   , [obj.EPICS_CTRL 'Y-BPM1-DOWN-POS-WAV'   ]));
      obj.ctrl.y_bpm2_down_pos_wav   = Channels.create(context, ChannelDescriptor('float[]'   , [obj.EPICS_CTRL 'Y-BPM2-DOWN-POS-WAV'   ]));
      obj.ctrl.y_col_pos_wav         = Channels.create(context, ChannelDescriptor('float'     , [obj.EPICS_CTRL 'Y-COL-POS-WAV'         ]));
      obj.ctrl.y_bpm1_up_valid_wav   = Channels.create(context, ChannelDescriptor('integer'   , [obj.EPICS_CTRL 'Y-BPM1-UP-VALID-WAV'   ]));
      obj.ctrl.y_bpm2_up_valid_wav   = Channels.create(context, ChannelDescriptor('integer'   , [obj.EPICS_CTRL 'Y-BPM2-UP-VALID-WAV'   ]));
      obj.ctrl.y_bpm1_down_valid_wav = Channels.create(context, ChannelDescriptor('integer'   , [obj.EPICS_CTRL 'Y-BPM1-DOWN-VALID-WAV' ]));
      obj.ctrl.y_bpm2_down_valid_wav = Channels.create(context, ChannelDescriptor('integer'   , [obj.EPICS_CTRL 'Y-BPM2-DOWN-VALID-WAV' ]));
      obj.ctrl.y_col_valid_wav       = Channels.create(context, ChannelDescriptor('float'     , [obj.EPICS_CTRL 'Y-COL-VALID-WAV'       ]));
      obj.ctrl.y_kick1_out_wav       = Channels.create(context, ChannelDescriptor('integer'   , [obj.EPICS_CTRL 'Y-KICK1-WAV'           ]));
      obj.ctrl.y_kick2_out_wav       = Channels.create(context, ChannelDescriptor('integer'   , [obj.EPICS_CTRL 'Y-KICK2-WAV'           ]));
      obj.ctrl.y_xfeltim_pulse       = Channels.create(context, ChannelDescriptor('integer'   , [obj.EPICS_CTRL 'Y-XFELTIM-PULSE'       ]));
      obj.ctrl.y_trg_mode            = Channels.create(context, ChannelDescriptor('integer'   , [obj.EPICS_CTRL 'Y-TRG-MODE'            ]));
      obj.ctrl.y_trg_single          = Channels.create(context, ChannelDescriptor('integer'   , [obj.EPICS_CTRL 'Y-TRG-SINGLE'          ]));
      obj.ctrl.y_trg_del             = Channels.create(context, ChannelDescriptor('integer'   , [obj.EPICS_CTRL 'Y-TRG-DEL'             ]));
      obj.ctrl.y_daq_mux0            = Channels.create(context, ChannelDescriptor('integer'   , [obj.EPICS_CTRL 'Y-DAQ-MUX0'            ]));
      obj.ctrl.y_daq_mux1            = Channels.create(context, ChannelDescriptor('integer'   , [obj.EPICS_CTRL 'Y-DAQ-MUX1'            ]));
      obj.ctrl.y_daq_mux2            = Channels.create(context, ChannelDescriptor('integer'   , [obj.EPICS_CTRL 'Y-DAQ-MUX2'            ]));
      obj.ctrl.y_daq_mux3            = Channels.create(context, ChannelDescriptor('integer'   , [obj.EPICS_CTRL 'Y-DAQ-MUX3'            ]));
      obj.ctrl.y_fb_sp_pos           = Channels.create(context, ChannelDescriptor('float'     , [obj.EPICS_CTRL 'Y-FB-SP-POS'           ]));
      obj.ctrl.y_fb_sp_angle         = Channels.create(context, ChannelDescriptor('float'     , [obj.EPICS_CTRL 'Y-FB-SP-ANGLE'         ]));     
      obj.ctrl.y_daq_ch00            = Channels.create(context, ChannelDescriptor('float[]'   , [obj.EPICS_CTRL 'Y-DAQ-CH00'            ]));
      obj.ctrl.y_daq_ch01            = Channels.create(context, ChannelDescriptor('float[]'   , [obj.EPICS_CTRL 'Y-DAQ-CH01'            ]));
      obj.ctrl.y_daq_ch10            = Channels.create(context, ChannelDescriptor('float[]'   , [obj.EPICS_CTRL 'Y-DAQ-CH10'            ]));
      obj.ctrl.y_daq_ch11            = Channels.create(context, ChannelDescriptor('float[]'   , [obj.EPICS_CTRL 'Y-DAQ-CH11'            ]));
      obj.ctrl.y_daq_ch00_int        = Channels.create(context, ChannelDescriptor('integer[]' , [obj.EPICS_CTRL 'Y-DAQ-CH00-INT'        ]));
      obj.ctrl.y_daq_ch01_int        = Channels.create(context, ChannelDescriptor('integer[]' , [obj.EPICS_CTRL 'Y-DAQ-CH01-INT'        ]));
      obj.ctrl.y_daq_ch10_int        = Channels.create(context, ChannelDescriptor('integer[]' , [obj.EPICS_CTRL 'Y-DAQ-CH10-INT'        ]));
      obj.ctrl.y_daq_ch11_int        = Channels.create(context, ChannelDescriptor('integer[]' , [obj.EPICS_CTRL 'Y-DAQ-CH11-INT'        ]));
      obj.ctrl.y_daq_ch20            = Channels.create(context, ChannelDescriptor('float[]'   , [obj.EPICS_CTRL 'Y-DAQ-CH20'            ]));
      obj.ctrl.y_daq_ch21            = Channels.create(context, ChannelDescriptor('float[]'   , [obj.EPICS_CTRL 'Y-DAQ-CH21'            ]));
      obj.ctrl.y_daq_ch30_int        = Channels.create(context, ChannelDescriptor('integer[]' , [obj.EPICS_CTRL 'Y-DAQ-CH30-INT'        ]));
      obj.ctrl.y_daq_ch31_int        = Channels.create(context, ChannelDescriptor('integer[]' , [obj.EPICS_CTRL 'Y-DAQ-CH31-INT'        ]));
      obj.ctrl.y_rx_down_bpm1        = Channels.create(context, ChannelDescriptor('float[]'   , [obj.EPICS_CTRL 'Y-RX-DOWN-BPM1'        ]));
      obj.ctrl.y_rx_down_bpm2        = Channels.create(context, ChannelDescriptor('float[]'   , [obj.EPICS_CTRL 'Y-RX-DOWN-BPM2'        ]));
      obj.ctrl.y_sase1_bucket_start  = Channels.create(context, ChannelDescriptor('integer'   , [obj.EPICS_CTRL 'Y-SASE1-BUCKET-START'  ]));
      obj.ctrl.y_sase1_bucket_stop   = Channels.create(context, ChannelDescriptor('integer'   , [obj.EPICS_CTRL 'Y-SASE1-BUCKET-STOP'   ]));
      obj.ctrl.y_sase1_bunch_space   = Channels.create(context, ChannelDescriptor('integer'   , [obj.EPICS_CTRL 'Y-SASE1-BUNCH-SPACE'   ]));
      obj.ctrl.y_sase1_bunch_num     = Channels.create(context, ChannelDescriptor('integer'   , [obj.EPICS_CTRL 'Y-SASE1-BUNCH-NUM'     ]));
      obj.ctrl.y_sase2_bucket_start  = Channels.create(context, ChannelDescriptor('integer'   , [obj.EPICS_CTRL 'Y-SASE2-BUCKET-START'  ]));
      obj.ctrl.y_sase2_bucket_stop   = Channels.create(context, ChannelDescriptor('integer'   , [obj.EPICS_CTRL 'Y-SASE2-BUCKET-STOP'   ]));
      obj.ctrl.y_sase2_bunch_space   = Channels.create(context, ChannelDescriptor('integer'   , [obj.EPICS_CTRL 'Y-SASE2-BUNCH-SPACE'   ]));
      obj.ctrl.y_sase2_bunch_num     = Channels.create(context, ChannelDescriptor('integer'   , [obj.EPICS_CTRL 'Y-SASE2-BUNCH-NUM'     ]));
      obj.ctrl.y_sase3_bucket_start  = Channels.create(context, ChannelDescriptor('integer'   , [obj.EPICS_CTRL 'Y-SASE3-BUCKET-START'  ]));
      obj.ctrl.y_sase3_bucket_stop   = Channels.create(context, ChannelDescriptor('integer'   , [obj.EPICS_CTRL 'Y-SASE3-BUCKET-STOP'   ]));
      obj.ctrl.y_sase3_bunch_space   = Channels.create(context, ChannelDescriptor('integer'   , [obj.EPICS_CTRL 'Y-SASE3-BUNCH-SPACE'   ]));
      obj.ctrl.y_sase3_bunch_num     = Channels.create(context, ChannelDescriptor('integer'   , [obj.EPICS_CTRL 'Y-SASE3-BUNCH-NUM'     ]));
      obj.ctrl.y_fast_fb_del         = Channels.create(context, ChannelDescriptor('integer'   , [obj.EPICS_CTRL 'Y-FAST-FB-DEL'         ]));
      obj.ctrl.y_fb_fast_ki          = Channels.create(context, ChannelDescriptor('float'     , [obj.EPICS_CTRL 'Y-FB-FAST-KI'          ]));     
      obj.ctrl.y_fb_fast_kp          = Channels.create(context, ChannelDescriptor('float'     , [obj.EPICS_CTRL 'Y-FB-FAST-KP'          ]));     
      obj.ctrl.y_fb_kicker_m11       = Channels.create(context, ChannelDescriptor('float'     , [obj.EPICS_CTRL 'Y-FB-KICKER-M11'       ]));     
      obj.ctrl.y_fb_kicker_m12       = Channels.create(context, ChannelDescriptor('float'     , [obj.EPICS_CTRL 'Y-FB-KICKER-M12'       ]));     
      obj.ctrl.y_fb_kicker_m21       = Channels.create(context, ChannelDescriptor('float'     , [obj.EPICS_CTRL 'Y-FB-KICKER-M21'       ]));     
      obj.ctrl.y_fb_kicker_m22       = Channels.create(context, ChannelDescriptor('float'     , [obj.EPICS_CTRL 'Y-FB-KICKER-M22'       ]));     
      obj.ctrl.y_fb_fast_on          = Channels.create(context, ChannelDescriptor('integer'   , [obj.EPICS_CTRL 'Y-FB-FAST-ON'          ]));
      obj.ctrl.y_ff_fast_on          = Channels.create(context, ChannelDescriptor('integer'   , [obj.EPICS_CTRL 'Y-FF-FAST-ON'          ]));
      obj.ctrl.y_fb_params_mode      = Channels.create(context, ChannelDescriptor('integer'   , [obj.EPICS_CTRL 'Y-FB-PARAMS-MODE'      ]));
      obj.ctrl.y_ff_table_pos        = Channels.create(context, ChannelDescriptor('float[]'   , [obj.EPICS_CTRL 'Y-FF-TABLE-POS'        ]));
      obj.ctrl.y_ff_table_angle      = Channels.create(context, ChannelDescriptor('float[]'   , [obj.EPICS_CTRL 'Y-FF-TABLE-ANGLE'      ]));
      obj.ctrl.y_kick1_p_pattern     = Channels.create(context, ChannelDescriptor('integer[]' , [obj.EPICS_CTRL 'Y-KICK1-P-PATTERN'     ]));
      obj.ctrl.y_kick1_n_pattern     = Channels.create(context, ChannelDescriptor('integer[]' , [obj.EPICS_CTRL 'Y-KICK1-N-PATTERN'     ]));
      obj.ctrl.y_kick2_p_pattern     = Channels.create(context, ChannelDescriptor('integer[]' , [obj.EPICS_CTRL 'Y-KICK2-P-PATTERN'     ]));
      obj.ctrl.y_kick2_n_pattern     = Channels.create(context, ChannelDescriptor('integer[]' , [obj.EPICS_CTRL 'Y-KICK2-N-PATTERN'     ]));
      obj.ctrl.y_fb_i_smp_apply      = Channels.create(context, ChannelDescriptor('integer'   , [obj.EPICS_CTRL 'Y-FB-I-SMP-APPLY'      ]));
      obj.ctrl.y_fb_i_smp_shift      = Channels.create(context, ChannelDescriptor('integer'   , [obj.EPICS_CTRL 'Y-FB-I-SMP-SHIFT'      ]));
      %             X               %
      obj.ctrl.x_updown_packets      = Channels.create(context, ChannelDescriptor('integer'   , [obj.EPICS_CTRL 'X-UPDOWN-PACKETS'      ]));
      obj.ctrl.x_sase_packets        = Channels.create(context, ChannelDescriptor('integer'   , [obj.EPICS_CTRL 'X-SASE-PACKETS'        ]));
      obj.ctrl.x_ff_fast_mode        = Channels.create(context, ChannelDescriptor('integer'   , [obj.EPICS_CTRL 'X-FF-FAST-MODE'        ]));
      obj.ctrl.x_fb_cmd              = Channels.create(context, ChannelDescriptor('integer'   , [obj.EPICS_CTRL 'X-FB-CMD'              ]));
      obj.ctrl.x_ff_table_cnt        = Channels.create(context, ChannelDescriptor('integer'   , [obj.EPICS_CTRL 'X-FF-TABLE-CNT'        ]));
      obj.ctrl.x_ff_table_pos        = Channels.create(context, ChannelDescriptor('float[]'   , [obj.EPICS_CTRL 'X-FF-TABLE-POS'        ]));
      obj.ctrl.x_ff_table_angle      = Channels.create(context, ChannelDescriptor('float[]'   , [obj.EPICS_CTRL 'X-FF-TABLE-ANGLE'      ]));
      %obj.ctrl.x_kick1_p_pattern     = Channels.create(context, ChannelDescriptor('float[]'   , [obj.EPICS_CTRL 'X-KICK1-P-PATTERN'     ]));
      %obj.ctrl.x_kick1_n_pattern     = Channels.create(context, ChannelDescriptor('float[]'   , [obj.EPICS_CTRL 'X-KICK1-N-PATTERN'     ]));
      %obj.ctrl.x_kick2_p_pattern     = Channels.create(context, ChannelDescriptor('float[]'   , [obj.EPICS_CTRL 'X-KICK2-P-PATTERN'     ]));
      %obj.ctrl.x_kick2_n_pattern     = Channels.create(context, ChannelDescriptor('float[]'   , [obj.EPICS_CTRL 'X-KICK2-N-PATTERN'     ]));
      obj.ctrl.x_dac_pattern_apply   = Channels.create(context, ChannelDescriptor('integer'   , [obj.EPICS_CTRL 'X-DAC-PATTERN-APPLY'   ]));
      obj.ctrl.x_dcm_ps_cmd          = Channels.create(context, ChannelDescriptor('integer'   , [obj.EPICS_CTRL 'X-DCM-PS-CMD'          ]));
      obj.ctrl.x_dac_mode_m          = Channels.create(context, ChannelDescriptor('integer'   , [obj.EPICS_CTRL 'X-DAC-MODE-M'          ]));
      obj.ctrl.x_bpm1_up_pos_wav     = Channels.create(context, ChannelDescriptor('float'     , [obj.EPICS_CTRL 'X-BPM1-UP-POS-WAV'     ]));
      obj.ctrl.x_bpm2_up_pos_wav     = Channels.create(context, ChannelDescriptor('float'     , [obj.EPICS_CTRL 'X-BPM2-UP-POS-WAV'     ]));
      obj.ctrl.x_bpm1_down_pos_wav   = Channels.create(context, ChannelDescriptor('float[]'   , [obj.EPICS_CTRL 'X-BPM1-DOWN-POS-WAV'   ]));
      obj.ctrl.x_bpm2_down_pos_wav   = Channels.create(context, ChannelDescriptor('float[]'   , [obj.EPICS_CTRL 'X-BPM2-DOWN-POS-WAV'   ]));
      obj.ctrl.x_bpm1_up_valid_wav   = Channels.create(context, ChannelDescriptor('integer'   , [obj.EPICS_CTRL 'X-BPM1-UP-VALID-WAV'   ]));
      obj.ctrl.x_bpm2_up_valid_wav   = Channels.create(context, ChannelDescriptor('integer'   , [obj.EPICS_CTRL 'X-BPM2-UP-VALID-WAV'   ]));
      obj.ctrl.x_bpm1_down_valid_wav = Channels.create(context, ChannelDescriptor('integer'   , [obj.EPICS_CTRL 'X-BPM1-DOWN-VALID-WAV' ]));
      obj.ctrl.x_bpm2_down_valid_wav = Channels.create(context, ChannelDescriptor('integer'   , [obj.EPICS_CTRL 'X-BPM2-DOWN-VALID-WAV' ]));
      obj.ctrl.x_kick1_out_wav       = Channels.create(context, ChannelDescriptor('integer'   , [obj.EPICS_CTRL 'X-KICK1-WAV'           ]));
      obj.ctrl.x_kick2_out_wav       = Channels.create(context, ChannelDescriptor('integer'   , [obj.EPICS_CTRL 'X-KICK2-WAV'           ]));
      obj.ctrl.x_xfeltim_pulse       = Channels.create(context, ChannelDescriptor('integer'   , [obj.EPICS_CTRL 'X-XFELTIM-PULSE'       ]));
      obj.ctrl.x_trg_mode            = Channels.create(context, ChannelDescriptor('integer'   , [obj.EPICS_CTRL 'X-TRG-MODE'            ]));
      obj.ctrl.x_trg_single          = Channels.create(context, ChannelDescriptor('integer'   , [obj.EPICS_CTRL 'X-TRG-SINGLE'          ]));
      obj.ctrl.x_trg_del             = Channels.create(context, ChannelDescriptor('integer'   , [obj.EPICS_CTRL 'X-TRG-DEL'             ]));
      obj.ctrl.x_daq_mux0            = Channels.create(context, ChannelDescriptor('integer'   , [obj.EPICS_CTRL 'X-DAQ-MUX0'            ]));
      obj.ctrl.x_daq_mux1            = Channels.create(context, ChannelDescriptor('integer'   , [obj.EPICS_CTRL 'X-DAQ-MUX1'            ]));
      obj.ctrl.x_daq_mux2            = Channels.create(context, ChannelDescriptor('integer'   , [obj.EPICS_CTRL 'X-DAQ-MUX2'            ]));
      obj.ctrl.x_daq_mux3            = Channels.create(context, ChannelDescriptor('integer'   , [obj.EPICS_CTRL 'X-DAQ-MUX3'            ]));
      obj.ctrl.x_fb_sp_pos           = Channels.create(context, ChannelDescriptor('float'     , [obj.EPICS_CTRL 'X-FB-SP-POS'           ]));
      obj.ctrl.x_fb_sp_angle         = Channels.create(context, ChannelDescriptor('float'     , [obj.EPICS_CTRL 'X-FB-SP-ANGLE'         ]));
      obj.ctrl.x_daq_ch00            = Channels.create(context, ChannelDescriptor('float[]'   , [obj.EPICS_CTRL 'X-DAQ-CH00'            ]));
      obj.ctrl.x_daq_ch01            = Channels.create(context, ChannelDescriptor('float[]'   , [obj.EPICS_CTRL 'X-DAQ-CH01'            ]));
      obj.ctrl.x_daq_ch10            = Channels.create(context, ChannelDescriptor('float[]'   , [obj.EPICS_CTRL 'X-DAQ-CH10'            ]));
      obj.ctrl.x_daq_ch11            = Channels.create(context, ChannelDescriptor('float[]'   , [obj.EPICS_CTRL 'X-DAQ-CH11'            ]));
      obj.ctrl.x_daq_ch00_int        = Channels.create(context, ChannelDescriptor('integer[]' , [obj.EPICS_CTRL 'X-DAQ-CH00-INT'        ]));
      obj.ctrl.x_daq_ch01_int        = Channels.create(context, ChannelDescriptor('integer[]' , [obj.EPICS_CTRL 'X-DAQ-CH01-INT'        ]));
      obj.ctrl.x_daq_ch10_int        = Channels.create(context, ChannelDescriptor('integer[]' , [obj.EPICS_CTRL 'X-DAQ-CH10-INT'        ]));
      obj.ctrl.x_daq_ch11_int        = Channels.create(context, ChannelDescriptor('integer[]' , [obj.EPICS_CTRL 'X-DAQ-CH11-INT'        ]));
      obj.ctrl.x_daq_ch20            = Channels.create(context, ChannelDescriptor('float[]'   , [obj.EPICS_CTRL 'X-DAQ-CH20'            ]));
      obj.ctrl.x_daq_ch21            = Channels.create(context, ChannelDescriptor('float[]'   , [obj.EPICS_CTRL 'X-DAQ-CH21'            ]));
      obj.ctrl.x_daq_ch30_int        = Channels.create(context, ChannelDescriptor('integer[]' , [obj.EPICS_CTRL 'X-DAQ-CH30-INT'        ]));
      obj.ctrl.x_daq_ch31_int        = Channels.create(context, ChannelDescriptor('integer[]' , [obj.EPICS_CTRL 'X-DAQ-CH31-INT'        ]));
      obj.ctrl.x_rx_down_bpm1        = Channels.create(context, ChannelDescriptor('float[]'   , [obj.EPICS_CTRL 'X-RX-DOWN-BPM1'        ]));
      obj.ctrl.x_rx_down_bpm2        = Channels.create(context, ChannelDescriptor('float[]'   , [obj.EPICS_CTRL 'X-RX-DOWN-BPM2'        ]));
      obj.ctrl.x_sase1_bucket_start  = Channels.create(context, ChannelDescriptor('integer'   , [obj.EPICS_CTRL 'X-SASE1-BUCKET-START'  ]));
      obj.ctrl.x_sase1_bucket_stop   = Channels.create(context, ChannelDescriptor('integer'   , [obj.EPICS_CTRL 'X-SASE1-BUCKET-STOP'   ]));
      obj.ctrl.x_sase1_bunch_space   = Channels.create(context, ChannelDescriptor('integer'   , [obj.EPICS_CTRL 'X-SASE1-BUNCH-SPACE'   ]));
      obj.ctrl.x_sase1_bunch_num     = Channels.create(context, ChannelDescriptor('integer'   , [obj.EPICS_CTRL 'X-SASE1-BUNCH-NUM'     ]));
      obj.ctrl.x_sase2_bucket_start  = Channels.create(context, ChannelDescriptor('integer'   , [obj.EPICS_CTRL 'X-SASE2-BUCKET-START'  ]));
      obj.ctrl.x_sase2_bucket_stop   = Channels.create(context, ChannelDescriptor('integer'   , [obj.EPICS_CTRL 'X-SASE2-BUCKET-STOP'   ]));
      obj.ctrl.x_sase2_bunch_space   = Channels.create(context, ChannelDescriptor('integer'   , [obj.EPICS_CTRL 'X-SASE2-BUNCH-SPACE'   ]));
      obj.ctrl.x_sase2_bunch_num     = Channels.create(context, ChannelDescriptor('integer'   , [obj.EPICS_CTRL 'X-SASE2-BUNCH-NUM'     ]));
      obj.ctrl.x_sase3_bucket_start  = Channels.create(context, ChannelDescriptor('integer'   , [obj.EPICS_CTRL 'X-SASE3-BUCKET-START'  ]));
      obj.ctrl.x_sase3_bucket_stop   = Channels.create(context, ChannelDescriptor('integer'   , [obj.EPICS_CTRL 'X-SASE3-BUCKET-STOP'   ]));
      obj.ctrl.x_sase3_bunch_space   = Channels.create(context, ChannelDescriptor('integer'   , [obj.EPICS_CTRL 'X-SASE3-BUNCH-SPACE'   ]));
      obj.ctrl.x_sase3_bunch_num     = Channels.create(context, ChannelDescriptor('integer'   , [obj.EPICS_CTRL 'X-SASE3-BUNCH-NUM'     ]));
      obj.ctrl.x_fast_fb_del         = Channels.create(context, ChannelDescriptor('integer'   , [obj.EPICS_CTRL 'X-FAST-FB-DEL'         ]));
      obj.ctrl.x_fb_fast_ki          = Channels.create(context, ChannelDescriptor('float'     , [obj.EPICS_CTRL 'X-FB-FAST-KI'          ]));     
      obj.ctrl.x_fb_fast_kp          = Channels.create(context, ChannelDescriptor('float'     , [obj.EPICS_CTRL 'X-FB-FAST-KP'          ]));     
      obj.ctrl.x_fb_kicker_m11       = Channels.create(context, ChannelDescriptor('float'     , [obj.EPICS_CTRL 'X-FB-KICKER-M11'       ]));     
      obj.ctrl.x_fb_kicker_m12       = Channels.create(context, ChannelDescriptor('float'     , [obj.EPICS_CTRL 'X-FB-KICKER-M12'       ]));     
      obj.ctrl.x_fb_kicker_m21       = Channels.create(context, ChannelDescriptor('float'     , [obj.EPICS_CTRL 'X-FB-KICKER-M21'       ]));     
      obj.ctrl.x_fb_kicker_m22       = Channels.create(context, ChannelDescriptor('float'     , [obj.EPICS_CTRL 'X-FB-KICKER-M22'       ]));     
      obj.ctrl.x_fb_fast_on          = Channels.create(context, ChannelDescriptor('integer'   , [obj.EPICS_CTRL 'X-FB-FAST-ON'          ]));
      obj.ctrl.x_ff_fast_on          = Channels.create(context, ChannelDescriptor('integer'   , [obj.EPICS_CTRL 'X-FF-FAST-ON'          ]));
      obj.ctrl.x_fb_params_mode      = Channels.create(context, ChannelDescriptor('integer'   , [obj.EPICS_CTRL 'X-FB-PARAMS-MODE'      ]));
      obj.ctrl.x_ff_table_pos        = Channels.create(context, ChannelDescriptor('float[]'   , [obj.EPICS_CTRL 'X-FF-TABLE-POS'        ]));
      obj.ctrl.x_ff_table_angle      = Channels.create(context, ChannelDescriptor('float[]'   , [obj.EPICS_CTRL 'X-FF-TABLE-ANGLE'      ]));
      obj.ctrl.x_kick1_p_pattern     = Channels.create(context, ChannelDescriptor('integer[]' , [obj.EPICS_CTRL 'X-KICK1-P-PATTERN'     ]));
      obj.ctrl.x_kick1_n_pattern     = Channels.create(context, ChannelDescriptor('integer[]' , [obj.EPICS_CTRL 'X-KICK1-N-PATTERN'     ]));
      obj.ctrl.x_kick2_p_pattern     = Channels.create(context, ChannelDescriptor('integer[]' , [obj.EPICS_CTRL 'X-KICK2-P-PATTERN'     ]));
      obj.ctrl.x_kick2_n_pattern     = Channels.create(context, ChannelDescriptor('integer[]' , [obj.EPICS_CTRL 'X-KICK2-N-PATTERN'     ]));
      obj.ctrl.x_fb_i_smp_apply      = Channels.create(context, ChannelDescriptor('integer'   , [obj.EPICS_CTRL 'X-FB-I-SMP-APPLY'      ]));
      obj.ctrl.x_fb_i_smp_shift      = Channels.create(context, ChannelDescriptor('integer'   , [obj.EPICS_CTRL 'X-FB-I-SMP-SHIFT'      ]));

      %%   PLAYER %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      if obj.use_player
        obj.play.play1_mem_play_timestamp = Channels.create(context, ChannelDescriptor('integer[]' , [obj.EPICS_PLAY 'PLAY1-MEM-PLAY-TIMESTAMP']));
        obj.play.play1_mem_play_control   = Channels.create(context, ChannelDescriptor('integer[]' , [obj.EPICS_PLAY 'PLAY1-MEM-PLAY-CONTROL'  ]));
        obj.play.play1_mem_play_x         = Channels.create(context, ChannelDescriptor('float[]'   , [obj.EPICS_PLAY 'PLAY1-MEM-PLAY-X'        ]));
        obj.play.play1_mem_play_y         = Channels.create(context, ChannelDescriptor('float[]'   , [obj.EPICS_PLAY 'PLAY1-MEM-PLAY-Y'        ]));
        obj.play.play1_mem_play_cmd       = Channels.create(context, ChannelDescriptor('integer'   , [obj.EPICS_PLAY 'PLAY1-MEM-PLAY-CMD'      ]));
        obj.play.play2_mem_play_timestamp = Channels.create(context, ChannelDescriptor('integer[]' , [obj.EPICS_PLAY 'PLAY2-MEM-PLAY-TIMESTAMP']));
        obj.play.play2_mem_play_control   = Channels.create(context, ChannelDescriptor('integer[]' , [obj.EPICS_PLAY 'PLAY2-MEM-PLAY-CONTROL'  ]));
        obj.play.play2_mem_play_x         = Channels.create(context, ChannelDescriptor('float[]'   , [obj.EPICS_PLAY 'PLAY2-MEM-PLAY-X'        ]));
        obj.play.play2_mem_play_y         = Channels.create(context, ChannelDescriptor('float[]'   , [obj.EPICS_PLAY 'PLAY2-MEM-PLAY-Y'        ]));
        obj.play.play2_mem_play_cmd       = Channels.create(context, ChannelDescriptor('integer'   , [obj.EPICS_PLAY 'PLAY2-MEM-PLAY-CMD'      ]));
      end;
      %%  MONITOR  %%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
      obj.mon(1).name = 'Y1 +';
      obj.mon(2).name = 'Y1 -';
      obj.mon(3).name = 'Y2 +';
      obj.mon(4).name = 'Y2 -';
      obj.mon(5).name = 'X1 +';
      obj.mon(6).name = 'X1 -';
      obj.mon(7).name = 'X2 +';
      obj.mon(8).name = 'X2 -';
      obj.mon(1).amp_adc_wav    = Channels.create(context, ChannelDescriptor('integer[]' , [obj.EPICS_MON 'AMP-ADC-WAV-0' ]));
      obj.mon(2).amp_adc_wav    = Channels.create(context, ChannelDescriptor('integer[]' , [obj.EPICS_MON 'AMP-ADC-WAV-1' ]));
      obj.mon(3).amp_adc_wav    = Channels.create(context, ChannelDescriptor('integer[]' , [obj.EPICS_MON 'AMP-ADC-WAV-2' ]));
      obj.mon(4).amp_adc_wav    = Channels.create(context, ChannelDescriptor('integer[]' , [obj.EPICS_MON 'AMP-ADC-WAV-3' ]));
      obj.mon(5).amp_adc_wav    = Channels.create(context, ChannelDescriptor('integer[]' , [obj.EPICS_MON 'AMP-ADC-WAV-4' ]));
      obj.mon(6).amp_adc_wav    = Channels.create(context, ChannelDescriptor('integer[]' , [obj.EPICS_MON 'AMP-ADC-WAV-5' ]));
      obj.mon(7).amp_adc_wav    = Channels.create(context, ChannelDescriptor('integer[]' , [obj.EPICS_MON 'AMP-ADC-WAV-6' ]));
      obj.mon(8).amp_adc_wav    = Channels.create(context, ChannelDescriptor('integer[]' , [obj.EPICS_MON 'AMP-ADC-WAV-7' ]));
      obj.mon(1).kick_adc_wav   = Channels.create(context, ChannelDescriptor('integer[]' , [obj.EPICS_MON 'KICK-ADC-WAV-0']));
      obj.mon(2).kick_adc_wav   = Channels.create(context, ChannelDescriptor('integer[]' , [obj.EPICS_MON 'KICK-ADC-WAV-1']));
      obj.mon(3).kick_adc_wav   = Channels.create(context, ChannelDescriptor('integer[]' , [obj.EPICS_MON 'KICK-ADC-WAV-2']));
      obj.mon(4).kick_adc_wav   = Channels.create(context, ChannelDescriptor('integer[]' , [obj.EPICS_MON 'KICK-ADC-WAV-3']));
      obj.mon(5).kick_adc_wav   = Channels.create(context, ChannelDescriptor('integer[]' , [obj.EPICS_MON 'KICK-ADC-WAV-4']));
      obj.mon(6).kick_adc_wav   = Channels.create(context, ChannelDescriptor('integer[]' , [obj.EPICS_MON 'KICK-ADC-WAV-5']));
      obj.mon(7).kick_adc_wav   = Channels.create(context, ChannelDescriptor('integer[]' , [obj.EPICS_MON 'KICK-ADC-WAV-6']));
      obj.mon(8).kick_adc_wav   = Channels.create(context, ChannelDescriptor('integer[]' , [obj.EPICS_MON 'KICK-ADC-WAV-7']));
      fprintf('done\n');
      
      if strncmp(obj.hostname, 'xfelpsiibfb', 11)
        fprintf('  DOOCS properties initialization\n');
        doocs_p     = 'XFEL.DIAG/BPM/';
        obj.doocs.y_bpm1_up_pos_name = [doocs_p 'BPMI.1860.TL/X.TD'];
        obj.doocs.y_bpm1_up_pos_name = [doocs_p 'BPMI.1860.TL/Y.TD'];
        obj.doocs.y_bpm1_up_pos_name = [doocs_p 'BPMI.1860.TL/Q.TD'];
        obj.doocs.y_bpm2_up_pos_name = [doocs_p 'BPMI.1878.TL/X.TD'];
        obj.doocs.y_bpm2_up_pos_name = [doocs_p 'BPMI.1878.TL/Y.TD'];
        obj.doocs.y_bpm2_up_pos_name = [doocs_p 'BPMI.1878.TL/Q.TD'];
        obj.doocs.y_bpm1_down_pos_name = [doocs_p 'BPMI.1910.TL/X.TD'];
        obj.doocs.y_bpm1_down_pos_name = [doocs_p 'BPMI.1910.TL/Y.TD'];
        obj.doocs.y_bpm1_down_pos_name = [doocs_p 'BPMI.1910.TL/Q.TD'];
        obj.doocs.y_bpm2_down_pos_name = [doocs_p 'BPMI.1930.TL/X.TD'];
        obj.doocs.y_bpm2_down_pos_name = [doocs_p 'BPMI.1930.TL/Y.TD'];
        obj.doocs.y_bpm2_down_pos_name = [doocs_p 'BPMI.1930.TL/Q.TD'];

        obj.doocs.x_bpm1_up_pos_name = [doocs_p 'BPMI.1863.TL/X.TD'];
        obj.doocs.x_bpm1_up_pos_name = [doocs_p 'BPMI.1863.TL/Y.TD'];
        obj.doocs.x_bpm1_up_pos_name = [doocs_p 'BPMI.1863.TL/Q.TD'];
        obj.doocs.x_bpm2_up_pos_name = [doocs_p 'BPMI.1889.TL/X.TD'];
        obj.doocs.x_bpm2_up_pos_name = [doocs_p 'BPMI.1889.TL/Y.TD'];
        obj.doocs.x_bpm2_up_pos_name = [doocs_p 'BPMI.1889.TL/Q.TD'];
        obj.doocs.x_bpm1_down_pos_name = [doocs_p 'BPMI.1925.TL/X.TD'];
        obj.doocs.x_bpm1_down_pos_name = [doocs_p 'BPMI.1925.TL/Y.TD'];
        obj.doocs.x_bpm1_down_pos_name = [doocs_p 'BPMI.1925.TL/Q.TD'];
        obj.doocs.x_bpm2_down_pos_name = [doocs_p 'BPMI.1939.TL/X.TD'];
        obj.doocs.x_bpm2_down_pos_name = [doocs_p 'BPMI.1939.TL/Y.TD'];
        obj.doocs.x_bpm2_down_pos_name = [doocs_p 'BPMI.1939.TL/Q.TD'];
        fprintf('done\n');
      end
      
    end

    % Destructor
    function delete(obj)
      %obj.play.mem_play_timestamp.close();
      %obj.play.mem_play_control.close();
      %obj.play.mem_play_x.close();
      %obj.play.mem_play_y.close();
      %obj.play.mem_play_cmd.close();
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% PLAYER FUNCTIONS
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function play_gen_sequence(obj, player, packets, bpm)
      if packets > 2700
          error 'Packets number must not exceed 2700';
      end
      obj.play.mem_play_timestamp.put(obj.play_calculate_timestamp());
      obj.play.mem_play_control.put(obj.player_calculate_control(packets, bpm));
      obj.play.mem_play_x.put(obj.player_calculate_pos(3.4));
      obj.play.mem_play_y.put(obj.player_calculate_pos(-0.7));
      pause(1);
      obj.play.mem_play_cmd.put(int32(player+2^8));
      pause(1);
      obj.play.mem_play_cmd.put(int32(0));
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    function play_gen_bpm_data(obj, bpmidx, offset, packets, posx, posy)
      obj.bpms(bpmidx).packets.num = packets;
      obj.bpms(bpmidx).packets.timestamp = offset + obj.BUCKET_SPACE*(0:(obj.BUCKET_NUMBER-1));
      % byte 0 - control word
      % byte 1 - bpm ID
      % byte 2-3 - bucket number
      buckets = (0:(obj.BUCKET_NUMBER-1));
      obj.bpms(bpmidx).packets.control = int32(buckets + bpmidx * 2^16) + obj.VALID_X + obj.VALID_Y;
      obj.bpms(bpmidx).packets.x(:) = posx + 1e-2*(0:(obj.BUCKET_NUMBER-1));
      obj.bpms(bpmidx).packets.y(:) = posy + 1e-2*(0:(obj.BUCKET_NUMBER-1));           
    end      
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    function play_program_mem(obj, bpm_fpga, player, bpms, debug) 
      % if length of bpms is zero then stop the transmission
      if isempty(bpms)
          mem_play_control = obj.PLAYER_EOP * int32(ones(1, obj.BUCKET_NUMBER-1));
          if bpm_fpga == 0
            obj.play.play1_mem_play_control.put(mem_play_control);
            pause(1);
            obj.play.play1_mem_play_cmd.put(int32(player+2^8));
            pause(1);
            obj.play.play1_mem_play_cmd.put(int32(0));
          else
            obj.play.play2_mem_play_control.put(mem_play_control);
            pause(1);
            obj.play.play2_mem_play_cmd.put(int32(player+2^8));
            pause(1);
            obj.play.play2_mem_play_cmd.put(int32(0));
          end;
          return;
      end
      % order data in memory using timestamps        
      bpmidx = ones(1, length(bpms));        
      memidx=1;
      mem_play_timestamp = zeros(1, obj.BUCKET_NUMBER);
      mem_play_control = obj.PLAYER_EOP * int32(ones(1, obj.BUCKET_NUMBER-1));
      mem_play_x = zeros(1, obj.BUCKET_NUMBER);
      mem_play_y = zeros(1, obj.BUCKET_NUMBER);
      p=0;
      while 1
        minbpm=0;
        mintimestamp=250000000;
        for i=length(bpms):-1:1
          if bpmidx(i) <= obj.bpms(bpms(i)).packets.num
            if obj.bpms(bpms(i)).packets.timestamp(bpmidx(i)) < mintimestamp
              mintimestamp = obj.bpms(bpms(i)).packets.timestamp(bpmidx(i));
              minbpm = i;
            end
          end
        end
        if minbpm
          p = p + 1;
          if debug
            %if bpmidx(minbpm) < 10
              fprintf('%3d, bpm %2d, bucket %4d, timestamp %d, 0x%08X\n', p, bpms(minbpm), bpmidx(minbpm),  obj.bpms(bpms(minbpm)).packets.timestamp(bpmidx(minbpm)), obj.bpms(bpms(minbpm)).packets.control(bpmidx(minbpm)));
            %end
          end          
          % write value to the memory
          %if bpmidx(minbpm) == 2700
          %  memidx
          %end
          if memidx > obj.BUCKET_NUMBER
            break;
          else
            mem_play_timestamp(memidx) = obj.bpms(bpms(minbpm)).packets.timestamp(bpmidx(minbpm));
            mem_play_control(memidx) = obj.bpms(bpms(minbpm)).packets.control(bpmidx(minbpm));
            mem_play_x(memidx) = obj.bpms(bpms(minbpm)).packets.x(bpmidx(minbpm));
            mem_play_y(memidx) = obj.bpms(bpms(minbpm)).packets.y(bpmidx(minbpm));
            memidx = memidx + 1;
          end
          bpmidx(minbpm) = bpmidx(minbpm) + 1;
        else
          break;
        end
      end
      % program memory
      if bpm_fpga == 0
        obj.play.play1_mem_play_timestamp.put(int32(obj.play.trgdel + mem_play_timestamp));
        obj.play.play1_mem_play_control.put(mem_play_control);
        obj.play.play1_mem_play_x.put(single(mem_play_x));
        obj.play.play1_mem_play_y.put(single(mem_play_y));
        pause(1);
        obj.play.play1_mem_play_cmd.put(int32(player+2^8));
        pause(1);
        obj.play.play1_mem_play_cmd.put(int32(0));
      else
        obj.play.play2_mem_play_timestamp.put(int32(obj.play.trgdel + mem_play_timestamp));
        obj.play.play2_mem_play_control.put(mem_play_control);
        obj.play.play2_mem_play_x.put(single(mem_play_x));
        obj.play.play2_mem_play_y.put(single(mem_play_y));
        pause(1);
        obj.play.play2_mem_play_cmd.put(int32(player+2^8));
        pause(1);
        obj.play.play2_mem_play_cmd.put(int32(0));
      end;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function [res] = play_init_bpms(obj)
      obj.play_gen_bpm_data(obj.BPMDOWNY1,       38,    2700,  0.11, -0.11);
      obj.play_gen_bpm_data(obj.BPMDOWNY2,       41,    2700,  0.12, -0.12);
      obj.play_gen_bpm_data(obj.BPMUPY1,         32,    2700,  0.21, -0.21);
      obj.play_gen_bpm_data(obj.BPMUPY2,         35,    2700,  0.22, -0.22);
      obj.play_gen_bpm_data(obj.BPMSASE1Y1,     132,    2700,  1.11, -1.11);
      obj.play_gen_bpm_data(obj.BPMSASE1Y2,     135,    2700,  1.12, -1.12);
      obj.play_gen_bpm_data(obj.BPMSASE2Y1,     142,    2700,  1.11, -1.11);
      obj.play_gen_bpm_data(obj.BPMSASE2Y2,     145,    2700,  1.12, -1.12);
      obj.play_gen_bpm_data(obj.BPMSASE3Y1,     232,    2700,  1.11, -1.11);
      obj.play_gen_bpm_data(obj.BPMSASE3Y2,     235,    2700,  1.12, -1.12);
      obj.play_gen_bpm_data(obj.BPMCOL1,         32,    2700,  1.12, -1.12);

      % X plane
      obj.play_gen_bpm_data(obj.BPMDOWNX1,       38,    2700,   2.3, -0.20);
      obj.play_gen_bpm_data(obj.BPMDOWNX2,       41,    2700,  -2.3,  0.50);
      obj.play_gen_bpm_data(obj.BPMUPX1,         32,    2700,  -2.3,  1.20);
      obj.play_gen_bpm_data(obj.BPMUPX2,         35,    2700,  -2.3,  1.20);
      obj.play_gen_bpm_data(obj.BPMSASE1X1,     132,    2700,  -2.3,  1.23);
      obj.play_gen_bpm_data(obj.BPMSASE1X2,     135,    2700,  -2.3,  1.33);
      obj.play_gen_bpm_data(obj.BPMSASE2X1,     142,    2700,  -2.3,  1.23);
      obj.play_gen_bpm_data(obj.BPMSASE2X2,     145,    2700,  -2.3,  1.33);
      obj.play_gen_bpm_data(obj.BPMSASE3X1,     232,    2700,  1.11, -1.11);
      obj.play_gen_bpm_data(obj.BPMSASE3X2,     235,    2700,  1.12, -1.12);    
    end

    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% CONTROLLER FUNCTIONS
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function [res, m] = ctrl_read_down_bpms(obj, plane)        
        res = 0;
        n = 16;
        smp = 256;
        
        m.bpm1 = zeros(n, smp);
        m.bpm2 = zeros(n, smp);
        if strcmp(plane, 'Y')        
            hbpm1 = obj.ctrl.y_bpm1_down_pos_wav;
            hbpm2 = obj.ctrl.y_bpm2_down_pos_wav;
        end
        if strcmp(plane, 'X')        
            hbpm1 = obj.ctrl.x_bpm1_down_pos_wav;
            hbpm2 = obj.ctrl.x_bpm2_down_pos_wav;
        end
        
        for i=1:16
            m.bpm1(i,:) = hbpm1.get();
            m.bpm2(i,:) = hbpm2.get();
            pause(0.3);
        end
        
    end

    function [res, m] = ctrl_plot_fb_compare(obj, plane, bpmb, bpma)
        % bpmb - measurements taken with open loop
        % bpma - measurements taken with closed loop
        
        clf
        pts=116;
        % reduce number of points to number of bunches * bunch_spacing
        bpmb.bpm1 = bpmb.bpm1(:,1:4:pts);
        bpmb.bpm2 = bpmb.bpm2(:,1:4:pts);              
        bpma.bpm1 = bpma.bpm1(:,1:4:pts);
        bpma.bpm2 = bpma.bpm2(:,1:4:pts);              
        pts = length(bpmb.bpm1);
                
        bpmb1m = mean(bpmb.bpm1);
        bpmb2m = mean(bpmb.bpm2);
        bpma1m = mean(bpma.bpm1);
        bpma2m = mean(bpma.bpm2);
        
        % BPM1
        subplot(2,1,1);
        e=errorbar(1:pts,bpmb1m, min(bpmb.bpm1)-bpmb1m, max(bpmb.bpm1)-bpmb1m);
        hold on
        e.Color = 'red';
        e = errorbar(1:pts,bpma1m, min(bpma.bpm1)-bpma1m, max(bpma.bpm1)-bpma1m);
        e.Color = 'blue';
        xlabel('Bunch number');
        ylabel('BPM1 position [mm]');
        title([plane ' Plane']);
        grid on
        legend('FB off', 'FB on')
        
        %BPM2
        subplot(2,1,2);
        e = errorbar(1:pts,bpmb2m, min(bpmb.bpm2)-bpmb2m, max(bpmb.bpm2)-bpmb2m)
        hold on
        e.Color = 'red';
        e = errorbar(1:pts,bpma2m, min(bpma.bpm2)-bpma2m, max(bpma.bpm2)-bpma2m);
        e.Color = 'blue';        
        xlabel('Bunch number');
        ylabel('BPM2 position [mm]');
        title([plane ' Plane']);
        grid on
        legend('FB off', 'FB on')
        
    end
    
    function [res] = ctrl_daq_set_mux(obj, plane, mux)

      res=0;
      if strcmp(plane, 'Y')
        obj.ctrl.y_daq_mux0.put(uint32(mux(1)));
        obj.ctrl.y_daq_mux1.put(uint32(mux(2)));
        obj.ctrl.y_daq_mux2.put(uint32(mux(3)));
        obj.ctrl.y_daq_mux3.put(uint32(mux(4)));
      end
      if strcmp(plane, 'X')
        obj.ctrl.x_daq_mux0.put(uint32(mux(1)));
        obj.ctrl.x_daq_mux1.put(uint32(mux(2)));
        obj.ctrl.x_daq_mux2.put(uint32(mux(3)));
        obj.ctrl.x_daq_mux3.put(uint32(mux(4)));
      end      
    end
    
    function [res, daq] = ctrl_read_daq(obj, plane)
      % [res, daq] = ctrl_read_daq(obj, plane, mux)
      % Parameters:
      %   plane - 'X', 'Y'
      % Return:
      %   res - error when not zero
      %   daq - readout structure
      
      res=0;
      if strcmp(plane, 'Y')
        daq.mux0 = obj.ctrl.y_daq_mux0.get();
        daq.mux1 = obj.ctrl.y_daq_mux1.get();
        daq.mux2 = obj.ctrl.y_daq_mux2.get();
        daq.mux3 = obj.ctrl.y_daq_mux3.get();          
        if obj.ctrl.y_daq_mux0.get() == 2
          daq.ch00 = (obj.ctrl.y_daq_ch00_int.get()        )';
          daq.ch01 = (obj.ctrl.y_daq_ch01_int.get()        )';
        else
          daq.ch00 = (obj.ctrl.y_daq_ch00.get()            )';
          daq.ch01 = (obj.ctrl.y_daq_ch01.get()            )';
        end
        if obj.ctrl.y_daq_mux1.get() == 2
          daq.ch10 = (obj.ctrl.y_daq_ch10_int.get()        )';
          daq.ch11 = (obj.ctrl.y_daq_ch11_int.get()        )';
        else
          daq.ch10 = (obj.ctrl.y_daq_ch10.get()            )';
          daq.ch11 = (obj.ctrl.y_daq_ch11.get()            )';
        end
        daq.ch20 = (obj.ctrl.y_daq_ch20.get()              )';
        daq.ch21 = (obj.ctrl.y_daq_ch21.get()              )';
        daq.ch30 = (obj.ctrl.y_daq_ch30_int.get()          )';
        daq.ch31 = (obj.ctrl.y_daq_ch31_int.get()          )';
        daq.rx_down_bpm1 = (obj.ctrl.y_rx_down_bpm1.get()  )';
        daq.rx_down_bpm2 = (obj.ctrl.y_rx_down_bpm2.get()  )';
      end
      if strcmp(plane, 'X')
        daq.mux0 = obj.ctrl.x_daq_mux0.get();
        daq.mux1 = obj.ctrl.x_daq_mux1.get();
        daq.mux2 = obj.ctrl.x_daq_mux2.get();
        daq.mux3 = obj.ctrl.x_daq_mux3.get();          
        if obj.ctrl.y_daq_mux0.get() == 2
          daq.ch00         = (obj.ctrl.x_daq_ch00_int.get())';
          daq.ch01         = (obj.ctrl.x_daq_ch01_int.get())';
        else
          daq.ch00         = (obj.ctrl.x_daq_ch00.get()    )';
          daq.ch01         = (obj.ctrl.x_daq_ch01.get()    )';
        end
        if obj.ctrl.y_daq_mux1.get() == 2
          daq.ch10         = (obj.ctrl.x_daq_ch10_int.get())';
          daq.ch11         = (obj.ctrl.x_daq_ch11_int.get())';
        else
          daq.ch10         = (obj.ctrl.x_daq_ch10.get()    )';
          daq.ch11         = (obj.ctrl.x_daq_ch11.get()    )';
        end
        daq.ch20         = (obj.ctrl.x_daq_ch20.get()      )';
        daq.ch21         = (obj.ctrl.x_daq_ch21.get()      )';
        daq.ch30         = (obj.ctrl.x_daq_ch30_int.get()  )';
        daq.ch31         = (obj.ctrl.x_daq_ch31_int.get()  )';
        daq.rx_down_bpm1 = (obj.ctrl.x_rx_down_bpm1.get()  )';
        daq.rx_down_bpm2 = (obj.ctrl.x_rx_down_bpm2.get()  )';
      end
    end
    
    function [res] = ctrl_ff_table_generate(obj, type, plane, kicker, amp, length)
      % [res] = ctrl_ff_table_generate(obj, type, plane, kicker, amplitude, length)
      %
      % Parameters:
      %   type      - possible strings 'lin', 'alt'
      %   plane     - select plane 'X', 'Y', 'XY'
      %   kicker    - select kicker 'KICK1', 'KICK2', 'KICK12'
      %   amp       - a vector of two amplitudes [start, stop] for linear, and [pos, neg] for alternating pulses
      %               the amplitude value is normalized to 1 and corresponds to +/- 32767 in hardware
      %   length    - a length of the generated ff table
      
      res = 0;
      tsize = 256;
      
      % generate tables
      switch type
        case 'pulse'
          ff1 = zeros(1, length);
          ff1(length) = amp(1);
          ff2 = zeros(1, length);
          ff2(length) = amp(3);
        case 'lin'
          ff1 = linspace(amp(1), amp(2), length);
          ff2 = linspace(amp(3), amp(4), length);
        case 'lin_alt'
          ff1 = zeros(1, 2*length);
          ff1(1:2:end) = linspace(amp(1), amp(2), length);
          ff2 = zeros(1, 2*length);
          ff2(1:2:end) = linspace(amp(3), amp(4), length);
        case 'alt'
          %ff = (-1).^(0:(length-1));
          ff1 = ones(1, length);
          ff1(1:2:end) = ff1(1:2:end) * amp(1);
          ff1(2:2:end) = ff1(2:2:end) * amp(2);
          ff2 = ones(1, length);
          ff2(1:2:end) = ff2(1:2:end) * amp(3);
          ff2(2:2:end) = ff2(2:2:end) * amp(4);
      end
           
      ff_tab = zeros(2, 2708);
      if strcmp(kicker, 'KICK1') || strcmp(kicker, 'KICK12')
        ff_tab(1, 1:size(ff1,2)) = ff1;
      end
      if strcmp(kicker, 'KICK2') || strcmp(kicker, 'KICK12')
        ff_tab(2, 1:size(ff2,2)) = ff2;
      end
      
      % this value triggers writing of the FF tables
      %ff_tab(1, end) = obj.ff_tab1;
      %ff_tab(2, end) = obj.ff_tab2;
      %ff_tab(1, 256) = obj.ff_tab1;
      ff_tab(2, 256) = obj.ff_tab2;

      obj.ff_tab1 = obj.ff_tab1 + 0.0001;
      obj.ff_tab2 = obj.ff_tab2 + 0.0001;

      y_cnt = obj.ctrl.y_ff_table_cnt.get();
      x_cnt = obj.ctrl.x_ff_table_cnt.get();
      % write to hardware 
      obj.ctrl.y_ff_fast_mode.put(uint32(1));
      obj.ctrl.x_ff_fast_mode.put(uint32(1));

      if strcmp(plane, 'Y') || strcmp(plane, 'XY')
        obj.ctrl.y_ff_table_pos.put(single(ff_tab(1,1:tsize))); 
        %plot(obj.ctrl.y_ff_table_pos.get(), 'b')
        %pause(1)
        obj.ctrl.y_ff_table_angle.put(single(ff_tab(2,1:tsize)));    
        %plot(obj.ctrl.y_ff_table_angle.get(),'r')
      end
      if strcmp(plane, 'X') || strcmp(plane, 'XY')
        obj.ctrl.x_ff_table_pos.put(single(ff_tab(1,1:tsize))); 
        %pause(1);
        obj.ctrl.x_ff_table_angle.put(single(ff_tab(2,1:tsize)));
      end
      w=0;
      pause(0.2)
      % wait for completion, the internal FF table counter should be incremented
      if strcmp(plane, 'Y') || strcmp(plane, 'XY')
        while y_cnt == obj.ctrl.y_ff_table_cnt.get()
          if w > 10000
            res = -4;
            return
          end
          w = w + 1;
        end
      end 
      %pause(1)
      if strcmp(plane, 'X') || strcmp(plane, 'XY')
        while x_cnt == obj.ctrl.x_ff_table_cnt.get()
          if w > 80000
            res = -5;
            return
          end
          w = w + 1;
        end
      end
      %pause(0.2)
      % send feedback command
      %obj.ctrl.y_fb_cmd.put(uint32(8));
      %pause(0.2)
      %obj.ctrl.y_fb_cmd.put(uint32(0));
      
    end

    function [m] = ctrl_ff_scan_init_single_m(obj, N, plane)
      m.bpm1_up_pos     = zeros(1, N);
      m.bpm2_up_pos     = zeros(1, N);
      m.bpm1_down_pos   = zeros(1, N);
      m.bpm2_down_pos   = zeros(1, N);
      m.bpm1_up_valid   = uint32(zeros(1, N));
      m.bpm2_up_valid   = uint32(zeros(1, N));
      m.bpm1_down_valid = uint32(zeros(1, N));
      m.bpm2_down_valid = uint32(zeros(1, N));
      if strcmp(plane, 'Y')
        m.col_pos       = zeros(1, N);
        m.col_valid     = uint32(zeros(1, N));
      end
      m.kick1_out       = int32(zeros(1, N));
      m.kick2_out       = int32(zeros(1, N));      
      m.pulseid         = uint32(zeros(1, N));
      %temporary
      %m.mon_adc7        = uint32(zeros(1, N));
      %m.mon_adc8        = uint32(zeros(1, N));
    end

    function [res] = ctrl_wait_for_next_pulse(obj, plane)
      res = 0;
      % assign pulse ID handler from the right plane
      if strcmp(plane, 'Y')
        h_pid = obj.ctrl.y_xfeltim_pulse;
      end;
      if strcmp(plane, 'X')
        h_pid = obj.ctrl.x_xfeltim_pulse;
      end;
      w = 0;
      pulid = h_pid.get();
      while pulid >= h_pid.get()
        pause(0.1);
        w = w + 1;
        if (w>10000) res=-2; return; end; % timeout
      end
    end

    function [res, m] = ctrl_ff_scan_read_single_bunch(obj, m, plane, i)
      res=0;
      w=0;
      res = ctrl_wait_for_next_pulse(obj, plane);
      if res return; end ;
      if strcmp(plane, 'Y')
        m.bpm1_up_pos(i)     = obj.ctrl.y_bpm1_up_pos_wav.get();
        m.bpm2_up_pos(i)     = obj.ctrl.y_bpm2_up_pos_wav.get();    
        m.bpm1_down_pos(i)   = obj.ctrl.y_bpm1_down_pos_wav.get();
        m.bpm2_down_pos(i)   = obj.ctrl.y_bpm2_down_pos_wav.get();
        m.bpm1_up_valid(i)   = uint32(obj.ctrl.y_bpm1_up_valid_wav.get()  );
        m.bpm2_up_valid(i)   = uint32(obj.ctrl.y_bpm2_up_valid_wav.get()  );
        m.bpm1_down_valid(i) = uint32(obj.ctrl.y_bpm1_down_valid_wav.get());
        m.bpm2_down_valid(i) = uint32(obj.ctrl.y_bpm2_down_valid_wav.get());
        m.col_pos(i)         = obj.ctrl.y_col_pos_wav.get();
        m.col_valid(i)       = uint32(obj.ctrl.y_col_valid_wav.get()); 
        m.kick1_out(i)       = int32(obj.ctrl.y_kick1_out_wav.get());
        m.kick2_out(i)       = int32(obj.ctrl.y_kick2_out_wav.get());
        m.pulseid(i)         = uint32(obj.ctrl.y_xfeltim_pulse.get());
        %temporary
        %adc = obj.mon(7).amp_adc_wav.get();
        %m.mon_adc7(i) = adc(45);
        %adc = obj.mon(8).amp_adc_wav.get();
        %m.mon_adc8(i) = adc(45);
      end
      if strcmp(plane, 'X')
        m.bpm1_up_pos(i)     = obj.ctrl.x_bpm1_up_pos_wav.get();
        m.bpm2_up_pos(i)     = obj.ctrl.x_bpm2_up_pos_wav.get();    
        m.bpm1_down_pos(i)   = obj.ctrl.x_bpm1_down_pos_wav.get();
        m.bpm2_down_pos(i)   = obj.ctrl.x_bpm2_down_pos_wav.get();
        m.bpm1_up_valid(i)   = uint32(obj.ctrl.x_bpm1_up_valid_wav.get()  );
        m.bpm2_up_valid(i)   = uint32(obj.ctrl.x_bpm2_up_valid_wav.get()  );
        m.bpm1_down_valid(i) = uint32(obj.ctrl.x_bpm1_down_valid_wav.get());
        m.bpm2_down_valid(i) = uint32(obj.ctrl.x_bpm2_down_valid_wav.get());
        m.kick1_out(i)       = int32(obj.ctrl.x_kick1_out_wav.get()      );
        m.kick2_out(i)       = int32(obj.ctrl.x_kick2_out_wav.get()      );
        m.pulseid(i)         = uint32(obj.ctrl.x_xfeltim_pulse.get()      );
      end
    end
    
    function [res, m] = ctrl_ff_scan_single(obj, plane, kicker)
      % [res] = ctrl_ff_scan_single(obj, plane, kicker)
      %
      % Parameters:
      %   plane     - select plane 'X', 'Y', 'XY'
      %   kicker    - select kicker 'KICK1', 'KICK2', 'KICK12'
      res = 0;
      k = -1:0.1:1;
      N = size(k,2);
      m = ctrl_ff_scan_init_single_m(obj, N, plane);
      for i=1:N
        [res] = obj.ctrl_ff_table_generate('lin',plane,kicker, [k(i) k(i) k(i) k(i)], 1);
        if res return; end;
        [res, m] = ctrl_ff_scan_read_single_bunch(obj, m, plane, i);
        if res return; end;
        %pause(1);
      end
      obj.ctrl_ff_table_generate('lin',plane,kicker, [0 0 0 0], 2707);
    end
    
    function [res, m] = ctrl_ff_scan_plane(obj, plane)
      % [res] = ctrl_ff_scan_plane(obj, plane)
      %
      % Parameters:
      %   plane     - select plane 'X', 'Y', 'XY'
      %   kicker    - select kicker 'KICK1', 'KICK2', 'KICK12'
      res = 0;
      k = -1:0.2:1;
      N = size(k,2);
      sm = ctrl_ff_scan_init_single_m(obj, N, plane);
      m.bpm1 = zeros(N,N);
      m.bpm2 = zeros(N,N);
      for i=1:N
          for j=1:N
            [res] = obj.ctrl_ff_table_generate('lin',plane, 'KICK12', [k(i) k(i) k(j) k(j)], 1);
            if res return; end;
            [res, sm] = ctrl_ff_scan_read_single_bunch(obj, sm, plane, i);
            if res return; end;
            m.bpm1(i,j) = sm.bpm1_down_pos(i);
            m.bpm2(i,j) = sm.bpm2_down_pos(i);
            if plot_r
                figure(1)
                clf
                plot(m.bpm1)
            end
          end
      end
      obj.ctrl_ff_table_generate('lin',plane, 'KICK12', [0 0 0 0], 2707);
    end
    
    function [res, m] = ctrl_ff_scan_single_plot(obj, m)
        figure(1);
        clf;
        % kicker output
        subplot(3, 1, 1);
        plot(m.kick1_out, 'r');
        hold on;
        plot(m.kick2_out, 'b');
        grid on;
        title('Controller outputs');
        legend('kicker 1', 'kicker 2');
        % upstream BPMs output
        subplot(3, 1, 2);
        plot(m.bpm1_up_pos, 'r');
        hold on;
        plot(m.bpm2_up_pos, 'b');
        grid on;
        title('Upstream BPMs');
        legend('BPM1', 'BPM2');
        % downstream BPMs output
        subplot(3, 1, 3);
        plot(m.bpm1_down_pos, 'r');
        hold on;
        plot(m.bpm2_down_pos, 'b');
        grid on;
        title('Downstream BPMs');
        legend('BPM1', 'BPM2');

    end 
    
    function [res, m] = ctrl_ff_scan_read_single_bunch_pos(obj, m, plane, i)
      res=0;
      w=0;
      res = ctrl_wait_for_next_pulse(obj, plane);
      if res return; end ;
      if strcmp(plane, 'Y')
        m.bpm1_up_pos(i)     = obj.ctrl.y_bpm1_up_pos_wav.get();
        m.bpm2_up_pos(i)     = obj.ctrl.y_bpm2_up_pos_wav.get();    
        m.bpm1_down_pos(i)   = obj.ctrl.y_bpm1_down_pos_wav.get();
        m.bpm2_down_pos(i)   = obj.ctrl.y_bpm2_down_pos_wav.get();
        %m.bpm1_up_valid(i)   = uint32(obj.ctrl.y_bpm1_up_valid_wav.get()  );
        %m.bpm2_up_valid(i)   = uint32(obj.ctrl.y_bpm2_up_valid_wav.get()  );
        %m.bpm1_down_valid(i) = uint32(obj.ctrl.y_bpm1_down_valid_wav.get());
        %m.bpm2_down_valid(i) = uint32(obj.ctrl.y_bpm2_down_valid_wav.get());
        %m.col_pos(i)         = obj.ctrl.y_col_pos_wav.get();
        %m.col_valid(i)       = uint32(obj.ctrl.y_col_valid_wav.get()); 
        %m.kick1_out(i)       = int32(obj.ctrl.y_kick1_out_wav.get());
        %m.kick2_out(i)       = int32(obj.ctrl.y_kick2_out_wav.get());
        m.pulseid(i)         = uint32(obj.ctrl.y_xfeltim_pulse.get());
        %temporary
        %adc = obj.mon(7).amp_adc_wav.get();
        %m.mon_adc7(i) = adc(45);
        %adc = obj.mon(8).amp_adc_wav.get();
        %m.mon_adc8(i) = adc(45);
        m.trg_del(i) = m.trg_del(i);
      end
      if strcmp(plane, 'X')
        wav = obj.ctrl.x_bpm1_up_pos_wav.get();
        m.bpm1_up_pos(i)     = wav(1);
        wav = obj.ctrl.x_bpm2_up_pos_wav.get();
        m.bpm2_up_pos(i)     = wav(1);    
        wav = obj.ctrl.x_bpm1_down_pos_wav.get();
        m.bpm1_down_pos(i)   = wav(1);
        wav = obj.ctrl.x_bpm2_down_pos_wav.get();
        m.bpm2_down_pos(i)   = wav(1);
        %m.bpm1_up_valid(i)   = uint32(obj.ctrl.x_bpm1_up_valid_wav.get()  );
        %m.bpm2_up_valid(i)   = uint32(obj.ctrl.x_bpm2_up_valid_wav.get()  );
        %m.bpm1_down_valid(i) = uint32(obj.ctrl.x_bpm1_down_valid_wav.get());
        %m.bpm2_down_valid(i) = uint32(obj.ctrl.x_bpm2_down_valid_wav.get());
        %m.kick1_out(i)       = uint32(obj.ctrl.x_kick1_out_wav.get()      );
        %m.kick2_out(i)       = uint32(obj.ctrl.x_kick2_out_wav.get()      );
        m.pulseid(i)         = uint32(obj.ctrl.x_xfeltim_pulse.get()      );
        m.trg_del(i) = m.trg_del(i);
      end
    end
        
    function [res, m] = ctrl_bpms_read_waveforms(obj)
        res = 0;
        for t=1:32
            m(t).bpmi_1925_tl_x_wav = obj.bpm_e.bpmi_1925_tl_wav_x.get();
            m(t).bpmi_1939_tl_x_wav = obj.bpm_e.bpmi_1939_tl_wav_x.get();
            m(t).bpmi_1910_tl_y_wav = obj.bpm_e.bpmi_1910_tl_wav_y.get();
            m(t).bpmi_1930_tl_y_wav = obj.bpm_e.bpmi_1930_tl_wav_y.get();    
            m(t).bpmi_1925_tl_y_wav = obj.bpm_e.bpmi_1925_tl_wav_y.get();
            m(t).bpmi_1939_tl_y_wav = obj.bpm_e.bpmi_1939_tl_wav_y.get();
            m(t).bpmi_1910_tl_x_wav = obj.bpm_e.bpmi_1910_tl_wav_x.get();
            m(t).bpmi_1930_tl_x_wav = obj.bpm_e.bpmi_1930_tl_wav_x.get();  
            pause(0.2);
        end
    end
    
    function [res, m] = ctrl_scan_trg_del(obj, plane)
        res = 0;
        N=48;
        m.bpm1_up_pos     = zeros(1, N);
        m.bpm2_up_pos     = zeros(1, N);
        m.bpm1_down_pos   = zeros(1, N);
        m.bpm2_down_pos   = zeros(1, N);
        m.trg_del         = zeros(1, N);
        m.pulseid         = zeros(1, N);

        if strcmp(plane, 'Y')
            h_trg = obj.ctrl.y_trg_del;
        end;
        if strcmp(plane, 'X')
            h_trg = obj.ctrl.x_trg_del;
        end;
        trg_init = h_trg.get();
        
        for d=1:N
            h_trg.put(uint32(trg_init-d));
            m.trg_del(d) = trg_init-d;
            pause(0.5);
            [res m] = ctrl_ff_scan_read_single_bunch_pos(obj, m, plane, d);
        end        
        
        h_trg.put(uint32(trg_init));
    end
    
    function [res, m] = ctrl_scan_trg_del_plot(obj, m)
        figure(1);
        clf;
        % upstream BPMs output
        subplot(2, 1, 1);
        plot(m.bpm1_up_pos, 'r');
        hold on;
        plot(m.bpm2_up_pos, 'b');
        grid on;
        title('Upstream BPMs');
        legend('BPM1', 'BPM2');
        % downstream BPMs output
        subplot(2, 1, 2);
        plot(m.bpm1_down_pos, 'r');
        hold on;
        plot(m.bpm2_down_pos, 'b');
        grid on;
        title('Downstream BPMs');
        legend('BPM1', 'BPM2');

    end 
    
    function [res, k] = ctrl_scale_kick_matrix(obj, plane)        
        res=0;
        if strcmp(plane, 'X')
            k(1) = obj.ctrl.x_fb_kicker_m11.get();
            k(2) = obj.ctrl.x_fb_kicker_m12.get();
            k(3) = obj.ctrl.x_fb_kicker_m21.get();
            k(4) = obj.ctrl.x_fb_kicker_m22.get();        
            k = k./max(k);
            obj.ctrl.x_fb_kicker_m11.put(single(k(1)));
            obj.ctrl.x_fb_kicker_m12.put(single(k(2)));
            obj.ctrl.x_fb_kicker_m21.put(single(k(3)));
            obj.ctrl.x_fb_kicker_m22.put(single(k(4)));        
        end
        if strcmp(plane, 'Y')
            k(1) = obj.ctrl.y_fb_kicker_m11.get();
            k(2) = obj.ctrl.y_fb_kicker_m12.get();
            k(3) = obj.ctrl.y_fb_kicker_m21.get();
            k(4) = obj.ctrl.y_fb_kicker_m22.get();        
            k = k./max(k);
            obj.ctrl.y_fb_kicker_m11.put(single(k(1)));
            obj.ctrl.y_fb_kicker_m12.put(single(k(2)));
            obj.ctrl.y_fb_kicker_m21.put(single(k(3)));
            obj.ctrl.y_fb_kicker_m22.put(single(k(4)));        
        end
    end
    
    function [res] = ctrl_ff_train_constant(obj, plane, kicker,n)
      % [res] = ctrl_ff_scan_single(obj, plane, kicker)
      %
      % Parameters:
      %   plane     - select plane 'X', 'Y', 'XY'
      %   kicker    - select kicker 'KICK1', 'KICK2', 'KICK12'
      
      res = obj.ctrl_ff_table_generate('lin',plane,kicker, [-1 -1 0.99 0.99], n);
    end

    function [res] = ctrl_ff_train_lin(obj, plane, kicker)
      % [res] = ctrl_ff_scan_single(obj, plane, kicker)
      %
      % Parameters:
      %   plane     - select plane 'X', 'Y', 'XY'
      %   kicker    - select kicker 'KICK1', 'KICK2', 'KICK12'
      
      res = 0;
      obj.ctrl_ff_table_generate('lin',plane,kicker, [-1 -1 0.99 0.99], 30);
    end

    function [res] = ctrl_ff_train_alternating(obj, plane, kicker)
      % [res] = ctrl_ff_scan_single(obj, plane, kicker)
      %
      % Parameters:
      %   plane     - select plane 'X', 'Y', 'XY'
      %   kicker    - select kicker 'KICK1', 'KICK2', 'KICK12'
      
      res = 0;
      obj.ctrl_ff_table_generate('alt',plane,kicker, [-0.99 0.5 -0.99 0.5], 30);
    end

    function [res] = ctrl_ff_clear(obj)
      % [res] = ctrl_ff_scan_single(obj, plane, kicker)
      %
      % Parameters:
      %   plane     - select plane 'X', 'Y', 'XY'
      %   kicker    - select kicker 'KICK1', 'KICK2', 'KICK12'
      
      res = 0;
      obj.ctrl_ff_table_generate('lin','XY','KICK12', [0 0 0 0], 2707);
    end
    
    
    function [res] = doublet_user_pattern(obj, t, a, plane)
      % Standard doublet
      % 
      % ibfb.doublet_user_pattern([0 2 3 13 14 33 34 44 45], [0 0 -5e3 -30e3 5e3 30e3 -5e3 -30e3 0])
      %
      %                _/|
      %              _/  |
      %            _/    |
      %           /      |
      %          |       |
      %  ----    |       |   -------
      %      |   |       |   |
      %       \  |        \  |
      %        \ |         \ |
      %         \|          \|
      %
      %  1  23  45      67  89
      %
      res = 0;
      if length(t) < 2
        fprintf(2, 'ERROR: the time and amplitude vector lengthe must be bigger than 1\n');
        res = -4;
        return
      end 
      if length(t) ~= length(a)
        fprintf(2, 'ERROR: the time and amplitude vector must have the same size\n');
        res = -1;
        return
      end
      if (min(t) < 0) < (max(t) > 47)
        fprintf(2, 'ERROR: the time vector can have values from 0 to 27\n');
        res = -2;
        return
      end
      if max(abs(a)) > 32767
        fprintf(2, 'ERROR: the amplitude vector can have values from -32767 to 32767\n');
        res = -3;
        return
      end
      p = zeros(1, 48);
      pt = 0:47;
      for i=1:length(t)-1
        p(t(i)+1:t(i+1)+1) = linspace(a(i), a(i+1), t(i+1)-t(i)+1);
      end      
      obj.ctrl.y_kick1_p_pattern.put(int32(p));
      obj.ctrl.y_kick1_n_pattern.put(int32(p));
      obj.ctrl.y_kick2_p_pattern.put(int32(p));
      obj.ctrl.y_kick2_n_pattern.put(int32(p));
      pause(2);
      obj.ctrl.y_dac_pattern_apply.put(int32(1));
      pause(1);
      obj.ctrl.y_dac_pattern_apply.put(int32(0));
      
      %plot(pt, p)
      %grid on
      
    end

    
    % KW84 - Obsolete
    % function [bpms] = ctrl_plot_mgt_rx(obj)
    %   % read data 
    %   elems = obj.ctrl.y_updown_packets.get();
    %   %  rx_tim = obj.ctrl.y_rx_updown_time.get();
    %   rx_ctrl = obj.ctrl.y_rx_updown_ctrl.get();
    %   rx_pos = obj.ctrl.y_rx_updown_pos.get();
    %   % rx_tim = rx_tim(1:elems);
    %   rx_ctrl = rx_ctrl(1:elems);
    %   rx_pos = rx_pos(1:elems);
    %   rx_bucket = bitand(rx_ctrl(1:20), 4095);
    %   rx_bpm = bitand(rx_ctrl(1:20)/2^16, 255);          
    %   bpms = unique(bitand(rx_ctrl(1:20)/2^16, 255));
    %   bpm_num = length(bpms);
    %   
    %   % sort data
    %   for i=1:bpm_num
    %     subplot(bpm_num,1,i);
    %     x = rx_bucket(rx_bpm==bpms(i));
    %     y = rx_pos(rx_bpm==bpms(i));
    %     plot(x, y);
    %     title(['BPM: ' num2str(bpms(i))]);
    %     ylabel('Position [mm]');
    %     xlabel('Bucket');
    %   end
    %   
    % end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% LATTICE FUNCTIONS
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    function [Mx, My] = lattice_calc_m(obj, s0, s)
      %
      % Function ibfb_calc_m calculates transfer matrix from s0 to s
      %
      %  M = ibfb_calc_m(s0, s)
      %
      % s0, s - structures which consists of 
      %          .alfx
      %          .betx
      %          .mux
      %          .alfy
      %          .bety
      %          .muy
      %
      %       | m11    m12 |
      %  M  = |            |
      %       | m21    m22 |
      %     
      %  where
      %      phi = m - m0
      %      m11 = sqrt(b/b0)*(cos(phi)+a0*sin(phi))         
      %      m12 = sqrt(b*b0)*sin(phi)
      %      m21 = (a0-a)*cos(phi)-(1+a0*a)*sin(phi)/sqrt(b0*b)
      %      m22 = sqrt(b0/b)*(cos(phi)-a*sin(phi))
      %
      %syms m11 m12 m21 m22;
      %      m11 = 'sqrt(b/b0)*(cos(phi)+a0*sin(phi))             ';
      %      m12 = 'sqrt(b*b0)*sin(phi)                           ';
      %      m21 = '(a0-a)*cos(phi)-(1+a0*a)*sin(phi)/sqrt(b0*b)  ';
      %      m22 = 'sqrt(b0/b)*(cos(phi)-a*sin(phi))              ';
      %
      %M = [ m11 m12; m21 m22]

      Mx = lattice_calc_m_one_plane(obj, s0.alfx, s0.betx, s0.mux, s.alfx, s.betx, s.mux);
      My = lattice_calc_m_one_plane(obj, s0.alfy, s0.bety, s0.muy, s.alfy, s.bety, s.muy);
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function lattice_process(obj)

      for i=1:size(obj.bpms,2)
          obj.bpms(i).gamx = lattice_calc_gamma(obj, obj.bpms(i).alfx, obj.bpms(i).betx);
          obj.bpms(i).gamy = lattice_calc_gamma(obj, obj.bpms(i).alfy, obj.bpms(i).bety);
          %obj.bpms(i).ex = 0.0024^2*obj.bpms(i).gamx;
          %obj.bpms(i).ey = 0.0028^2*obj.bpms(i).gamy;
          %obj.bpms(i).maxax = sqrt(obj.bpms(i).ex/obj.bpms(i).betx);
          %obj.bpms(i).maxay = sqrt(obj.bpms(i).ey/obj.bpms(i).bety);
          if strcmp(obj.bpms(i).plane, 'X')
              obj.bpms(i).el_eq  = [num2str(obj.bpms(i).gamx) '*x^2 + ' ...
                                    num2str(obj.bpms(i).alfx) '*2*x*y + ' ...    
                                    num2str(obj.bpms(i).betx) '*y^2 - ' num2str(obj.EMITTANCE) ' = 0'];
          else
              obj.bpms(i).el_eq  = [num2str(obj.bpms(i).gamy) '*x^2 + ' ...
                                    num2str(obj.bpms(i).alfy) '*2*x*y + ' ...    
                                    num2str(obj.bpms(i).bety) '*y^2 - ' num2str(obj.EMITTANCE) ' = 0'];
          end
      end
      
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function [res] = lattice_c_code_init(obj, elems)
      
      fd = fopen('lattice.c', 'w');
      
      fprintf(fd, '#include "ibfb_ctrl.h"\n\n');

      fprintf(fd, 'void ibfb_load_lattice_params(struct structIBFBctrl *this) {\n\n');
      
      % empty element for indexing aligment between Matlab and C
      fprintf(fd, '    this->shared->lattice[0].plane = PLANE_X;\n');
      fprintf(fd, '    strcpy((char *)this->shared->lattice[0].name, "EMPTY");\n');
      fprintf(fd, '    this->shared->lattice[0].z = 0.0;\n');
      fprintf(fd, '    this->shared->lattice[0].twissX.beta = 0.0;\n');
      fprintf(fd, '    this->shared->lattice[0].twissX.alfa = 0.0;\n');
      fprintf(fd, '    this->shared->lattice[0].twissX.mu = 0.0;\n');
      fprintf(fd, '    this->shared->lattice[0].twissX.gamma = 0.0;\n');
      fprintf(fd, '    this->shared->lattice[0].twissY.beta = 0.0;\n');
      fprintf(fd, '    this->shared->lattice[0].twissY.alfa = 0.0;\n');
      fprintf(fd, '    this->shared->lattice[0].twissY.mu = 0.0;\n');
      fprintf(fd, '    this->shared->lattice[0].twissY.gamma = 0.0;\n');
      fprintf(fd, '\n');
      
      j=1;
      for i=elems
        fprintf(fd, '    this->shared->lattice[%d].plane = PLANE_%s;\n', j, obj.bpms(i).plane);
        fprintf(fd, '    strcpy((char *)this->shared->lattice[%d].name, "%s");\n', j, obj.bpms(i).name);
        fprintf(fd, '    this->shared->lattice[%d].z = %.2f;\n', j, obj.bpms(i).z);
        fprintf(fd, '    this->shared->lattice[%d].twissX.beta = %.4f;\n', j, obj.bpms(i).betx);
        fprintf(fd, '    this->shared->lattice[%d].twissX.alfa = %.4f;\n', j, obj.bpms(i).alfx);
        fprintf(fd, '    this->shared->lattice[%d].twissX.mu = %.4f;\n', j, obj.bpms(i).mux);
        fprintf(fd, '    this->shared->lattice[%d].twissX.gamma = 0.0;\n', j);
        fprintf(fd, '    this->shared->lattice[%d].twissY.beta = %.4f;\n', j, obj.bpms(i).bety);
        fprintf(fd, '    this->shared->lattice[%d].twissY.alfa = %.4f;\n', j, obj.bpms(i).alfy);
        fprintf(fd, '    this->shared->lattice[%d].twissY.mu = %.4f;\n', j, obj.bpms(i).muy);
        fprintf(fd, '    this->shared->lattice[%d].twissY.gamma = 0.0;\n', j);
        fprintf(fd, '\n');
        j = j + 1;
      end

      fprintf(fd, '    this->lattice_elems = %d;\n', elems(end)+1);      
      
      fprintf(fd, '    return;\n');
      fprintf(fd, '}\n');

      fclose(fd);
    end    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function [res] = lattice_display_table(obj)
    
      fprintf('\nidx:     name        plane\n\n');
      for i=1:length(obj.bpms)
        fprintf('%3d: %16s    %s    %3d  %f %f \n', i, obj.bpms(i).name, obj.bpms(i).plane, obj.bpms(i).betx, obj.bpms(i).bety);
      end
      
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function lattice_plot_orbits(obj, plane)
      figure(1);
      clf;
      ax_range = [-0.004 , 0.004, -.25e-3, .25e-3];
      leg = {};
      for i=2:size(obj.bpms,2)     
          if strcmp(obj.bpms(i).plane, plane)
              h = ezplot(obj.bpms(i).el_eq, ax_range);
              set(h, 'color', [i/21 0 0]);
              hold on
              leg(i-1) = cellstr(obj.bpms(i).name);
          end
      end        
      grid on
      xlabel('y [mm]');
      ylabel('y'' [mrad]');
      legend(leg);
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function M = lattice_calc_m_one_plane(obj, alf0, bet0, mu0, alfs, bets, mus) 
      phi = (mus - mu0);
      M(1,1) = sqrt(bets/bet0)*(cos(phi)+alf0*sin(phi))         ;
      M(1,2) = sqrt(bets*bet0)*sin(phi);
      M(2,1) = ((alf0-alfs)*cos(phi)-(1+alf0*alfs)*sin(phi))/sqrt(bet0*bets);
      M(2,2) = sqrt(bet0/bets)*(cos(phi)-alfs*sin(phi));
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %function res = calc_fft(obj, wav)           
    %  res = 20*log10(abs(fft(wav)));
    %end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% MONITOR FUNCTIONS
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function [res] = mon_read(obj, channels, pulses)
      res = 0;
      if (min(channels) < 1) || (max(channels) > 8)
        fprintf(2, 'ERROR: Invalid channel number\n');
        res = -1; return
      end
      for i=channels
        obj.mon(i).amp_wav    = zeros(pulses, 2048);
        obj.mon(i).kicker_wav = zeros(pulses, 2048);
        for j=1:pulses
          obj.mon(i).amp_wav(j, :)    = double(obj.mon(i).amp_adc_wav.get() )./obj.ADC_RANGE;
          obj.mon(i).kicker_wav(j, :) = double(obj.mon(i).kick_adc_wav.get())./obj.ADC_RANGE;
          pause(0.2);
        end
      end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function mon_plot_fft(obj, channels)
      figure(1)
      clf
      figure(2)
      clf
      plen = length(channels);
      pl=0;
      for i=channels
        pl = pl + 1;
        %----------
        figure(1)
        subplot(plen,2,pl)
        [sf, f, Afloor, Amax, fmax, N] = fftFS(obj, obj.mon(i).amp_wav   , obj.Fs);
        plot(f, sf);
        plot(f(1:N/2), sf(1:N/2))
        hold on
        plot(f(1:N/2), Afloor*ones(1,N/2), '-.r')
        grid on
        ylim([Afloor-10 0])
        xlim([0 f(N/2)]);
        xlabel('Frequency [MHz]')
        ylabel('Amplitude [dBFS]')
        title(['Amplifier ' obj.mon(i).name '  [Fmax = ' num2str(fmax, '%12.6f MHz') ', Amax = ' num2str(Amax) ' dB, Afloor = ' num2str(Afloor) ' dB]'])
        %-----------
        subplot(plen,2,plen+pl)
        [sf, f, Afloor, Amax, fmax, N] = fftFS(obj, obj.mon(i).kicker_wav, obj.Fs);
        plot(f, sf);
        plot(f(1:N/2), sf(1:N/2))
        hold on
        plot(f(1:N/2), Afloor*ones(1,N/2), '-.r')
        grid on
        ylim([Afloor-10 0])
        xlim([0 f(N/2)]);
        xlabel('Frequency [MHz]')
        ylabel('Amplitude [dBFS]')
        title(['Kicker ' obj.mon(i).name '  [Fmax = ' num2str(fmax, '%12.6f MHz') ', Amax = ' num2str(Amax) ' dB, Afloor = ' num2str(Afloor) ' dB]'])
        %-----------
        figure(2)
        subplot(plen,2,pl)
        t = (0:N-1).*1e6./obj.Fs;
        plot(t,obj.mon(i).amp_wav);
        grid on
        xlabel('Time [us]')
        ylabel('Amplitude [Normalized]')
        title(['Amplifier ' obj.mon(i).name ])
        %-----------
        subplot(plen,2,plen+pl)
        t = (0:N-1).*1e6./obj.Fs;
        plot(t,obj.mon(i).kicker_wav);
        grid on
        xlabel('Time [us]')
        ylabel('Amplitude [Normalized]')
        title(['Kicker ' obj.mon(i).name ])
      end
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% SYSTEM TEST FUNCTIONS
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    function [res] = test_init(obj, pair)
      test_record_set(obj, 'IBFBCTRL:Y-AMP-GATE-ENA'        , 'integer', 0);
      test_record_set(obj, 'IBFBCTRL:X-AMP-GATE-ENA'        , 'integer', 0);
      test_record_set(obj, 'IBFBCTRL:Y-DAC-MODE-M'          , 'integer',   2);
      test_record_set(obj, 'IBFBCTRL:X-DAC-MODE-M'          , 'integer',   2);
      for i=1:8
        is = num2str(i);        
        test_record_set(obj, ['IBFBCCOM:AMP-GATE-'             is], 'integer',  9422596);
      end
      for i=1:4
        is = num2str(i-1);        
        test_record_set(obj, ['IBFBCTRL:Y-DAC-MODE-'           is], 'integer',      2);
        test_record_set(obj, ['IBFBCTRL:X-DAC-MODE-'           is], 'integer',      2);
        test_record_set(obj, ['IBFBCTRL:Y-DAC-WAVE-AMPL-'      is], 'double',   0.500);
        test_record_set(obj, ['IBFBCTRL:X-DAC-WAVE-AMPL-'      is], 'double',   0.500);
        test_record_set(obj, ['IBFBCTRL:Y-DAC-WAVE-FREQ-'      is], 'double',  4.5139);
        test_record_set(obj, ['IBFBCTRL:X-DAC-WAVE-FREQ-'      is], 'double',  4.5139);
      end
      test_record_set(obj, 'IBFBCCOM:AMP-LOSS-RST', 'integer',      1);
      pause(0.5);
      test_record_set(obj, 'IBFBCCOM:AMP-LOSS-RST', 'integer',      0);
      
      
      test_record_set(obj, 'IBFBCTRL:Y-AMP-GATE-ENA'        , 'integer', 1);
      test_record_set(obj, 'IBFBCTRL:X-AMP-GATE-ENA'        , 'integer', 1);
    
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function [res] = test_general_records(obj, fd)
      res = 0;

      srvname = cellstr(['IBFBCTRL';'IBFBSW  ';'IBFBMON ']);
      
      for i=1:3
        res = res + test_record_print(obj, [char(srvname(i)) ':GPAC2-SN']          , 'string',  fd);
        res = res + test_record_print(obj, [char(srvname(i)) ':GPAC2-PB1-SN']      , 'string',  fd);
        res = res + test_record_print(obj, [char(srvname(i)) ':GPAC2-PB2-SN']      , 'string',  fd);
        res = res + test_record_print(obj, [char(srvname(i)) ':GPAC2-MAC.SVAL']    , 'string',  fd);
        res = res + test_record_print(obj, [char(srvname(i)) ':CFG-FIRMWARE']    , 'string',  fd);
        res = res + test_record_print(obj, [char(srvname(i)) ':CFG-FW-DATE.SVAL']    , 'string',  fd);
        res = res + test_record_print(obj, [char(srvname(i)) ':CFG-SW-DATE.SVAL']    , 'string',  fd);
        res = res + test_record_print(obj, [char(srvname(i)) ':SYS-FIRMWARE']    , 'string',  fd);
        res = res + test_record_print(obj, [char(srvname(i)) ':SYS-FW-DATE.SVAL']    , 'string',  fd);
        res = res + test_record_print(obj, [char(srvname(i)) ':SYS-SW-DATE.SVAL']    , 'string',  fd);
        res = res + test_record_print(obj, [char(srvname(i)) ':BP-FIRMWARE']    , 'string',  fd);
        res = res + test_record_print(obj, [char(srvname(i)) ':BP-FW-DATE.SVAL']    , 'string',  fd);
        res = res + test_record_print(obj, [char(srvname(i)) ':BP-SW-DATE.SVAL']    , 'string',  fd);
        res = res + test_record_print(obj, [char(srvname(i)) ':BPM1-FIRMWARE']    , 'string',  fd);
        res = res + test_record_print(obj, [char(srvname(i)) ':BPM1-FW-DATE.SVAL']    , 'string',  fd);
        res = res + test_record_print(obj, [char(srvname(i)) ':BPM1-SW-DATE.SVAL']    , 'string',  fd);
        res = res + test_record_print(obj, [char(srvname(i)) ':BPM2-FIRMWARE']    , 'string',  fd);
        res = res + test_record_print(obj, [char(srvname(i)) ':BPM2-FW-DATE.SVAL']    , 'string',  fd);
        res = res + test_record_print(obj, [char(srvname(i)) ':BPM2-SW-DATE.SVAL']    , 'string',  fd);
        res = res + test_record_print(obj, [char(srvname(i)) ':P0HS7-SN']    , 'string',  fd);
        res = res + test_record_value(obj, [char(srvname(i)) ':P0HS7-STATUS']    , 'integer',  65537, 65537, 0, fd);
        res = res + test_record_value(obj, [char(srvname(i)) ':P0HS7-TEMP']    , 'double',  25.0, 35.0, 1, fd);

        res = res + test_record_value(obj, [char(srvname(i)) ':GPAC2-CFG-TMP-BPM1-FPGA']    , 'double',    25.00, 56.00, 2, fd);
        res = res + test_record_value(obj, [char(srvname(i)) ':GPAC2-CFG-TMP-BPM2-FPGA']    , 'double',    25.00, 56.00, 2, fd);
        res = res + test_record_value(obj, [char(srvname(i)) ':GPAC2-CFG-TMP-SYS-FPGA']    , 'double',     25.00, 56.00, 2, fd);
        res = res + test_record_value(obj, [char(srvname(i)) ':GPAC2-CFG-TMP-BPM1-DDR2']    , 'double',    25.00, 56.00, 2, fd);
        res = res + test_record_value(obj, [char(srvname(i)) ':GPAC2-CFG-TMP-BPM2-DDR2']    , 'double',    25.00, 56.00, 2, fd);
        res = res + test_record_value(obj, [char(srvname(i)) ':GPAC2-CFG-TMP-SYS-DDR21']    , 'double',    25.00, 56.00, 2, fd);
        res = res + test_record_value(obj, [char(srvname(i)) ':GPAC2-CFG-TMP-BPM1-QDR2']    , 'double',    25.00, 56.00, 2, fd);
        res = res + test_record_value(obj, [char(srvname(i)) ':GPAC2-CFG-TMP-BPM2-QDR2']    , 'double',    25.00, 56.00, 2, fd);
        res = res + test_record_value(obj, [char(srvname(i)) ':GPAC2-CFG-TMP-SYS-DDR22']    , 'double',    25.00, 56.00, 2, fd);
        res = res + test_record_value(obj, [char(srvname(i)) ':GPAC2-CFG-TMP-BPM1-AIR']    , 'double',     25.00, 56.00, 2, fd);
        res = res + test_record_value(obj, [char(srvname(i)) ':GPAC2-CFG-TMP-BPM2-AIR']    , 'double',     25.00, 56.00, 2, fd);
        res = res + test_record_value(obj, [char(srvname(i)) ':GPAC2-CFG-TMP-BPM1-SENSOR']    , 'double',  25.00, 56.00, 2, fd);
        res = res + test_record_value(obj, [char(srvname(i)) ':GPAC2-CFG-TMP-BPM2-SENSOR']    , 'double',  25.00, 56.00, 2, fd);
        res = res + test_record_value(obj, [char(srvname(i)) ':GPAC2-CFG-TMP-SYS-SENSOR']     , 'double',  25.00, 56.00, 2, fd);
        res = res + test_record_value(obj, [char(srvname(i)) ':GPAC2-CFG-TMP-WARNING']    , 'integer',  75, 76, 0, fd);
        res = res + test_record_value(obj, [char(srvname(i)) ':GPAC2-CFG-TMP-ALARM']    , 'integer',  80, 81, 0, fd);
        res = res + test_record_value(obj, [char(srvname(i)) ':GPAC2-PWR-STATUS']    , 'integer',  3583, 3583, 0, fd);

        res = res + test_record_value(obj, [char(srvname(i)) ':GPAC2-HS5V0CFG-VIN']    , 'double',  4.90, 5.10, 2, fd);
        res = res + test_record_value(obj, [char(srvname(i)) ':GPAC2-HS3V3-VIN']    , 'double',  3.20, 3.40, 2, fd);
        res = res + test_record_value(obj, [char(srvname(i)) ':GPAC2-HS5V0-VIN']    , 'double',  4.90, 5.10, 2, fd);
        res = res + test_record_value(obj, [char(srvname(i)) ':GPAC2-HS3V3PB-VIN']    , 'double',  3.20, 3.40, 2, fd);
        res = res + test_record_value(obj, [char(srvname(i)) ':GPAC2-HS5V0PB-VIN']    , 'double',  4.90, 5.10, 2, fd);
        res = res + test_record_value(obj, [char(srvname(i)) ':GPAC2-HS5V0CFG-VOUT']    , 'double',  4.90, 5.10, 2, fd);
        res = res + test_record_value(obj, [char(srvname(i)) ':GPAC2-HS3V3-VOUT']    , 'double',  3.20, 3.40, 2, fd);
        res = res + test_record_value(obj, [char(srvname(i)) ':GPAC2-HS5V0-VOUT']    , 'double',  4.90, 5.10, 2, fd);
        res = res + test_record_value(obj, [char(srvname(i)) ':GPAC2-HS3V3PB-VOUT']    , 'double',  3.20, 3.40, 2, fd);
        res = res + test_record_value(obj, [char(srvname(i)) ':GPAC2-HS5V0PB-VOUT']    , 'double',  4.90, 5.10, 2, fd);
        switch char(srvname(i))
          case 'IBFBCTRL'
            res = res + test_record_value(obj, [char(srvname(i)) ':GPAC2-HS5V0CFG-I']    , 'double',   0.10,  0.20, 2, fd);
            res = res + test_record_value(obj, [char(srvname(i)) ':GPAC2-HS3V3-I']       , 'double',   5.00,  5.50, 2, fd);
            res = res + test_record_value(obj, [char(srvname(i)) ':GPAC2-HS5V0-I']       , 'double',   4.50,  5.00, 2, fd);
            res = res + test_record_value(obj, [char(srvname(i)) ':GPAC2-HS3V3PB-I']     , 'double',   0.30,  0.40, 2, fd);
            res = res + test_record_value(obj, [char(srvname(i)) ':GPAC2-HS5V0PB-I']     , 'double',   3.00,  3.50, 2, fd);
            res = res + test_record_value(obj, [char(srvname(i)) ':GPAC2-TOTAL-PWR']     , 'double',  55.00, 65.00, 2, fd);
          case 'IBFBSW'
            res = res + test_record_value(obj, [char(srvname(i)) ':GPAC2-HS5V0CFG-I']    , 'double',   0.10,  0.20, 2, fd);
            res = res + test_record_value(obj, [char(srvname(i)) ':GPAC2-HS3V3-I']       , 'double',   7.00,  8.00, 2, fd);
            res = res + test_record_value(obj, [char(srvname(i)) ':GPAC2-HS5V0-I']       , 'double',   2.50,  3.50, 2, fd);
            res = res + test_record_value(obj, [char(srvname(i)) ':GPAC2-HS3V3PB-I']     , 'double',   1.50,  2.50, 2, fd);
            res = res + test_record_value(obj, [char(srvname(i)) ':GPAC2-HS5V0PB-I']     , 'double',   0.00,  0.00, 2, fd);
            res = res + test_record_value(obj, [char(srvname(i)) ':GPAC2-TOTAL-PWR']     , 'double',  45.00, 50.00, 2, fd);
          case 'IBFBMON'
            res = res + test_record_value(obj, [char(srvname(i)) ':GPAC2-HS5V0CFG-I']    , 'double',   0.10,  0.20, 2, fd);
            res = res + test_record_value(obj, [char(srvname(i)) ':GPAC2-HS3V3-I']       , 'double',   5.00,  6.00, 2, fd);
            res = res + test_record_value(obj, [char(srvname(i)) ':GPAC2-HS5V0-I']       , 'double',   5.00,  6.00, 2, fd);
            res = res + test_record_value(obj, [char(srvname(i)) ':GPAC2-HS3V3PB-I']     , 'double',   3.00,  4.00, 2, fd);
            res = res + test_record_value(obj, [char(srvname(i)) ':GPAC2-HS5V0PB-I']     , 'double',   2.00,  3.00, 2, fd);
            res = res + test_record_value(obj, [char(srvname(i)) ':GPAC2-TOTAL-PWR']     , 'double',  60.00, 70.00, 2, fd);
        end
        switch char(srvname(i))
          case 'IBFBCTRL'
            res = res + test_record_value(obj, [char(srvname(i)) ':RTMG-SFP2']    , 'integer',   522127135,  522127135, 0, fd);
            res = res + test_record_value(obj, [char(srvname(i)) ':RTMG-SFP1']    , 'integer',   117901063,  117901063, 0, fd);
          case 'IBFBSW'
            res = res + test_record_value(obj, [char(srvname(i)) ':RTMG-SFP2']    , 'integer',   522127135,  522127135, 0, fd);
            res = res + test_record_value(obj, [char(srvname(i)) ':RTMG-SFP1']    , 'integer',   522127111,  522127111, 0, fd);
          case 'IBFBMON'
            res = res + test_record_value(obj, [char(srvname(i)) ':RTMG-SFP2']    , 'integer',   522127135,  522127135, 0, fd);
            res = res + test_record_value(obj, [char(srvname(i)) ':RTMG-SFP1']    , 'integer',   522133279,  522133279, 0, fd);
        end
        switch char(srvname(i))
          case 'IBFBCTRL'
            res = res + test_record_value(obj, [char(srvname(i)) ':Y-RTMG-GTX-STATUS']    , 'integer',   65543,  65543, 0, fd);
            res = res + test_record_value(obj, [char(srvname(i)) ':X-RTMG-GTX-STATUS']    , 'integer',   65543,  65543, 0, fd);
            res = res + test_record_value(obj, [char(srvname(i)) ':Y-UPDOWN-LOSS-CNT']    , 'integer',       0,      0, 0, fd);
            res = res + test_record_value(obj, [char(srvname(i)) ':Y-SASE-LOSS-CNT']      , 'integer',       0,      0, 0, fd);
            res = res + test_record_value(obj, [char(srvname(i)) ':X-UPDOWN-LOSS-CNT']    , 'integer',       0,      0, 0, fd);
            res = res + test_record_value(obj, [char(srvname(i)) ':X-SASE-LOSS-CNT']      , 'integer',       0,      0, 0, fd);
            res = res + test_record_value(obj, [char(srvname(i)) ':Y-UPDOWN-BAD-DATA']      , 'integer',       0,      0, 0, fd);
            res = res + test_record_value(obj, [char(srvname(i)) ':Y-SASE-BAD-DATA']      , 'integer',       0,      0, 0, fd);
            res = res + test_record_value(obj, [char(srvname(i)) ':X-UPDOWN-BAD-DATA']      , 'integer',       0,      0, 0, fd);
            res = res + test_record_value(obj, [char(srvname(i)) ':X-SASE-BAD-DATA']      , 'integer',       0,      0, 0, fd);
            res = res + test_record_value(obj, [char(srvname(i)) ':Y-UPDOWN-CRC-ERR']      , 'integer',       0,      0, 0, fd);
            res = res + test_record_value(obj, [char(srvname(i)) ':Y-SASE-CRC-ERR']      , 'integer',       0,      0, 0, fd);
            res = res + test_record_value(obj, [char(srvname(i)) ':X-UPDOWN-CRC-ERR']      , 'integer',       0,      0, 0, fd);
            res = res + test_record_value(obj, [char(srvname(i)) ':X-SASE-CRC-ERR']      , 'integer',       0,      0, 0, fd);
            res = res + test_record_value(obj, [char(srvname(i)) ':Y-UPDOWN-PACKETS']      , 'integer',     2700,      2700, 0, fd);
            res = res + test_record_value(obj, [char(srvname(i)) ':X-UPDOWN-PACKETS']      , 'integer',     2700,      2700, 0, fd);
            res = res + test_record_value(obj, [char(srvname(i)) ':Y-SASE-PACKETS']      , 'integer',     7700,      7700, 0, fd);
            res = res + test_record_value(obj, [char(srvname(i)) ':X-SASE-PACKETS']      , 'integer',     5000,      5000, 0, fd);
            res = res + test_record_value(obj, [char(srvname(i)) ':Y-UPDOWN-DELAY']      , 'integer',    65600,      65850, 0, fd);
            res = res + test_record_value(obj, [char(srvname(i)) ':Y-SASE-DELAY']      , 'integer',    65600,      65850, 0, fd);
            res = res + test_record_value(obj, [char(srvname(i)) ':X-UPDOWN-DELAY']      , 'integer',    65600,      65850, 0, fd);
            res = res + test_record_value(obj, [char(srvname(i)) ':X-SASE-DELAY']      , 'integer',    65600,      65850, 0, fd);
          case 'IBFBSW'
            res = res + test_record_value(obj, [char(srvname(i)) ':QSFP1-SFP-IN']      , 'integer',    16843009,      16843009, 0, fd);
            res = res + test_record_value(obj, [char(srvname(i)) ':QSFP1-RX-LOSS']      , 'integer',    0,      0, 0, fd);
            res = res + test_record_value(obj, [char(srvname(i)) ':QSFP2-SFP-IN']      , 'integer',    16843009,      16843009, 0, fd);
            res = res + test_record_value(obj, [char(srvname(i)) ':QSFP2-RX-LOSS']      , 'integer',    1,      1, 0, fd);
            res = res + test_record_value(obj, [char(srvname(i)) ':SW1-GTX-QSFP02-STATUS']      , 'integer',    71,      71, 0, fd);
            res = res + test_record_value(obj, [char(srvname(i)) ':SW1-GTX-QSFP13-STATUS']      , 'integer',    71,      71, 0, fd);
            res = res + test_record_value(obj, [char(srvname(i)) ':SW1-GTX-QSFP0-LOSS-CNT']      , 'integer',    0,      0, 0, fd);
            res = res + test_record_value(obj, [char(srvname(i)) ':SW1-GTX-QSFP1-LOSS-CNT']      , 'integer',    0,      0, 0, fd);
            res = res + test_record_value(obj, [char(srvname(i)) ':SW1-GTX-QSFP2-LOSS-CNT']      , 'integer',    0,      0, 0, fd);
            res = res + test_record_value(obj, [char(srvname(i)) ':SW1-GTX-QSFP3-LOSS-CNT']      , 'integer',    0,      0, 0, fd);
            res = res + test_record_value(obj, [char(srvname(i)) ':SW2-GTX-QSFP02-STATUS']      , 'integer',    71,      71, 0, fd);
            res = res + test_record_value(obj, [char(srvname(i)) ':SW2-GTX-QSFP13-STATUS']      , 'integer',   103,      103, 0, fd);
            res = res + test_record_value(obj, [char(srvname(i)) ':SW2-GTX-QSFP0-LOSS-CNT']      , 'integer',    0,      0, 0, fd);
            res = res + test_record_value(obj, [char(srvname(i)) ':SW2-GTX-QSFP1-LOSS-CNT']      , 'integer',    0,      0, 0, fd);
            res = res + test_record_value(obj, [char(srvname(i)) ':SW2-GTX-QSFP2-LOSS-CNT']      , 'integer',    0,      0, 0, fd);
            res = res + test_record_value(obj, [char(srvname(i)) ':FILT-SASE1-DOWNSTREAM-PACKETS']      , 'integer',    10800,   10800, 0, fd);
            res = res + test_record_value(obj, [char(srvname(i)) ':FILT-SASE1-UPSTREAM-PACKETS']        , 'integer',    10800,   10800, 0, fd);
            res = res + test_record_value(obj, [char(srvname(i)) ':FILT-SASE2-DOWNSTREAM-PACKETS']      , 'integer',    10800,   10800, 0, fd);
            res = res + test_record_value(obj, [char(srvname(i)) ':FILT-SASE2-UPSTREAM-PACKETS']        , 'integer',    10800,   10800, 0, fd);
            res = res + test_record_value(obj, [char(srvname(i)) ':FILT-SASE3-DOWNSTREAM-PACKETS']      , 'integer',    10800,   10800, 0, fd);
            res = res + test_record_value(obj, [char(srvname(i)) ':FILT-SASE3-UPSTREAM-PACKETS']        , 'integer',    10800,   10800, 0, fd);
            res = res + test_record_value(obj, [char(srvname(i)) ':FILT-COLL-UPSTREAM-PACKETS']         , 'integer',     2700,    2700, 0, fd);
            res = res + test_record_value(obj, [char(srvname(i)) ':Y-FILT-SASE1-DISCARD']      , 'integer',    0,   0, 0, fd);
            res = res + test_record_value(obj, [char(srvname(i)) ':X-FILT-SASE1-DISCARD']      , 'integer',    0,   0, 0, fd);
            res = res + test_record_value(obj, [char(srvname(i)) ':Y-FILT-SASE2-DISCARD']      , 'integer',    0,   0, 0, fd);
            res = res + test_record_value(obj, [char(srvname(i)) ':X-FILT-SASE2-DISCARD']      , 'integer',    0,   0, 0, fd);
            res = res + test_record_value(obj, [char(srvname(i)) ':Y-FILT-SASE3-DISCARD']      , 'integer',    0,   0, 0, fd);
            res = res + test_record_value(obj, [char(srvname(i)) ':X-FILT-SASE3-DISCARD']      , 'integer',    0,   0, 0, fd);
            res = res + test_record_value(obj, [char(srvname(i)) ':FILT-COLL-DISCARD']       , 'integer',    0,   0, 0, fd);
            res = res + test_record_value(obj, [char(srvname(i)) ':Y-FILT-SASE1-INVALID-BPM']      , 'integer',    0,   0, 0, fd);
            res = res + test_record_value(obj, [char(srvname(i)) ':X-FILT-SASE1-INVALID-BPM']      , 'integer',    0,   0, 0, fd);
            res = res + test_record_value(obj, [char(srvname(i)) ':Y-FILT-SASE2-INVALID-BPM']      , 'integer',    0,   0, 0, fd);
            res = res + test_record_value(obj, [char(srvname(i)) ':X-FILT-SASE2-INVALID-BPM']      , 'integer',    0,   0, 0, fd);
            res = res + test_record_value(obj, [char(srvname(i)) ':Y-FILT-SASE3-INVALID-BPM']      , 'integer',    0,   0, 0, fd);
            res = res + test_record_value(obj, [char(srvname(i)) ':X-FILT-SASE3-INVALID-BPM']      , 'integer',    0,   0, 0, fd);
            res = res + test_record_value(obj, [char(srvname(i)) ':FILT-COLL-INVALID-BPM']       , 'integer',    0,   0, 0, fd);
            res = res + test_record_value(obj, [char(srvname(i)) ':Y-FILT-SASE1-PASSED']      , 'integer',   1800,   1800, 0, fd);
            res = res + test_record_value(obj, [char(srvname(i)) ':X-FILT-SASE1-PASSED']      , 'integer',   1800,   1800, 0, fd);
            res = res + test_record_value(obj, [char(srvname(i)) ':Y-FILT-SASE2-PASSED']      , 'integer',   1800,   1800, 0, fd);
            res = res + test_record_value(obj, [char(srvname(i)) ':X-FILT-SASE2-PASSED']      , 'integer',   1800,   1800, 0, fd);
            res = res + test_record_value(obj, [char(srvname(i)) ':Y-FILT-SASE3-PASSED']      , 'integer',   1400,   1400, 0, fd);
            res = res + test_record_value(obj, [char(srvname(i)) ':X-FILT-SASE3-PASSED']      , 'integer',   1400,   1400, 0, fd);
            res = res + test_record_value(obj, [char(srvname(i)) ':FILT-COLL-PASSED']         , 'integer',   2700,   2700, 0, fd);
            res = res + test_record_value(obj, [char(srvname(i)) ':ROUTER1-OUT-ENA']          , 'integer',   160,   160, 0, fd);
            res = res + test_record_value(obj, [char(srvname(i)) ':ROUTER2-OUT-ENA']          , 'integer',    80,    80, 0, fd);
            res = res + test_record_value(obj, [char(srvname(i)) ':SW1-GTX-BPM01-STATUS']          , 'integer',    71,    71, 0, fd);
            res = res + test_record_value(obj, [char(srvname(i)) ':SW1-GTX-BPM0-LOSS-CNT']          , 'integer',    0,    0, 0, fd);
            res = res + test_record_value(obj, [char(srvname(i)) ':SW1-GTX-BPM1-LOSS-CNT']          , 'integer',    0,    0, 0, fd);
            res = res + test_record_value(obj, [char(srvname(i)) ':SW1-GTX-P0-STATUS']          , 'integer',    71,    71, 0, fd);
            res = res + test_record_value(obj, [char(srvname(i)) ':SW1-GTX-P0-0-LOSS-CNT']          , 'integer',    0,    0, 0, fd);
            res = res + test_record_value(obj, [char(srvname(i)) ':SW1-GTX-P0-1-LOSS-CNT']          , 'integer',    0,    0, 0, fd);
          case 'IBFBMON'
        end
        res = res + test_record_value(obj, [char(srvname(i)) ':XFELTIM-STATUS']          , 'integer',    1,    1, 0, fd);
        res = res + test_record_value(obj, [char(srvname(i)) ':XFELTIM-B1-START']          , 'integer',    0,    0, 0, fd);
        res = res + test_record_value(obj, [char(srvname(i)) ':XFELTIM-B1-DURATION']          , 'integer',    900,    900, 0, fd);
        res = res + test_record_value(obj, [char(srvname(i)) ':XFELTIM-B1-INCREMENT']          , 'integer',    9,    9, 0, fd);
        res = res + test_record_value(obj, [char(srvname(i)) ':XFELTIM-B1-LENGTH']          , 'integer',    80,    80, 0, fd);
        
      end
    
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function [res] = test_check_records(obj, pair, fd)
      AMP_PAIR=pair;
      res = 0;

      fprintf(fd, '#---- Timing settings ----\n');
      res = res + test_record_value(obj, 'IBFBCTRL:Y-TRG-SOURCE'          , 'integer',  0,  0, 0, fd);
      res = res + test_record_value(obj, 'IBFBCTRL:X-TRG-SOURCE'          , 'integer',  0,  0, 0, fd);
      res = res + test_record_value(obj, 'IBFBCTRL:Y-TRG-MODE'            , 'integer',  0,  0, 0, fd);
      res = res + test_record_value(obj, 'IBFBCTRL:X-TRG-MODE'            , 'integer',  0,  0, 0, fd);
      res = res + test_record_value(obj, 'IBFBCTRL:Y-TRG-DEL'             , 'integer',  65535,  65535, 0, fd);
      res = res + test_record_value(obj, 'IBFBCTRL:X-TRG-DEL'             , 'integer',  65535,  65535, 0, fd);
      res = res + test_record_value(obj, 'IBFBCTRL:Y-BUNCH-NUM'           , 'integer',  2700,  2700, 0, fd);
      res = res + test_record_value(obj, 'IBFBCTRL:X-BUNCH-NUM'           , 'integer',  2700,  2700, 0, fd);
      res = res + test_record_value(obj, 'IBFBCTRL:Y-BUNCH-SPACE'         , 'integer',   1,  1, 0, fd);
      res = res + test_record_value(obj, 'IBFBCTRL:X-BUNCH-SPACE'         , 'integer',   1,  1, 0, fd);
      res = res + test_record_value(obj, 'IBFBCTRL:Y-TRG-EXT-MISSING'     , 'integer',   0,  0, 0, fd);
      res = res + test_record_value(obj, 'IBFBCTRL:X-TRG-EXT-MISSING'     , 'integer',   0,  0, 0, fd);
      res = res + test_record_value(obj, 'IBFBCTRL:CLK-EXTERNAL'          , 'integer',   1,  1, 0, fd);
      res = res + test_record_value(obj, 'IBFBCTRL:Y-AMP-GATE-ENA'        , 'integer',   1,  1, 0, fd);
      res = res + test_record_value(obj, 'IBFBCTRL:X-AMP-GATE-ENA'        , 'integer',   1,  1, 0, fd);
      res = res + test_record_value(obj, 'IBFBCTRL:Y-AMP-GATE-ADVANCE'    , 'integer',   -1085,  -1085, 0, fd);
      res = res + test_record_value(obj, 'IBFBCTRL:X-AMP-GATE-ADVANCE'    , 'integer',   -1085,  -1085, 0, fd);
      res = res + test_record_value(obj, 'IBFBCTRL:Y-KICK1-SCALE'         , 'double' ,   1.0,  1.0, 3, fd);
      res = res + test_record_value(obj, 'IBFBCTRL:X-KICK1-SCALE'         , 'double' ,   1.0,  1.0, 3, fd);

      res = res + test_record_value(obj, 'IBFBMON1:TRG-SOURCE'            , 'integer',  0,  0, 0, fd);
      res = res + test_record_value(obj, 'IBFBMON1:TRG-MODE'              , 'integer',  0,  0, 0, fd);
      res = res + test_record_value(obj, 'IBFBMON1:TRG-DEL'               , 'integer',  65735,  65735, 0, fd);
      res = res + test_record_value(obj, 'IBFBMON1:BUNCH-NUM'             , 'integer',  2700,  2700, 0, fd);
      res = res + test_record_value(obj, 'IBFBMON1:BUNCH-SPACE'           , 'integer',   1,  1, 0, fd);
      res = res + test_record_value(obj, 'IBFBMON1:TRG-EXT-MISSING'       , 'integer',   0,  0, 0, fd);
      res = res + test_record_value(obj, 'IBFBMON2:TRG-SOURCE'            , 'integer',  0,  0, 0, fd);
      res = res + test_record_value(obj, 'IBFBMON2:TRG-MODE'              , 'integer',  0,  0, 0, fd);
      res = res + test_record_value(obj, 'IBFBMON2:TRG-DEL'               , 'integer',  65735,  65735, 0, fd);
      res = res + test_record_value(obj, 'IBFBMON2:BUNCH-NUM'             , 'integer',  2700,  2700, 0, fd);
      res = res + test_record_value(obj, 'IBFBMON2:BUNCH-SPACE'           , 'integer',   1,  1, 0, fd);
      res = res + test_record_value(obj, 'IBFBMON2:TRG-EXT-MISSING'       , 'integer',   0,  0, 0, fd);
      
      fprintf(fd, '#---- Kicker attenuators fan control ----\n');
      for i=AMP_PAIR
        is = num2str(i);        
        res = res + test_record_value(obj, ['IBFBSWCOM:KICK-ATTN-FAN-RST-'   is], 'integer',  0,  0, 0, fd);
        res = res + test_record_value(obj, ['IBFBSWCOM:KICK-ATTN-FAN-SPEED-' is], 'integer', 50, 50, 0, fd);
        res = res + test_record_value(obj, ['IBFBSWCOM:KICK-ATTN-FAN-TACHO-' is], 'integer', 2900, 3100, 0, fd);
      end
      fprintf(fd, '#---- Amplifier control ----\n');
      for i=AMP_PAIR
        is = num2str(i);        
        res = res + test_record_value(obj, ['IBFBCCOM:AMP-ALIGNED-'          is], 'integer',  19140865,  19140865, 0, fd);
        res = res + test_record_value(obj, ['IBFBCCOM:AMP-LINK-DELAY-'       is], 'integer',  1,  1, 0, fd);
        res = res + test_record_value(obj, ['IBFBCCOM:AMP-LINK-SPEED-'       is], 'double',  6.25,  6.25, 2, fd);
        res = res + test_record_value(obj, ['IBFBCCOM:AMP-GATE-'             is], 'integer',  9422596,  9422596, 0, fd);
        res = res + test_record_value(obj, ['IBFBCCOM:AMP-GATE-DELAY-'       is], 'double',  290.0,  300.0, 3, fd);
        res = res + test_record_value(obj, ['IBFBCCOM:AMP-GATE-LENGTH-'      is], 'double',  598.0,  599.0, 3, fd);
      end

      fprintf(fd, '#---- DAC control ----\n');
      res = res + test_record_value(obj, 'IBFBCTRL:Y-DAC-NO-EXT-CLK'            , 'integer' ,   0,  0, 0, fd);
      res = res + test_record_value(obj, 'IBFBCTRL:X-DAC-NO-EXT-CLK'            , 'integer' ,   0,  0, 0, fd);
      res = res + test_record_value(obj, 'IBFBCTRL:Y-DAC-PLL1-LOCKED'           , 'integer' ,   16777216,  16777216, 0, fd);
      res = res + test_record_value(obj, 'IBFBCTRL:X-DAC-PLL1-LOCKED'           , 'integer' ,   16777216,  16777216, 0, fd);
      res = res + test_record_value(obj, 'IBFBCTRL:Y-DAC-PLL2-LOCKED'           , 'integer' ,   16777216,  16777216, 0, fd);
      res = res + test_record_value(obj, 'IBFBCTRL:X-DAC-PLL2-LOCKED'           , 'integer' ,   16777216,  16777216, 0, fd);
      res = res + test_record_value(obj, 'IBFBCTRL:Y-DCM-LOCKED'                , 'integer' ,   16843009,  16843009, 0, fd);
      res = res + test_record_value(obj, 'IBFBCTRL:X-DCM-LOCKED'                , 'integer' ,   16843009,  16843009, 0, fd);
      for i=1:4
        is = num2str(i-1);        
        res = res + test_record_value(obj, ['IBFBCTRL:Y-DAC-TEMP-'           is], 'double',  33.0,  45.0, 1, fd);
        res = res + test_record_value(obj, ['IBFBCTRL:X-DAC-TEMP-'           is], 'double',  33.0,  45.0, 1, fd);
        res = res + test_record_value(obj, ['IBFBCTRL:Y-DCM-FREQ-'           is], 'double',  216.660,  216.662, 3, fd);
        res = res + test_record_value(obj, ['IBFBCTRL:X-DCM-FREQ-'           is], 'double',  216.660,  216.662, 3, fd);
        res = res + test_record_value(obj, ['IBFBCTRL:Y-DAC-AMP-ENA-'        is], 'integer',  1,  1, 0, fd);
        res = res + test_record_value(obj, ['IBFBCTRL:X-DAC-AMP-ENA-'        is], 'integer',  1,  1, 0, fd);
        res = res + test_record_value(obj, ['IBFBCTRL:Y-DAC-ENA-'            is], 'integer',  1,  1, 0, fd);
        res = res + test_record_value(obj, ['IBFBCTRL:X-DAC-ENA-'            is], 'integer',  1,  1, 0, fd);
        res = res + test_record_value(obj, ['IBFBCTRL:Y-DAC-AMP-CMV-'        is], 'integer',  850,  850, 0, fd);
        res = res + test_record_value(obj, ['IBFBCTRL:X-DAC-AMP-CMV-'        is], 'integer',  850,  850, 0, fd);
        res = res + test_record_value(obj, ['IBFBCTRL:Y-DAC-COMP-REF-'       is], 'integer',   0,  0, 0, fd);
        res = res + test_record_value(obj, ['IBFBCTRL:X-DAC-COMP-REF-'       is], 'integer',   0,  0, 0, fd);
        res = res + test_record_value(obj, ['IBFBCTRL:Y-DAC-MODE-'           is], 'integer',   2,  2, 0, fd);
        res = res + test_record_value(obj, ['IBFBCTRL:X-DAC-MODE-'           is], 'integer',   2,  2, 0, fd);
        res = res + test_record_value(obj, ['IBFBCTRL:Y-DAC-WAVE-AMPL-'      is], 'double',  0.500,  0.500, 3, fd);
        res = res + test_record_value(obj, ['IBFBCTRL:X-DAC-WAVE-AMPL-'      is], 'double',  0.500,  0.500, 3, fd);
        res = res + test_record_value(obj, ['IBFBCTRL:Y-DAC-WAVE-FREQ-'      is], 'double',  4.513,  4.515, 3, fd);
        res = res + test_record_value(obj, ['IBFBCTRL:X-DAC-WAVE-FREQ-'      is], 'double',  4.513,  4.515, 3, fd);
        res = res + test_record_value(obj, ['IBFBCTRL:Y-DAC-WAVE-PHASE-'     is], 'double',  0,  0, 0, fd);
        res = res + test_record_value(obj, ['IBFBCTRL:X-DAC-WAVE-PHASE-'     is], 'double',  0,  0, 0, fd);
      end
      
      for i=AMP_PAIR
        is = num2str(i-1);        
        test_record_print(obj, ['IBFBMON1:ADC-WAV-'   is], 'integer[]', fd);
        test_record_print(obj, ['IBFBMON2:ADC-WAV-'   is], 'integer[]', fd);
      end

      
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function [res] = test_generate(obj)
      fname = 'Test_result.txt';
      fd = fopen(fname, 'w');
      if (fd == -1)
        disp(['ERROR: Cant create result file ' fname]);
        err=1;
        return;
      end

      pair_str = '7-8';
      pair = 7:8;
      generate_report_header(obj, fd, pair);
      res = test_check_records(obj, pair, fd);
      if res
        fprintf(2, 'Test aborted. It contains %d errors\n', res);
        return
      end
      pause(2);
      mon_read(obj, pair);
      mon_plot_fft(obj, pair);
      h=figure(1);
      set(h, 'Position', [0 0 1400 700])
      set(h, 'PaperPositionMode', 'auto')      
      figname = ['TestResult_PSI_IBFB-1.0_Test_Channels_' pair_str '_' datestr(datetime,'yymmdd-HHMMSS') '_Spectrum.jpg'];
      saveas(h, figname)
      h=figure(2);
      set(h, 'Position', [0 0 1400 700])
      set(h, 'PaperPositionMode', 'auto')
      figname = ['TestResult_PSI_IBFB-1.0_Test_Channels_' pair_str '_' datestr(datetime,'yymmdd-HHMMSS') '_Samples.jpg'];
      saveas(h, figname)
      
      if res
        copyfile(fname,['TestResult_PSI_IBFB-1.0_Test_Channels_' pair_str '_' datestr(datetime,'yymmdd-HHMMSS') '_FAULT.txt']);
      else
        copyfile(fname,['TestResult_PSI_IBFB-1.0_Test_Channels_' pair_str '_' datestr(datetime,'yymmdd-HHMMSS') '_OK.txt']);
      end

    end 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function [res] = test_generate_general(obj)
      fname = 'Test_result.txt';
      fd = fopen(fname, 'w');
      if (fd == -1)
        disp(['ERROR: Cant create result file ' fname]);
        err=1;
        return;
      end

      test_generate_general_report_header(obj, fd);
      
      res = test_general_records(obj, fd);
      if res
        fprintf(2, 'Test aborted. It contains %d errors\n', res);
        return
      end
      
      if res
        copyfile(fname,['TestResult_PSI_IBFB-1.0_Test_General_' datestr(datetime,'yymmdd-HHMMSS') '_FAULT.txt']);
      else
        copyfile(fname,['TestResult_PSI_IBFB-1.0_Test_General_' datestr(datetime,'yymmdd-HHMMSS') '_OK.txt']);
      end

    end 
    
    % KW84 - Obsolete function
    %function [res] = ctrl_rx_dump_memory(obj, plane)
    %
    %  if strcmp(plane, 'Y')
    %    obj.mem.timestamp = obj.ctrl.y_rx_updown_time.get();
    %    ctrl_word = obj.ctrl.y_rx_updown_ctrl.get();
    %    obj.mem.ctrl_word = ctrl_word;
    %    obj.mem.bpmid = get_bpm_from_control_word(obj, ctrl_word);
    %    obj.mem.bucket = get_bucket_from_control_word(obj, ctrl_word);
    %    obj.mem.pos = obj.ctrl.y_rx_updown_pos.get();
    %    obj.mem.updown_packets = obj.ctrl.y_updown_packets.get();
    %    obj.mem.sase_packets = obj.ctrl.y_sase_packets.get();
    %  else
    %    obj.mem.timestamp = obj.ctrl.x_rx_updown_time.get();
    %    ctrl_word = obj.ctrl.x_rx_updown_ctrl.get();
    %    obj.mem.ctrl_word = ctrl_word;
    %    obj.mem.bpmid = get_bpm_from_control_word(obj, ctrl_word);
    %    obj.mem.bucket = get_bucket_from_control_word(obj, ctrl_word);
    %    obj.mem.pos = obj.ctrl.x_rx_updown_pos.get();
    %    obj.mem.updown_packets = obj.ctrl.x_updown_packets.get();
    %    obj.mem.sase_packets = obj.ctrl.x_sase_packets.get();
    %  end
    %  
    %  %save(fname, '-struct','obj.mem');
    %end
    % 
    % function bpm = get_bpm_from_control_word(obj, table)
    %   bpm = bitand(bitshift(table, -16), 255);
    % end
    % 
    % function bpm = get_bucket_from_control_word(obj, table)
    %   bpm = bitand(table, 65535);
    % end
    % 
    % function bpm = analyze_rx_strem(obj)
    %   %if obj.mem.updown_packets > 2700
    %   if obj.mem.sase_packets > 2700
    %     p = 2700;
    %   else
    %     p = obj.mem.sase_packets;
    %   end
    %   mintim = min(obj.mem.timestamp(1:p));
    %   bpmids = unique(obj.mem.bpmid(1:p));
    %   bpms = length(bpmids);
    %   fprintf('Found %d BPMs with numbers [%s]\n', bpms, num2str(bpmids'));
    %   for i=1:bpms        
    %     idxs = find(obj.mem.bpmid(1:p) == bpmids(i));
    %     obj.mem.bpm(i).bucket = obj.mem.bucket(idxs);
    %     obj.mem.bpm(i).timestamp = obj.mem.timestamp(idxs);
    %     obj.mem.bpm(i).pos = obj.mem.pos(idxs);
    %     obj.mem.bpm(i).timediff = diff(obj.mem.bpm(i).timestamp);        
    %   end
    %   %
    %   figure(1);
    %   clf
    %   for i=1:bpms       
    %     subplot(bpms+1, 2, i*2-1);
    %     plot(obj.mem.bpm(i).bucket, obj.mem.bpm(i).pos);
    %     grid on;
    %     xlabel('Bucket number');
    %     ylabel('Position [mm]');
    %     title(['BPM ' num2str(bpmids(i))]);
    %     subplot(bpms+1, 2, i*2);
    %     arriv=unique(obj.mem.bpm(i).timediff);
    %     bins = double((min(arriv)):max(arriv));
    %     hist(obj.mem.bpm(i).timediff, bins);
    %     title([num2str(length(obj.mem.bpm(i).pos)) ' bunches from ' num2str(min(obj.mem.bpm(i).bucket)) ' to '  num2str(max(obj.mem.bpm(i).bucket))])
    %   end
    %   figcols = ['b.';'r.';'g.';'c.'];
    %   subplot(bpms+1, 2, bpms*2+1);
    %   for i=1:bpms             
    %     plot(obj.mem.bpm(i).timestamp-mintim, obj.mem.bpm(i).pos, figcols(i,:));
    %     hold on
    %     if max(diff(obj.mem.bpm(i).bucket)) > 1
    %       fprintf('WARNING: BPM %d has gaps in buckets\n', bpmids(i));
    %     end
    %   end
    %   legend(num2str(bpmids))
    %   xlabel('Timestamp [216.6 MHz clock cycles]');
    %   ylabel('Position [mm]');
    %   grid on;
    %   
    % end
   
    function [res, scan] = dac_phase_scan(obj)
      res = 0;
      
      cmd_y = obj.ctrl.y_dcm_ps_cmd;
      dac_mode_y = obj.ctrl.y_dac_mode_m;
      cmd_x = obj.ctrl.x_dcm_ps_cmd;
      dac_mode_x = obj.ctrl.x_dac_mode_m;
      
      scan.dac = zeros(256,8);
      
      % set dac mode
      dac_mode_y.put(uint32(9));
      dac_mode_x.put(uint32(9));
      % reset phase shifter
      cmd_y.put(uint32(hex2dec('02020202')));
      cmd_x.put(uint32(hex2dec('02020202')));
      pause(0.4);
      cmd_y.put(uint32(0));
      cmd_x.put(uint32(0));
      pause(0.4);
      % scan
      for i=1:256
        fprintf('.');
        for j=1:4
          scan.dac(i, j  ) = mean(obj.mon(j  ).amp_adc_wav.get());
          scan.dac(i, j+4) = mean(obj.mon(j+4).amp_adc_wav.get());
        end
        cmd_x.put(uint32(hex2dec('01010101')));        
        cmd_y.put(uint32(hex2dec('01010101')));        
        pause(0.3);
        cmd_x.put(uint32(0));
        cmd_y.put(uint32(0));
        pause(0.3);
      end
      % reset phase shifter
      cmd_y.put(uint32(hex2dec('02020202')));
      cmd_x.put(uint32(hex2dec('02020202')));
      pause(0.4);
      cmd_y.put(uint32(0));
      cmd_x.put(uint32(0));
      pause(0.4);
      
      % plot results
      figcols = ['b';'r';'g';'c'];
      x = (12/(256*1.3)).*[0:255];
      figure(1)
      clf
      for i=1:4
        subplot(2,1,1);
        plot(x, scan.dac(:,i), figcols(i,:));
        hold on
        subplot(2,1,2);
        plot(x, scan.dac(:,i+4), figcols(i,:));
        hold on
      end
      subplot(2,1,1);
      grid on
      legend('DAC0', 'DAC1', 'DAC2', 'DAC3');
      xlabel('time [ns]')
      ylabel('ADC counts')
      title('DAC16HL - PB1')
      subplot(2,1,2);
      grid on
      legend('DAC0', 'DAC1', 'DAC2', 'DAC3');
      xlabel('time [ns]')
      ylabel('ADC counts')
      title('DAC16HL - PB2')
    end

    
    % function [f, a] = measure_amp_spectrum(obj)
    %   N = 2048;
    %   F = 109; %MHz
    % 
    %   f = [1:N].*(F/N);
    %   a = zeros(1, N);
    %   figure(1)
    %   clf
    %   for i=1:N
    %     obj.ctrl.y_dac_wave_freq_2.put(single(f(i)));
    %     pause(0.5);
    %     outm = single(obj.mon(3).kick_adc_wav.get());
    %     a(i) = 20*log10(mean(abs(outm)));
    %     if i<N
    %       a(i+1:end) = a(i);
    %     end
    %     plot(f,a)
    %     grid on
    %   end
    %   obj.ctrl.y_dac_wave_freq_2.put(single(4.6));
    % 
    % end
    %
    %function [res] = doublet_optimization_in_time1(obj)
    %  N=48;
    %  MO = 0;
    %  
    %  if MO
    %    % clear the pattern table 
    %    ind = zeros(1, N);
    %    obj.ctrl.y_kick2_p_pattern.put(int32(ind));
    %    pause(2);
    %    obj.ctrl.y_dac_pattern_apply.put(int32(1));
    %    pause(2);
    %    % noise measurement
    %    nspan=0;
    %    offst=zeros(1,10);
    %    for i=1:10
    %      w = single(obj.mon(3).kick_adc_wav.get());
    %      offst(i) = mean(w);
    %      pause(0.2);
    %    end
    %    offst = mean(offst)
    %  else
    %    offst = -60;
    %  end 
    %  
    %  % generate intial patterns
    %  outd = [zeros(1,2) -0.5.*ones(1,8) 0.5.*ones(1,16) -0.5.*ones(1,8) zeros(1,14)];
    %  ind = [zeros(1,2) linspace(-0.523,-0.772,8) linspace(0.285,0.735,16) linspace(-0.27,-0.47,8) zeros(1,14)];
    %  ind(3:34) = ind(3:34);
    %  %clf; plot(ind); return
    %  %outd = [zeros(1,5) -sin(2*pi.*[1:40]./40) zeros(1,3)];
    %  outd = outd.*16384;
    %  %ind = outd;
    %  ind = ind.*16384;
    %  obj.ctrl.y_kick2_p_pattern.put(int32(ind));
    %  pause(2);
    %  obj.ctrl.y_dac_pattern_apply.put(int32(1));
    %  pause(3);
    %  w = single(obj.mon(3).kick_adc_wav.get());
    %  w = w(1:N);
    %  w = w';
    %  err = outd-w;
    %  toprms = rms(err(12:26))
    %  while toprms>30
    %    figure(1)
    %    clf
    %    subplot(2,1,1)
    %    plot(outd, 'b')
    %    hold on
    %    grid on
    %    plot(ind, 'g')
    %    plot(w, 'r')
    %    legend('Desired output', 'Desired input', 'Measured output')
    %    subplot(2,1,2)
    %    plot(err)
    %    hold on
    %    grid on
    %    
    %    indp = ind;
    %    ind = ind + 0.9.*err;
    %    ind(3) = indp(3);
    %    ind(11) = indp(11);
    %    ind(27) = indp(27);
    %    ind(35) = indp(35);
    %    ind(46:48)=0;
    %    obj.ctrl.y_kick1_p_pattern.put(int32(ind));
    %    obj.ctrl.y_kick1_n_pattern.put(int32(ind));
    %    obj.ctrl.y_kick2_p_pattern.put(int32(ind));
    %    obj.ctrl.y_kick2_n_pattern.put(int32(ind));
    %    pause(2);
    %    obj.ctrl.y_dac_pattern_apply.put(int32(1));
    %    pause(3);
    %    w = single(obj.mon(3).kick_adc_wav.get());
    %    w = w-offst;
    %    w = w(1:N);
    %    w = w';
    %    err = outd-w;        
    %    toprms = rms(err(12:26))
    %    tailrms = rms(err(36:48))
    %  end
    %        
    %  save('dac_pattern.mat', 'ind');
    %  
    %end
    %
    %function [res] = doublet_optimization_in_time(obj)
    %
    %  N=48;
    %
    %  %outd = [zeros(1,4) -0.5.*ones(1,10) 0.5.*ones(1,20) -0.5.*ones(1,10) zeros(1,4)];
    %  
    %  outd = [zeros(1,4) -sin(2*pi.*[1:40]./40) zeros(1,4)];
    %  %figure(1)
    %  %clf
    %  %plot(outd, '-x')
    %  %return
    %  
    %  outd = outd.*16384;
    %  % clear the pattern table 
    %  ind = zeros(1, N);
    %  ind(5) = 20000;
    %  obj.ctrl.y_kick2_p_pattern.put(int32(ind));
    %  pause(2);
    %  obj.ctrl.y_dac_pattern_apply.put(int32(1));
    %  pause(2);
    %  return
    %  % noise measurement
    %  nspan=0;
    %  offst=zeros(1,10);
    %  for i=1:10
    %    w = single(obj.mon(3).kick_adc_wav.get());
    %    pp = max(w) - min(w);
    %    if pp > nspan
    %      nspan = pp;
    %    end
    %    offst(i) = mean(w);
    %    pause(0.2);
    %  end
    %  offst = mean(offst)
    %  pp = 3*pp
    %
    %  % Pulse optimization
    %  i=1;
    %  while i<(N+1)
    %    w = single(obj.mon(3).kick_adc_wav.get());
    %    w = w-offst;  
    %    if (w(i)<(outd(i)+pp)) && (w(i)>(outd(i)-pp))
    %      i = i + 1;
    %      fprintf('i=%d\n', i);
    %    else
    %      ind(i) = ind(i) + 0.2*(outd(i)-w(i));   
    %      obj.ctrl.y_kick2_p_pattern.put(int32(ind));
    %      pause(2);
    %      obj.ctrl.y_dac_pattern_apply.put(int32(1));
    %      pause(2);
    %    end
    %    figure(1)
    %    clf
    %    plot(outd, 'b')
    %    hold on
    %    grid on
    %    plot(ind, 'g')
    %    plot(w(1:N), 'r')
    %    legend('Desired output', 'Desired input', 'Measured output')
    %    %pause
    %  end
    %  
    %  
    %end
    %
    function [res, v] = doublet_add(obj, v, del, amp)
      
      res = 0;
      dbl_p = [1 -1];
      dbl_n = [-1 1];
      
      v(del:del+1) = v(del:del+1) + amp.*dbl_p;
          
    end
    
    function [res, ind] = upload_dac_pattern(obj, v)
      res = 0;
    
      if nargin == 2
        ind = v;
      else
      
        PT = 2;
        %ind = [0 0 0 0 ...
        %       -5287 -8035 -10783 -13531 -16279 -19027 -21775 -24523 -27271 0 ...
        %       9887 11061 10735 10709 11783 13157 16631 14405 17879 16253 20227 18401 22775 20649 26023 22897 29271 25145 32719 27393 ...
        %       -5287 -8035 -10783 -13531 -16279 -19027 -21775 -24523 -27271 -30019 ...
        %       0 0 0 0 ...
        %       ];
              
        ind = zeros(1,48);
              
        % pulse
        %ind(24) = 30000;

        
        if PT == 1% bi-polar pulse composition
          [res, ind] = doublet_add(obj, ind,  3, -1);
          [res, ind] = doublet_add(obj, ind,  4, -2);
          [res, ind] = doublet_add(obj, ind,  5, -3);
          [res, ind] = doublet_add(obj, ind,  6, -1);
          [res, ind] = doublet_add(obj, ind,  7,  1.3);
          [res, ind] = doublet_add(obj, ind,  8,  3.6);
          [res, ind] = doublet_add(obj, ind,  9,  6.0);
          [res, ind] = doublet_add(obj, ind, 10,  8.5);
          [res, ind] = doublet_add(obj, ind, 11,  11.2);
          [res, ind] = doublet_add(obj, ind, 12,  10.2);
          [res, ind] = doublet_add(obj, ind, 13,  9.2);
          [res, ind] = doublet_add(obj, ind, 14,  8.2);
          [res, ind] = doublet_add(obj, ind, 15,  7.2);
          [res, ind] = doublet_add(obj, ind, 16,  6.2);
          [res, ind] = doublet_add(obj, ind, 17,  5.2);
          [res, ind] = doublet_add(obj, ind, 18,  4.2);
          [res, ind] = doublet_add(obj, ind, 19,  3.2);
          [res, ind] = doublet_add(obj, ind, 20,  2.2);
          [res, ind] = doublet_add(obj, ind, 21,  1.2);
          [res, ind] = doublet_add(obj, ind, 22,  0.2);
        end
        if PT == 2% bi-polar pulse composition
          ind( 2:4 ) = linspace(-1, -1.3, 3);
          %ind( 5:10) = linspace( 2,  2, 6);
          ind( 5:10) = [2, 2.3, 2.3, 2.4, 2.5, 2.7];
          %ind(11:21) = linspace(-1, -0.9, 11);
          ind(11:14) = linspace(-2.3, -2.3, 4);
          ind(15:20) = linspace(-0.2, -0.2, 6);
        end
      end
      
      % step
      %ind = 30000.*ones(1,48);
             
      % normalize to 32767
      inds = ind.*32767;
      obj.ctrl.y_kick1_p_pattern.put(int32(inds));
      obj.ctrl.y_kick1_n_pattern.put(int32(inds));
      obj.ctrl.y_kick2_p_pattern.put(int32(inds));
      obj.ctrl.y_kick2_n_pattern.put(int32(inds));
      
    end
    %
    %function [res] = find_optimal_doublet(obj, f, s)
    %
    %  N=2048; 
    %  Fs=216.6666666; % MHz
    %  t=[1:N]./Fs;
    %
    %  % calculate desired output
    %  outd = [zeros(1,4) -0.25 -0.5.*ones(1,8) -0.25 0 0.25 0.5.*ones(1,16) 0.25 0 -0.25 -0.5.*ones(1,8) -0.25 zeros(1,4)];
    %  outd = [repmat(outd, 1, 42) zeros(1, 32)];
    %  outdfftc = fft(outd);
    %  outdfft = 20*log10(abs(outdfftc)); 
    %  
    %  % calculate spectrum of the desired input
    %  sfft = 10.^((s-80)./20);
    %  indfftc = ifftshift(outdfftc).*ifftshift(sfft);
    %  indfft = 20*log10(abs(indfftc));
    %  indt = ifft(ifftshift(indfftc));
    %  %indt = indt-mean(indt);
    %  %indt = indt.*4;
    %  
    %  inm = single(obj.ctrl.y_kick2_p_pattern.get());
    %  % replicated pattern up to 2048 samples
    %  %inm = [repmat(inm, 42, 1);inm(1:32)];
    %  inm = [repmat(inm, 42, 1); zeros(32,1)];
    %  % normalize to 1
    %  inm = inm./max(abs(inm));
    %  inmfftc   = fft(inm'); 
    %  inmfft   = 20*log10(abs(inmfftc)); 
    %
    %  outmfftc = inmfftc./sfft;
    %  outmfft   = 20*log10(abs(outmfftc)); 
    %  outmt     = ifft((outmfftc)); 
    %  
    %  figure(1);
    %  clf
    %  %
    %  rng=1:1150;
    %  subplot(2,1,1)
    %  plot(t(rng), outd(rng), 'b')
    %  grid on
    %  hold on
    %  %plot(t(rng), indt(rng), 'r')
    %  plot(t(rng), inm(rng), 'g')
    %  plot(t(rng), outmt(rng), 'r')
    %  
    %  %
    %  subplot(2,1,2)
    %  plot(f, s-40, 'b')
    %  hold on
    %  grid on
    %  %plot(f, outdfft, 'r')
    %  plot(f, inmfft, 'g')
    %  plot(f, outmfft-6,  'r')
    %  %plot(f, indfft,  'g')
    %  %
    %  %figure(2)
    %  %clf
    %  
    %end
    %
    %function [res, outm, ind] = doublet_optimization(obj)
    %  res=0;
    %  N=2048; 
    %  M=48;
    %  Fs=216.6666666; % MHz
    %  t=[1:N]./Fs;
    %  f=Fs.*[1:N]./N;
    %  %outmn = zeros(16, 2048);
    %  %outmfftcn = zeros(16, 2048);
    %  %for i=1:16
    %  %  %outmn(i,:) = single(obj.mon(3).kick_adc_wav.get());
    %  %  outm = single(obj.mon(3).kick_adc_wav.get());
    %  %  outm = outm./max(abs(outm));
    %  %  %outmn(i,:) = outmn(i,:)./max(abs(outmn(i,:)));
    %  %  outmfftcn(i,:) = fft(outm);
    %  %  pause(0.1);
    %  %end
    %  outm = single(obj.mon(3).kick_adc_wav.get());
    %  %outm(2017:2048) = 0;
    %  outm = outm./max(abs(outm));
    %  outmfftc = fft(outm);
    %  %outm = outm./max(abs(outm));
    %  %outmfftc = mean(outmfftcn)';
    %  %outm = mean(outmn)';
    %  %outm = single(obj.mon(3).kick_adc_wav.get());
    %  %figure(1); clf; plot(outm); hold on; plot(mean(outmn)', 'r'); return;
    %  %figure(1); clf; plot(outm); return;
    %  inm = single(obj.ctrl.y_kick2_p_pattern.get());
    %  % replicated pattern up to 2048 samples
    %  %inm = [repmat(inm, 42, 1);inm(1:32)];
    %  inm = [repmat(inm, 42, 1); zeros(32,1)];
    %  % normalize to 1
    %  inm = inm./max(abs(inm));
    %  %inm = inm.*hamming(N);
    %  % remove DC
    %  %outm = outm-mean(outm);
    %  %inm = inm-mean(inm);
    %  % scale them to the same amplitude
    %  %scl = max(outm(1:48))/max(inm(1:48));
    %  %inm = inm.*scl;
    %  
    %  inmfftc   = fft(inm); 
    %  %outmfftc  = fft(outm);
    %  
    %  inmfft   = 20*log10(abs(inmfftc)); 
    %  outmfft  = 20*log10(abs(outmfftc));
    %  outmfftp = angle(outmfftc);
    %  
    %  %inmfft(1) = outmfft(1);    % do not care about the DC amplitude
    %  %ht = outmfft-inmfft;
    %  htfftc = outmfftc./inmfftc;
    %  htfft  = 20*log10(abs(htfftc));
    %  
    %  %%%%
    %  figure(1)
    %  clf
    %  
    %  % desired shape
    %  outd = [zeros(1,4) -0.25 -0.5.*ones(1,8) -0.25 0 0.25 0.5.*ones(1,16) 0.25 0 -0.25 -0.5.*ones(1,8) -0.25 zeros(1,4)];
    %  % replicate the shape up to 2048 samples
    %  %outd = [repmat(outd, 1, 42) outd(1:32)];
    %  outd = [repmat(outd, 1, 42) zeros(1, 32)];
    %  %hw = hamming(N);
    %  %outd = outd.*hw';
    %  outdfftc = fft(outd);
    %  outdfft = 20*log10(abs(outdfftc)); 
    %  
    %  outd = ifft(inmfftc.*outmfftc);
    %  
    %  indfftc = outdfftc./htfftc';
    %  indfft  = 20*log10(abs(indfftc)); 
    %  %ind = ifft(indfftc);
    %  ind = filter([.5 .5], [1], ifft(indfftc));
    %  %ind = ifft(indfftc);
    %  indm = mean(reshape(ind((M*1+1):(M*32)), 48, 31)');
    %  indm = ind(1009:1056);
    %  %indm(1:4) = 0;
    %  %indm(45:48) = 0;
    %  %indm(4:43) = indm(4:43) - mean(indm(4:43));
    %  % scale pattern to 1 and then to 16-bit resolution
    %  indm = indm./max(abs(indm));
    %  indm = indm.*(2^15-1);
    %  %plot(int32(indm));
    %  %return;
    %  %obj.ctrl.y_kick2_p_pattern.put(int32(indm));
    %  
    %  %
    %  figure(1)
    %  rng=1:2048;
    %  subplot(3,1,1)
    %  plot(t(rng), inm(rng), 'r')
    %  hold on
    %  grid on
    %  plot(t(rng), outm(rng), 'b')
    %  plot(t(rng), outd(rng), 'g')
    %  %plot(t(rng), ind(rng), 'k')
    %  xlabel('Time [us]')
    %  ylabel('Norm(1)')
    %  legend('Actual DAC output', 'Actual Kicker output', 'Desired kicker output', 'Desired DAC output')
    %  title('Time domain waveforms')
    %  %
    %  subplot(3,1,2)
    %  plot(f(1:end/2), inmfft(1:end/2), 'r')
    %  grid on
    %  hold on
    %  plot(f(1:end/2), outmfft(1:end/2), 'b')
    %  %plot(f(1:end/2), outdfft(1:end/2), 'g')
    %  %plot(f(1:end/2), indfft(1:end/2), 'k')
    %  xlabel('Frequency [MHz]')
    %  ylabel('Magnitude [dB]')
    %  legend('Actual DAC output', 'Actual Kicker output', 'Desired kicker output', 'Desired DAC output')
    %  title('Spectrum')
    %  %
    %  subplot(3,1,3)
    %  plot(f(1:end/2), outmfftp(1:end/2), 'r')
    %  grid on
    %  title('System transfer spectrum')
    %  xlabel('Frequency [MHz]')
    %  ylabel('Magnitude [dB]')
    %  %
    %  figure(2)
    %  clf
    %  plot(indm)
    %  hold on;
    %  grid on
    %  
    %end 
    
    %save('doublet_calib.mat', 'ptrn1', 'ch2');
    
  end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  methods (Access = private)

    function [res] = test_record_set(obj, name, dtype, value)
      import ch.psi.jcae.*;
      res = 0;
      
      rec = Channels.create(obj.context, ChannelDescriptor(dtype , name));
      switch dtype
        case 'integer'
          rec.put(uint32(value));
        case 'float'
          rec.put(value);
        case 'double'
          rec.put(value);
        case 'string'
          rec.put(value);
      end
      rec.close();
        
    end

    function [res] = test_record_print(obj, name, dtype, fd)
      import ch.psi.jcae.*;
      res = 0;
      
      rec = Channels.create(obj.context, ChannelDescriptor(dtype , name));
      val = rec.get();
      fprintf(fd, '%s\n', name);
      if strcmp(dtype,'string')
        fprintf(fd, '  %s ', val);
      else
        fprintf(fd, '%d ', val);
      end
      fprintf(fd, '\n');
      %rec.close();
    end
  
    function [res] = test_record_value(obj, name, dtype, min, max, prec, fd)
      import ch.psi.jcae.*;
      res = 0;
      
      rec = Channels.create(obj.context, ChannelDescriptor(dtype , name));
      val = rec.get();
      fprintf(fd, '%s\n', name);
      fprintf(fd, ['  ' format_string(obj, dtype, prec) format_string(obj, dtype, prec) format_string(obj, dtype, prec)], val, min, max);
      if (val > max) || (val < min)        
        fprintf(2, '%s\n', name);
        fprintf(2, ['  ' format_string(obj, dtype, prec) format_string(obj, dtype, prec) format_string(obj, dtype, prec)], val, min, max);
        fprintf(2, ' - ERROR -------------------------------------------------\n');
        res = 1;
      else 
        fprintf(fd, '\n');
      end
      rec.close();
    end

    function generate_general_report_header(obj, fd)
      fprintf(fd, '#----------------------------------------                                      \n');
      fprintf(fd, '# The IBFB hardware is tested in cabinet WLHA.A08.0.03                         \n');
      fprintf(fd, '#----------------------------------------                                      \n');
      fprintf(fd, '# The IBFB hardware was tested in a 21-slot VME create with 3 GPAC boards:     \n');
      fprintf(fd, '# controller, switch and monitor.                                              \n');
      fprintf(fd, '# Trigger and clock was taken from the E-XFEL timing system running in uTCA    \n');
      fprintf(fd, '#----------------------------------------                                      \n');
      fprintf(fd, '# Interpretation of the report file:                                           \n');
      fprintf(fd, '# Comment lines start with #                                                   \n');
      fprintf(fd, '# All data have a unique variable name followed by the data on the next line   \n');
      fprintf(fd, '# <VariableName>                                                               \n');
      fprintf(fd, '# <space><measured value>;<optional lower and upper limit)>;<optional units>   \n');
      fprintf(fd, '#----------------------------------------                                      \n');
      fprintf(fd, '#                                                                              \n');
      fprintf(fd, 'File-Format-Version                    \n');
      fprintf(fd, '1                                      \n');
      fprintf(fd, 'Test-Description                       \n');
      fprintf(fd, 'IBFB hardware generic test             \n');
      fprintf(fd, 'Data-Institute                         \n');
      fprintf(fd, 'PSI                                    \n');
      fprintf(fd, 'Data-Tester                            \n');
      fprintf(fd, 'Waldemar Koprek                        \n');
      fprintf(fd, 'Test-Date                              \n');
      fprintf(fd, '%s                   \n', date);
    end

    
    function test_generate_amplifier_report_header(obj, fd, pair)
      fprintf(fd, '#----------------------------------------                                      \n');
      fprintf(fd, '# The IBFB hardware is tested in cabinet WLHA.A08.0.03                         \n');
      fprintf(fd, '#----------------------------------------                                      \n');
      fprintf(fd, '# The IBFB hardware was tested with two aplifiers switched sequentially to     \n');
      fprintf(fd, '# different output/input pairs                                                 \n');
      fprintf(fd, '# Trigger and clock was taken from the E-XFEL timing system running in uTCA    \n');
      fprintf(fd, '#----------------------------------------                                      \n');
      fprintf(fd, '# Interpretation of the report file:                                           \n');
      fprintf(fd, '# Comment lines start with #                                                   \n');
      fprintf(fd, '# All data have a unique variable name followed by the data on the next line   \n');
      fprintf(fd, '# <VariableName>                                                               \n');
      fprintf(fd, '# <space><measured value>;<optional lower and upper limit)>;<optional units>   \n');
      fprintf(fd, '#----------------------------------------                                      \n');
      fprintf(fd, '#                                                                              \n');
      fprintf(fd, 'File-Format-Version                    \n');
      fprintf(fd, '1                                      \n');
      fprintf(fd, 'Test-Description                       \n');
      fprintf(fd, 'IBFB hardware generic test             \n');
      fprintf(fd, 'Data-Institute                         \n');
      fprintf(fd, 'PSI                                    \n');
      fprintf(fd, 'Data-Tester                            \n');
      fprintf(fd, 'Waldemar Koprek                        \n');
      fprintf(fd, 'Test-Date                              \n');
      fprintf(fd, '%s                   \n', date);
      fprintf(fd, 'Tested-Pair                            \n');
      fprintf(fd, '%s                   \n', pair);
    end
  
       
    function [format_str] = format_string(obj, dtype, prec)
      switch dtype
        case 'integer'
          format_str = ['%' num2str(prec) 'd; '];
        case 'float'
          format_str = ['%.' num2str(prec) 'f; '];
        case 'double'
          format_str = ['%.' num2str(prec) 'f; '];
        case 'string'
          format_str = ['%s; '];
      end
    end
       
    function [sf, f, Afloor, Amax, fmax, N] = fftFS(obj, st, fs)

      % fftFS - calculates FFT in full scale
      %
      % f = fftFS(st, fs, pl)
      %     st - input data in time domain normalized to 1
      %     fs - sampling frequency in [Hz]
      %     sf - output spectrum, 0dB is full scale

      fs = fs/1.0e6;
      %remove DC
      %s = s - mean(s);

      N = length(st);

      %h = blackman(N);
      %h = hanning(N);
      h = window(@chebwin, N);
      sh = st.*h;
      %sh = st;
      %fft
      %sf = 20*log10(abs(fft(sh))) - 20*log10(N/2); 
      sf = 20*log10(abs(fft(sh))) - 20*log10(N/2) + 7; %correction for Blackman window

      %sf = sf + 20*log10(fs/N);

      %find the fundamental frequency
      Amax = max(sf);
      fmax = fs*find(sf==Amax,1)/N - fs/N;

      %SNR calculation
      %sfl=abs(fft(sh-mean(sh)))./(N/2);
      %sfl(find(sfl>0.1)) = 0;
      %semilogy(sfl) 
      %std(ifft(sfl).*(N/2))
      %plot(ifft(sfl).*(N/2))
      %snr = 20*log10(1/sum(sfl(1:N/2)))


      %noise floor calucation 
      sfl = sf;
      Afloor = mean(sfl);
      sfl(find(sfl>Afloor+20)) = Afloor;
      Afloor = mean(sfl);

      t = [1:N]/fs;
      f = [0:fs/N:fs-fs/N];
    
    end
    
    function table = play_calculate_timestamp(obj)
      table = int32(obj.BUCKET_SPACE*0:obj.BUCKET_NUMBER);
    end
    
    function table = play_calculate_control(obj, packets, bpm)
      a = bpm*2^16+[0:obj.BUCKET_NUMBER];
      a(packets+1:end) = obj.PLAYER_EOP;
      table = int32(a);
    end



    function table = play_calculate_pos(obj, pos)
      table = single(normrnd(0, 0.02, [1 2700]) + pos);
    end
    
    function res = lattice_find_components_in_xfel_list(obj)

      res = 0;
      %constants


      % try to open the file
      try
      %  [r1, r2, r3] = xlsread(obj.LATTICE_FILE_NAME , 'LONGLIST', '','basic');
        [r1, r2, r3] = xlsread(obj.LATTICE_FILE_NAME, 'Sheet1' );
      catch
        fprintf('error reading file %s\n', obj.LATTICE_FILE_NAME )
        res = -1;
        return
      end
      fprintf('\n');
      % find IBFB components in XFEL list of components
      % fprintf('Finding IBFB component in XFEL list...')
      objid=0;
      for i=1:size(obj.xls.filters,2)
        idxs = lattice_find_component_index(obj, r3, obj.xls.filters(i));
        if isempty(idxs)
          fprintf(2, '\nERROR: Nothing found in Section: %s, group: %s, type: %s', obj.xls.filters(i).section, obj.xls.filters(i).group, obj.xls.filters(i).type);
          res = -2;
          return
        else
          fprintf('    section: %s, group: %s, type: %s - found %d elements\n', obj.xls.filters(i).section, obj.xls.filters(i).group, obj.xls.filters(i).type, length(idxs));
        %  %fprintf('index %d', obj.bpms(i).idx)
          for j=1:length(idxs)
            objid = objid + 1;
            obj.bpms(objid).name    = r3{idxs(j), obj.XLS_NAME1};
            obj.bpms(objid).name2   = r3{idxs(j), obj.XLS_NAME2};
            obj.bpms(objid).x       = r3{idxs(j), obj.XLS_X};
            obj.bpms(objid).y       = r3{idxs(j), obj.XLS_Y};
            obj.bpms(objid).z       = r3{idxs(j), obj.XLS_Z};
            obj.bpms(objid).alfx    = r3{idxs(j), obj.XLS_ALFX};
            obj.bpms(objid).betx    = r3{idxs(j), obj.XLS_BETX};
            obj.bpms(objid).mux     = r3{idxs(j), obj.XLS_MUX};
            obj.bpms(objid).alfy    = r3{idxs(j), obj.XLS_ALFY};
            obj.bpms(objid).bety    = r3{idxs(j), obj.XLS_BETY};
            obj.bpms(objid).muy     = r3{idxs(j), obj.XLS_MUY};
            obj.bpms(objid).section = obj.xls.filters(i).section;
            obj.bpms(objid).group   = obj.xls.filters(i).group;
            obj.bpms(objid).type    = obj.xls.filters(i).type;
            obj.bpms(objid).plane = 'B';
            % select the plane by checking the NAME2 attribute
            if ~isempty(findstr(obj.bpms(objid).name2, 'X'))
              obj.bpms(objid).plane = 'X';
            end;
            if ~isempty(findstr(obj.bpms(objid).name2, 'Y'))
              obj.bpms(objid).plane = 'Y';
            end;
            % collimator BPMs used only for Y plane
            if strcmp(obj.bpms(objid).section, 'CL')
              obj.bpms(objid).plane = 'Y';
            end;
            % for the undulator BPMs select the plane by the beta value
            % the BPM belogs to the plane for which it has bigger beta value
            if strcmp(obj.bpms(objid).type, 'BPME')
              if (obj.bpms(objid-1).bety > obj.bpms(objid).bety)
                obj.bpms(objid).plane = 'X';
              else
                obj.bpms(objid).plane = 'Y';
              end;
            end;
            % assign BPM IDs 
            %if strcmp(obj.bpms(objid).section, 'CL')
            %  obj.bpms(objid).bpmid = obj.BPM_ID_CL + j - 1;
            %end;
            %if strcmp(obj.bpms(objid).section, 'TL')
            %  if strcmp(obj.bpms(objid).type, 'BPMI')
            %    obj.bpms(objid).bpmid = obj.BPM_ID_TL + j - 1;
            %  end;
            %  if strcmp(obj.bpms(objid).type, 'KFBX')
            %    obj.bpms(objid).bpmid = obj.KICK_ID_KFBX + j - 1;
            %  end;
            %  if strcmp(obj.bpms(objid).type, 'KFBY')
            %    obj.bpms(objid).bpmid = obj.KICK_ID_KFBY + j - 1;
            %  end;
            %end;
            %if strcmp(obj.bpms(objid).section, 'SA1')
            %  obj.bpms(objid).bpmid = obj.BPM_ID_SA1 + j - 1;
            %end;
            %if strcmp(obj.bpms(objid).section, 'SA2')
            %  obj.bpms(objid).bpmid = obj.BPM_ID_SA2 + j - 1;
            %end;
            %if strcmp(obj.bpms(objid).section, 'SA3')
            %  obj.bpms(objid).bpmid = obj.BPM_ID_SA3 + j - 1;
            %end;
          end
        end
      end
      %fprintf('\n  Components not found removed from the list of IBFB components\n')
      %obj.bpms = ibfb.components([ibfb.components.idx] > 0);
      %fprintf('\ndone\n')     
    end
    
    function [idx] = lattice_find_component_index(obj, xfelcomps, filter)

      idx=[];        
      for i=3:size(xfelcomps,1)
          %fprintf('%s\n', xfelcomps{i, obj.XLS_GROUP})
          if strcmp(xfelcomps{i, obj.XLS_SECTION}, filter.section) & strcmp(xfelcomps{i, obj.XLS_GROUP}, filter.group) & strcmp(xfelcomps{i, obj.XLS_TYPE}, filter.type)
              idx = [idx i];
          end        
      end
      
    end
          
    function gamma = lattice_calc_gamma(obj, alfa, beta)
      gamma = (1 + alfa^2)/beta;        % K. Wille, "Physik und Beschleuniger" s. 92
    end
      
  end
   
end