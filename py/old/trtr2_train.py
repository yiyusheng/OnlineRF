# -*- coding:utf-8 -*-
from multiprocessing import Pool
import os,time

def exec_cmd(cmd,endid):
  str = cmd %(endid,endid)
  print 'Run task %s(%s)...\ncommand:%s' %(endid,os.getpid(),str)
  start = time.time()
  os.system(str)
  end = time.time()
  print 'Task %s runs %0.2f seconds.' %(endid,(end-start))

if __name__=='__main__':
  train2_lastid = [
    30261, 92495,152778,215387,273983,335970,391756,
    437229,467607,489691,511793,526705,538443,550386,557258,
    563947,570257,576830,582177,585079,586987,587005,
    ]

  train2_lastid_selected = [
    30261,92495,152778,273983,391756,511793,587005,
    ]
  
  all2_lastid = [
    43317,133802,223874,319027,414898,531093,638823,
    734518,807688,846765,883214,912154,933736,954474,968344,
    982910,994404,1010636,1020460,1024840,1029559,1029590,
    ]

  train1_lastid = [
    32193,38612,44848,51552,59040,67081,75734,84278,93996,103823,
    114832,126182,138476,151453,164880,179684,194844,212770,
    231865,250782,272443,293930,316032,336861,359090,381341,
    402983,425719,447489,470290,489863,510306,533275,
    ]


  all1_lastid = [
    34832,41891,49030,57042,66917,76821,88595,100036,113395,128583,
    145759,163406,181677,201561,223384,248694,276089,310277,
    348876,388985,436136,485615,535990,583677,635136,687169,
    739015,791513,841048,894902,940160,988146,1046368,
    ]

  p = Pool(8)
  cmd = "cd /home/yiyusheng/Code/C/OnlineRF/online_rfr;./OMCBoost -c conf/train_train.conf --orfr --train --test -negPoisson 0.05 -trainIndEnd %s -testIndEnd 587005 -testP 1 -outP train > /home/yiyusheng/Data/log/OnlineRF/%s"
  #cmd = "cd /home/yiyusheng/Code/C/OnlineRF/online_rfr;./OMCBoost -c conf/train_train.conf --orfr --train --test -negPoisson 0.05 -trainIndEnd %s -testIndEnd 587005 -testP 1 -outP train > /home/yiyusheng/Data/log/OnlineRF/%s"

  len_id = len(train2_lastid_selected)
  #len_id = 1
  for i in range(len_id):
    p.apply_async(exec_cmd,args=(cmd,train2_lastid_selected[i]))
  p.close()
  p.join()
