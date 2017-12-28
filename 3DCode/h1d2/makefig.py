# make figures from .h5 files
import os

os.system('h5topng -S3 -y -0 -RZc dkbluered -a yarg -A narrowf-eps-000000.00.h5 narrowf-ey-*.h5')
os.system('convert *.png a.gif')
