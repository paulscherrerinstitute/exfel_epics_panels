clear all

B=100;                 % number of bunches
BS=1;                 % bunch spacing
FB_DEL=9;             % feedback delay in buckets
BPM_SMP_DEL=10;       % bpm valid delay with respect to bucket trigger
ERR_CMP=6;            % error computation time
ACC_CMP=11;           % integrator computation time
PI_CMP=6;             % P+I computation time
tb=48;                % samples per bucket
smp = tb*B ;          % all simulation samples
t=0:smp-1;            % time domain vector
Kp=0.5;               % P gain
Ki=0.06;             % I gain
FB_ON=1;              % enable feedback

bkt_trg = zeros(1, smp);
bkt_trg(1:tb:end) = 0.5;
bpm = zeros(3, smp);  % 1 - position, 2 - bucket trigger, 3 - bunch trigger
bpm(1,:) = linspace(0.12, 0.12, smp);% + 0.01.*rand(1,B-FB_DEL);
bpm(1,1:FB_DEL*tb+BPM_SMP_DEL-1) = 0;% + 0.01.*rand(1,B-FB_DEL);
bpm(3,FB_DEL*tb+BPM_SMP_DEL:tb*BS:end) = 1;% + 0.01.*rand(1,B-FB_DEL);

err = zeros(2, smp); % 1 - error value, 2 - error valid
err(2,FB_DEL*tb+BPM_SMP_DEL+ERR_CMP:tb*BS:end) = 1;

acc = zeros(2, smp); % 1 - acc value, 2 - acc valid
acc(2,FB_DEL*tb+BPM_SMP_DEL+ERR_CMP+ACC_CMP:tb:end) = 1;

p = zeros(3, smp); % 1 - values, 2 - counter, 3 - trigger
%p = ones(1, smp); % 1 - values, 2 - counter, 3 - trigger
p(3,FB_DEL*tb+BPM_SMP_DEL+ERR_CMP+1:tb:end) = 1; 

it = zeros(1, smp); % 1 - values, 2 - counter, 3 - trigger

pi = zeros(2, smp); % 1 - values, 2 - counter, 3 - trigger
pi(2,FB_DEL*tb+BPM_SMP_DEL+ERR_CMP+PI_CMP:tb:end) = 1; 

sp = 0.3*ones(1, smp);
fb_k = zeros(2, smp);
fb_i = zeros(2, smp);

for b=1:B   % for each bucket
  for s=1:tb   % for each sample in the bucket
    i =  (b-1)*tb + s;
    % bpm position - repeat the received sample 48 samples * BS
    if bpm(3,i) % bpm valid
      if FB_ON
        if i-tb*(FB_DEL) > 0
          bpm(1,i:i+BS*tb-1) = bpm(1, i)+pi(1,i-tb*(FB_DEL));
        end
      else
        bpm(1,i:i+BS*tb-1) = bpm(1, i);
      end
    end 
    % calculate error
    if err(2,i)
      err(1, i:i+BS*tb-1) = sp(i) - bpm(1,i);
    end
    % calculate integrator
    if acc(2,i)
      acc(1, i:i+BS*tb-1) = acc(1, i-1) + Ki*err(1,i);
    end
    % feedback gate
    if p(3, i)
      p(1, i:i+tb-1) = err(1, i-1);
      if p(2, i-1) == 1
        p(2, i:i+tb-1) = FB_DEL-1;
      else
        p(2, i:i+tb-1) = p(2,i-1)-1;
      end
      if p(2, i-1) == 1
        it(1, (i+tb):i+tb*(FB_DEL+1)-1) = acc(1,i);
      end 
    end
    if pi(2, i)
        pi(1, i:i+tb*(FB_DEL-1)) = Kp*(p(1, i) + it(1, i));      
    end
    
    
    % feedback i
    if bkt_trg(i) 
    end 
    % feedback k
    if bkt_trg(i) 
    %  fb_k(1, i+FB_K_CMP) = Ki*err(1,i);
    %  fb_k(2, i+FB_K_CMP) = 1;
    else
    %  fb_k(1, i+FB_K_CMP) = fb_k(1, i+FB_K_CMP-1);
    end
  end
end

% cut too much samples
err = err(:, 1:smp);
fb_k = fb_k(:, 1:smp);

% plots 
figure(1)
clf
plot(t, bkt_trg, 'y--') % plot trigger
hold on
plot(t, bpm(1,1:smp), 'k')
plot(t, sp, 'b') % plot sp
plot(t, err(1,1:smp), 'r')
plot(t, acc(1,1:smp), 'm')
plot(t, p(1,1:smp), 'c')
plot(t, pi(1,1:smp), 'b')
%plot(t, p(2,1:smp)./100, 'k')

legend('bucket trigger', 'bpm', 'SP', 'Error', 'Integrator', 'Propotional', 'PI')
title(['Bunches: ' num2str(B) ', Space: ' num2str(BS) ', Ki=' num2str(Ki) ', Kp=' num2str(Kp)])