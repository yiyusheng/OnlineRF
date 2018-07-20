function [monthMax] = month_lastid(smart)
  dv = datevec(smart.date);
  smart.year = dv(:,1);
  smart.month = dv(:,2);
  monthMax = varfun(@max,smart,'GroupingVariables',{'year','month'},'InputVariable','id');
end
