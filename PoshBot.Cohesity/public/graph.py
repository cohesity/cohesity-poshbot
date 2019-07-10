import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt; plt.rcdefaults()
import numpy as np
import matplotlib.pyplot as plt
import sys



def graph(stat, hour, current):
        hour = hour.split(",")
        
        current_t = current.replace("AM","")
        if current_t != current:
                sett = "am"
                current_t = int(current_t)
        else:
                current_t = current.replace("PM","")
                sett = "pm"
                current_t = int(current_t)
                #current_t = current_t - 12
        stat = stat.split(",")
        hour  = map(int, hour)
        N = 24
        success = [0] * N
        fail = [0] * N
        total_time = current_t
        time_line = [0] * N
        time_tt = [0] * N
        for i in range(N):
            total_time =total_time -1
            #if sett == 'pm':
             #   total_time = total_time + 12
            if (total_time < 0):
                temp = total_time + 24
                time_line[i] = temp
                time_tt[i] = total_time
            if (total_time == 0):
                time_line[i] = 24
                time_tt[i] = total_time   
            if (total_time > 0):
                time_line[i] = total_time
                time_tt[i] = total_time
        time_tt.reverse()
        time_line.reverse()
        num = 0
        for i in stat:
                if stat[num] == 'KFailure':
                        fail[time_line.index(hour[num])] += 1
                if stat[num] == 'KSuccess':
                        success[time_line.index(hour[num])] += 1
                num += 1
        width = 0.5
        plt.bar(time_tt, success, color = 'b',align='center', alpha=0.5, label='success')
        plt.bar(time_tt, fail, color = 'r', bottom = success, align='center', alpha=0.5, label='failed')
        plt.legend(loc='upper left')
        plt.ylabel('number of protection runs')
        combined = [x + y for x, y in zip(fail, success)]
        x_axis = []
        x_coor = []
        count = 0
        for i in combined:
                if(i != 0):
                        x= count
                        time = int(time_line[x])
                        x_coor.append(time_tt[x])
                        if (0 < time < 12):
                                temp = str(time) + 'am'
                        if (time > 12):
                                time = time - 12
                                temp = str(time) + 'pm'
                        #if (time < -12):
                         #       time = str(time + 24) + 'am'
                        x_axis.append(temp)
                count = count + 1
        plt.xticks(x_coor, x_axis)
        plt.xticks(rotation=90)
        plt.title('Protection runs in the past day')
        plt.gcf().subplots_adjust(bottom=0.15)
        plt.xlabel('time')
        plt.savefig('/home/cohesity/.local/share/powershell/Modules/cohesity-module-for-poshbot/PoshBot.Cohesity/public/graph.png')
#        plt.savefig(done.png)
if __name__ == "__main__":
        arg1 = sys.argv[1]
        arg2 = sys.argv[2]
        arg3 = sys.argv[3]
        graph(arg1, arg2, arg3)