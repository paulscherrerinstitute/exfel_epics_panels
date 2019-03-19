
load amp_pulse_response.mat
N = 48;
t = 0:N-1;

%a = 2*exp(-.3.*t);
%remove dc
amp_m_no_dc = amp_m - mean(amp_m(1:70));
%amp_r = amp_m_no_dc(70:70+N-1);
amp_r = amp_m_no_dc;
b = zeros(1, N);
%b(1:5) = linspace(-0.3, -0.6, 5);
%b(6:12) = linspace(0.5, 0.8, 7);
%b(13:17) = linspace(-0.7, -0.7, 5);
b(2) = 1;
b(3) = -1;
b(4) = 1;
b(5) = -1;
b(6) = 1;
b(7) = -1;

bc = conv(amp_r, b);

figure(1)
clf
subplot(2,1,1)
plot(amp_r)
hold on
grid on
plot(b, 'r')
subplot(2,1,2)
plot( bc, 'g')
grid on
