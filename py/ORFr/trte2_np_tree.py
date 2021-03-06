# -*- coding:utf-8 -*-
from multiprocessing import Pool
import os,time

def exec_cmd(cmd,para1,para2,para3):
  str = cmd %(para1,para2,para3,para3,para1,para2)
  print 'Run task %s_%s(%s)...\ncommand:%s' %(para1,para2,os.getpid(),str)
  start = time.time()
  os.system(str)
  end = time.time()
  print 'Task %s_%s runs %0.2f seconds.' %(para1,para2,(end-start))

if __name__=='__main__':
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

  train2_lastid = [
    30261, 92495,152778,215387,273983,335970,391756,
    437229,467607,489691,511793,526705,538443,550386,557258,
    563947,570257,576830,582177,585079,586987,587005,
    ]

  all2_lastid = [
    43317,133802,223874,319027,414898,531093,638823,
    734518,807688,846765,883214,912154,933736,954474,968344,
    982910,994404,1010636,1020460,1024840,1029559,1029590,
    ]
  
  lastid = train2_lastid
  lastid_selected = [3]
  negP = [0.005,0.01,0.03,0.05]
  nTree = [10,20,40,80]
  outP = "J30SBM3"

  cmd = "cd /home/yiyusheng/Code/C/OnlineRF/online_rfr;./OMCBoost -c conf/smart2_train_test.conf --orfr --train --test -negPoisson %s -trainIndEnd 215387 -nTree %s -testP 1 -outP %s > /home/yiyusheng/Data/log/OnlineRF/ORFr/%s_NT%s_NP%s"

  para1 = negP
  para2 = nTree
  len1 = len(para1)
  len2 = len(para2)
  p = Pool(min(len1*len2,40))

  for i in range(len1):
    for j in range(len2):
      p.apply_async(exec_cmd,args=(cmd,para1[i],para2[j],outP))

  p.close()
  p.join()

  
