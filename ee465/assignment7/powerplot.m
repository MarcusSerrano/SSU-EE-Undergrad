%% Project B - Power plot
readChannelID = 3185083;   % e.g. 123456
readAPIKey    = 'ITHFKJ1E49NRFOPQ';

% (If you want to write to another channel later, fill these in)
writeChannelID = 3185083;  % or a different one
writeAPIKey    = 'GJL6SFCBCT1HWWAE';

% Read last 100 points from fields 1 (Temp) and 2 (CPU%)
[data, timeStamps] = thingSpeakRead(readChannelID, ...
    'ReadKey', readAPIKey, ...
    'Fields', [1 2], ...
    'NumPoints', 100);

tempC      = data(:,1);   % Field 1 = temperature in °C
cpuPercent = data(:,2);   % Field 2 = CPU usage in %

% POWER_in_W formula from assignment
POWER_in_W = (0.23 * 100 * (cpuPercent/100) + tempC * 0.32);
% which is effectively: 0.23*cpuPercent + 0.32*tempC

plot(timeStamps, POWER_in_W, 'LineWidth', 2);
title('POWER\_in\_W vs Time');
ylabel('POWER\_in\_W');
datetick('x','HH:MM','keepticks');
grid on;
