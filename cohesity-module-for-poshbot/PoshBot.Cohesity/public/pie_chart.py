# Copyright 2019 Cohesity Inc.
# Author : Christina Mudarth <christina.mudarth@cohesity.com>
# This script is run by Get-PBCohesityUsage.ps1
# creates a graph
import matplotlib
matplotlib.use('Agg')
import sys
import matplotlib.pyplot as plt; plt.rcdefaults()
import numpy as np

def graph(used, available, path):
    # Pie chart
    used = float(used)
    available = float(available)
    gib_used = round((used / 1074000000), 1)
    gib_available = round((available / 1074000000), 1)
    use = "used: " + str(gib_used) + " GiB"
    avail = "available: " + str(gib_available) + " GiB"
    sizes = [used, available]
    # colors
    colors = ['#36539D', '#9EC7F1']
    labels = [use, avail]
    fig1, ax1 = plt.subplots()
    ax1.pie(sizes, colors=colors, labels=labels,
            autopct='%1.1f%%', startangle=90)
    # draw circle
    centre_circle = plt.Circle((0, 0), 0.70, fc='white')
    fig = plt.gcf()
    fig.gca().add_artist(centre_circle)
    # Equal aspect ratio ensures that pie is drawn as a circle
    ax1.axis('equal')
    plt.tight_layout()
    plt.show()
    path_png = path + '/pie_chart.png'
    plt.savefig(
        path_png)


if __name__ == "__main__":
    arg1 = sys.argv[1]
    arg2 = sys.argv[2]
    arg3 = sys.argv[3]
    graph(arg1, arg2, arg3)
