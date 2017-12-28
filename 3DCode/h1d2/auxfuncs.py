import math
import sys

# function to cehck if PID is running
'''
def checkpid(pid):
    """ Check for the existence of a unix pid. """
    try:
        return os.path.exists("/proc/"+str(pid))
'''

# functional form to compare modes to
def bandform(x,y):
    a = [0,0,0]
    return a[0]*x+a[1]*y**2+a[2] # reference frequency at this k point

# class to Tee object out, from stackoverflow
class Tee(object): 
    def __init__(self, name): 
        self.file = open(name, "w") 
        self.stdout = sys.stdout 
        sys.stdout = self 
    def __del__(self): 
        sys.stdout = self.stdout 
        self.file.close() 
    def write(self, data): 
       self.file.write(data) 
       self.stdout.write(data)
       self.file.flush()
