
%高精度的ms,us级别延时
tic;
for t = 0.001:0.001:0.7
    while toc < t
    end
end

t=toc;
disp(['t:' num2str(t)]);

%time表示定时时间，单位为s。语句t=0.001:0.001：time中的步长表示计时的精度，此处为0.001ms。