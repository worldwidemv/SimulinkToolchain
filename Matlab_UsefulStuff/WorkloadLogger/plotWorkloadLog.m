fileName = 'workload.log';

fileID = fopen(fileName);
if (fileID == -1)
    error([char(10), 'File ', fileName, ' was not found.']);
end
frewind(fileID);
dataStr = fread(fileID,'*char')';
dataStr = strrep(dataStr, ',', '.');
data = textscan(dataStr, '%d  %d  %f  %f  %s\n');
fclose(fileID);

time = data{1};
pid  = data{2};
cpu  = data{3};
ram  = data{4};
command = data{5};

clear('task');
clear('subtask');

validPID = unique(pid);
for i = [1:length(validPID)],
    temp = find(pid == validPID(i));
    
    subtask(i).time = time(temp) -time(temp(1));
    subtask(i).cpu  = cpu(temp);
    subtask(i).ram  = ram(temp);
    subtask(i).pid  = validPID(i);
    subtask(i).command = cell2mat(command(temp(1)));
end

commandsAll = {subtask(:).command};
tasksTemp = unique(commandsAll);
for i = [1:length(tasksTemp)],
    task(i).subtask = subtask(strcmp(commandsAll, tasksTemp(i)));
    task(i).command = tasksTemp(i);
    task(i).time    = task(i).subtask(1).time;
    task(i).cpu     = zeros(size(task(i).time));
    task(i).ram     = zeros(size(task(i).time));
    for j = [1:length(task(i).subtask)],
        if (length(task(i).time) == length(task(i).subtask(j).time))
            task(i).cpu     = sum([task(i).cpu, task(i).subtask(j).cpu], 2);
            task(i).ram     = sum([task(i).ram, task(i).subtask(j).ram], 2);
        end
    end
    
    f = figure(i);
    clf(f);
    hold on;
    plot(task(i).time, task(i).cpu);
    for j = [1:length(task(i).subtask)],
        plot(task(i).subtask(j).time, task(i).subtask(j).cpu);
    end
    title(strrep(task(i).command, '_', '\_'));
    xlabel('time [s]');
    ylabel('Processor Workload [%]');
    legend(['SUM', cellstr(strcat('P', num2str([1:length(task(i).subtask)]')))']);
    grid on;
    hold off;
end

