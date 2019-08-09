# Copyright 2019 Cohesity Inc.
# Author : Christina Mudarth <christina.mudarth@cohesity.com>
# This script is run by Get-PBCohesityProtectionRunGraph.ps1
# creates a graph
import matplotlib
matplotlib.use('Agg')
import sys
import matplotlib.pyplot as plt; plt.rcdefaults()
import numpy as np

def graph(stat, hour, current, path):
    hour = hour.split(",")
    current_t = current.replace("AM", "")
    if current_t != current:
        current_t = int(current_t)
    else:
        current_t = current.replace("PM", "")
        current_t = int(current_t)
    stat = stat.split(",")
    hour = map(int, hour)
    N = 24
    success = [0] * N
    fail = [0] * N
    cancel = [0] * N
    running = [0] * N
    total_time = current_t
    time_line = [0] * N
    total_times = total_time
    timeline_past = [0] * N
    # list of times in past 23 hours
    for i in range(N):
        total_times = total_times - 1
        if (total_times < 0):
            timeline_past[i] = total_times + 1
        if (total_times == 0):
            timeline_past[i] = total_times + 1
        if (total_times > 0):
            timeline_past[i] = total_times + 1
    start_times = total_time
    # list of times in 24 hour format 
    for i in range(N):
        if (start_times < 0):
            temp = start_times + 24
            time_line[i] = temp
        if (start_times == 0):
            time_line[i] = 24
        if (start_times > 0):
            time_line[i] = start_times
        start_times = start_times - 1

    timeline_past.reverse()
    time_line.reverse()
    num = 0
    # number of failed, succesful, cancelled, and accepted runs
    for i in stat:
        if stat[num] == 'KFailure':
            fail[time_line.index(hour[num])] += 1
        if stat[num] == 'KSuccess':
            success[time_line.index(hour[num])] += 1
        if stat[num] == 'KCanceled':
            cancel[time_line.index(hour[num])] += 1
        if stat[num] == 'KAccepted':
            running[time_line.index(hour[num])] += 1
        num += 1
    # plot values
    plt.bar(timeline_past, success, color='g',
            align='center', label='success')
    plt.bar(timeline_past, fail, color='r', bottom=success,
            align='center', label='failed')
    plt.bar(timeline_past, cancel, color='#FF8D33', bottom=fail,
            align='center', label='canceled')
    plt.bar(timeline_past, running, color='#3358FF', bottom=cancel,
            align='center', label='running')
    plt.legend(loc='upper left')
    plt.ylabel('number of protection runs')
    combined = [x + y for x, y in zip(fail, success)]
    combined = [x + y for x, y in zip(combined, cancel)]
    combined = [x + y for x, y in zip(combined, running)]
    x_axis = []
    x_coor = []
    count = 0
    # plot x axis times
    for i in combined:
        if(i != 0):
            x = count
            time = int(time_line[x])
            x_coor.append(timeline_past[x])
            if (0 < time < 12):
                temp = str(time) + 'am'
            if (time > 12):
                time = time - 12
                temp = str(time) + 'pm'
            if (time == 12):
                temp = str(time) + 'pm'
            x_axis.append(temp)
        count = count + 1
    plt.xticks(x_coor, x_axis)
    plt.xticks(rotation=90)
    plt.title('Protection runs in the past day')
    plt.gcf().subplots_adjust(bottom=0.15)
    plt.xlabel('time')
    path_png = path + '/graph.png'
    plt.savefig(
        path_png)


if __name__ == "__main__":
    arg1 = sys.argv[1]
    arg2 = sys.argv[2]
    arg3 = sys.argv[3]
    arg4 = sys.argv[4]
    graph(arg1, arg2, arg3, arg4)
