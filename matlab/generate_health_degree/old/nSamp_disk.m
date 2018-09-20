function  [] = nSamp_disk(smart)
  a = smart;
  a_pos = a(a.class==1,:);
  a_neg = a(a.class==0,:);
  size_posid = size(unique(a_pos.sn_id));
  size_negid = size(unique(a_neg.sn_id));
  size_pos = size(a_pos);
  size_neg = size(a_neg);

  nSamp_pos = size_pos/size_posid
  nSamp_neg = size_neg/size_negid
%varfun(@length,b,'GroupingVariables',{'sn_id'},'InputVariable',{'sn_id'})
end
