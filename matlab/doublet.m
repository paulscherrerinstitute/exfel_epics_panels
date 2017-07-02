clear all

N = 48;
t = 0:N-1;
a = 2*exp(-.3.*t);
b = zeros(1, N);
b(20:30) = 1;
bc = conv(a,b);
size(b)
size(bc)

figure(1)
clf
subplot(2,1,1)
plot(t,a)
hold on
grid on
plot(t, b, 'r')
subplot(2,1,2)
plot( bc, 'g')