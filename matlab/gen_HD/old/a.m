s2 = smart2_test;
size_s2t = size(s2);
a = 0;
b = 0;
count = 1;
c = zeros(1277,1);

if(s2.class(1)==1)
  a = 1;
  c(count)=a;
  count=count+1;
else
  b=1;
  c(count)=b;
  count=count+1;
sn_left = s2.sn_id(1);
end

for i = 1:size_s2t(1)
  sn = s2.sn_id(i);
  cls = s2.class(i);
  if(sn~=sn_left && cls==1)
    a = a+1;
    sn_left=sn;
    c(count)=a;
    count = count+1;
  end

  if(sn~=sn_left && cls==0)
    b = b+1;
    sn_left=sn;
    c(count)=b;
    count = count+1;
  end
end

