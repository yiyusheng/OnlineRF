# -*- coding:utf-8 -*-
from multiprocessing import Pool
import os,time

def exec_cmd(cmd,p):
  str = cmd %(p,p)
  print 'Run task %s(%s)...\ncommand:%s' %(p,os.getpid(),str)
  start = time.time()
  os.system(str)
  end = time.time()
  print 'Task %s runs %0.2f seconds.' %(p,(end-start))

if __name__=='__main__':
  poisson = [
      0.01,0.02,0.03,0.04,0.05,0.06,0.07,0.08,0.09,0.10,
      0.15,0.20,0.25,0.30,0.40,0.50,
      ]

  p = Pool(20)
  cmd = "cd /home/yiyusheng/Code/C/OnlineRF/online_rfr;./OMCBoost -c conf/train_test.conf --orfr --train --test -negPoisson %s -trainIndEnd 152778 -testIndEnd 153147 -testP 1 -outP poisson> /home/yiyusheng/Data/log/OnlineRF/poisson_%s"

  len_id = len(poisson)
  for i in range(len_id):
    p.apply_async(exec_cmd,args=(cmd,poisson[i]))
  p.close()
  p.join()
