clear all

B=100;                 % number of bunches
BS=1;                 % bunch spacing
FB_DEL=9;             % feedback delay in buckets
%BPM_SMP_DEL=10;       % bpm valid delay with respect to bucket trigger
%ERR_CMP=6;            % error computation time
%ACC_CMP=11;           % integrator computation time
%PI_CMP=6;             % P+I computation time
%tb=48;                % samples per bucket
%smp = tb*B ;          % all simulation samples
t=1:B;            % time domain vector
Kp=1;               % P gain
Ki=1/11;             % I gain
FB_ON=1;              % enable feedback
I_APPLY=FB_DEL;
I_SHIFT=1;

%bkt_trg = zeros(1, smp);
%bkt_trg(1:tb:end) = 0.5;
bpm = zeros(2, B);  % 1 - position, 3 - bunch trigger
bpm(1,:) = linspace(0.5, 0.5, B);
bpm(1,1:FB_DEL-1) = 0;
bpm(2,FB_DEL:BS:end) = 1;

err = zeros(2, B); % 1 - error value, 2 - error valid
%err(2,FB_DEL*tb+BPM_SMP_DEL+ERR_CMP:tb*BS:end) = 1;

acc = zeros(2, B); % 1 - acc value, 2 - acc valid
%acc(2,FB_DEL*tb+BPM_SMP_DEL+ERR_CMP+ACC_CMP:tb:end) = 1;

p = zeros(3, B); % 1 - values, 2 - counter, 3 - trigger
%p = ones(1, smp); % 1 - values, 2 - counter, 3 - trigger
%p(3,FB_DEL*tb+BPM_SMP_DEL+ERR_CMP+1:tb:end) = 1; 

it = zeros(1, B); % 1 - values, 2 - counter, 3 - trigger

pi = zeros(2, B); % 1 - values, 2 - counter, 3 - trigger
%pi(2,FB_DEL*tb+BPM_SMP_DEL+ERR_CMP+PI_CMP:tb:end) = 1; 

sp = 1*ones(1, B);
%fb_k = zeros(2, B);
%fb_i = zeros(2, B);
fb_cnt = 0;
%start = 0;
in = 0;
for b=1:B   % for each bucket
    % bpm position - repeat the received sample 48 samples * BS
    if bpm(2, b) % bpm valid
      if FB_ON
        if b > (FB_DEL+1)
          bpm(1, b) = bpm(1, b) + pi(1, b-FB_DEL-1);
        end
      end
    else   % repeat previous bunch
      if b>1
        bpm(1, b) = bpm(1, b-1);
      end
    end 
    % calculate error
    if bpm(2, b)
      err(1, b) = sp(b) - bpm(1, b);
    else % repeate previous position error
      if b>1
        err(1, b) = err(1, b-1);
      end
    end    
    % calculate integrator
    %if bpm(2,b)
    if b>1
      acc(1, b) = acc(1, b-1) + Ki*err(1,b);
    end
    %end
    % feedback gate
    %if bpm(2,b)
    if b>FB_DEL
      pi(1, b) = Kp*(err(1,b)+in);
      pi(2,b) = fb_cnt;
      if fb_cnt == I_SHIFT
        in = acc(1,b);
      end
      if fb_cnt <= 1 % constant - the same like in hardware
        fb_cnt = I_APPLY;
      else
        fb_cnt = fb_cnt - 1;
      end
    end
end

% plots 
figure(1)
clf
%hold on
plot(t, bpm(1,:), 'k')
hold on
plot(t, bpm(2,:), 'y--') % plot trigger
plot(t, sp, 'b') % plot sp
plot(t, err(1,:), 'r')
plot(t, acc(1,:), 'm')
plot(t, pi(1,:), 'c')
plot(t, pi(2,:)/10, 'b')
grid on
legend('bpm', 'bunch','SP', 'Error', 'I', 'PI')
