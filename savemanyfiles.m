for i=1:1:10
    fd=fopen([num2str(i) 'EitData' datestr(now,'yyyy-mm-dd_HH_MM_SS') '.txt'],'w')
    pause(1)
end