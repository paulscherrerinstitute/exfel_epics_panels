clear all

B=50;               % number of buckets
BS=1;                 % bunch spacing
%BPM_SMP_DEL=10;       % bpm valid delay with respect to bucket trigger

FB_DEL=9;             % feedback delay in buckets
t=1:B;            % time domain vector
Kp=0.9;               % P gain
Ki=1/11;             % I gain
FB_ON=1;              % enable feedback
I_APPLY=FB_DEL;
I_SHIFT=1;

% combination of integrator apply counter, integrator gain versus bunch
% spacing
% FB_DEL = 9;
%
% BS       Ki      I_APPLY
%  1       1/11      FB_DEL
%  2       1/6       FB_DEL
%  3       1/4       FB_DEL+1
%  4       1/3       FB_DEL
%  5       1/3       FB_DEL
%  6       1/2       FB_DEL
%  7       1/2       FB_DEL+1
%  8       1/2       FB_DEL+4
%  9       1/2       FB_DEL+7
% 10       1/2       FB_DEL+7
% 11       1/1       FB_DEL

% calculation vectors
bpm = zeros(2, B);  % 1 - position, 3 - bunch trigger
bpm(1,:) = linspace(0.6, 0.5, B) + 0.01.*(rand(1,B)-0.5);
bpm(1,1:FB_DEL-1) = 0;
bpm(2,FB_DEL:BS:end) = 1;

%kpv = zeros(1, B); % Kp gain vector
kpv = linspace(1,0.7,B);

err = zeros(2, B);  % 1 - error value, 2 - error valid
acc = zeros(2, B);  % 1 - acc value, 2 - acc valid
p = zeros(3, B);    % 1 - values, 2 - counter, 3 - trigger
it = zeros(1, B);   % 1 - values, 2 - counter, 3 - trigger
pi = zeros(2, B);   % 1 - values, 2 - counter, 3 - trigger

sp = 1*ones(1, B);
fb_cnt = 0;
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
    if bpm(2,b)
      acc(1, b) = acc(1, b-1) + Ki*err(1,b);
    else
      if b>1
        acc(1, b) = acc(1, b-1);
      end
    end 
    % feedback gate
    %if bpm(2,b)
    if b>FB_DEL
      pi(1, b) = Kp*(err(1,b)+in);   % constant Kp
      %pi(1, b) = kpv(b)*(err(1,b)+in);    % variable Kp
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
%plot(t, pi(2,:)/10, 'b')
grid on
legend('bpm', 'bunch','SP', 'Error', 'I', 'PI')
xlabel('Bucket number [222ns]')
ylabel('Position [mm]')
title(['Bunch spacing: ' num2str(BS) ', FB\_DEL=' num2str(FB_DEL) ...
  ', Kp=' num2str(Kp) ', Ki=' num2str(Ki) ', Icnt=' num2str(I_APPLY) ...
  ', Ishift=' num2str(I_SHIFT)]);