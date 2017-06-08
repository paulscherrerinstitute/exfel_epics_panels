clear all

B=50;
FB_DEL=4;
BPM_SMP_DEL=10;
ERR_CMP=6;
FB_K_CMP=7;
tb=48;
smp = tb*B ;
t=1:smp;
K=0.8;

bkt_trg = zeros(1, smp);
bkt_trg(1:tb:end) = 0.5;
bpm1 = zeros(2, smp);
bpm1(1,FB_DEL*tb+BPM_SMP_DEL:tb:end) = 0.1;% + 0.01.*rand(1,B-FB_DEL);
bpm1(2,FB_DEL*tb+BPM_SMP_DEL:tb:end) = 1;
sp = 0.3*ones(1, smp);
err = zeros(2, smp);
fb_k = zeros(2, smp);

for b=1:B   % for each bucket
  for s=1:tb   % for each sample in the bucket
    i =  (b-1)*tb + s;
    % bpm position - repeat the received sample 48 times
    if bpm1(2,i)
      ik = i+FB_DEL*tb;
      if ik<=smp
        bpm1(1,i+FB_DEL*tb) = bpm1(1,i+FB_DEL*tb) + fb_k(1,i);
      end
    else
      if i>1
        bpm1(1,i) = bpm1(1,i-1);
      end
    end
    % calculate error
    if bpm1(2,i)
      err(1, i+ERR_CMP) = sp(i) - bpm1(1,i);
      err(2, i+ERR_CMP) = 1;
    else
      err(1, i+ERR_CMP) = err(1, i+ERR_CMP-1);
    end
    % feedback k
    if bkt_trg(i) 
      fb_k(1, i+FB_K_CMP) = K*err(1,i);
      fb_k(2, i+FB_K_CMP) = 1;
    else
      fb_k(1, i+FB_K_CMP) = fb_k(1, i+FB_K_CMP-1);
    end
  end
end

% cut too much samples
err = err(:, 1:smp);
fb_k = fb_k(:, 1:smp);

% plots 
figure(1)
clf
plot(t, bkt_trg, 'g--') % plot trigger
hold on
plot(t, bpm1(1,:), 'k')
plot(t, sp, 'b') % plot sp
plot(t, err(1,:), 'r')
plot(t, fb_k(1,:), 'm')

legend('bucket trigger', 'bpm', 'SP', 'Error', 'FB K')