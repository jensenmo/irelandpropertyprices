for i in {2010..2016} ; do
  curl 'https://www.propertypriceregister.ie/website/npsra/ppr/npsra-ppr.nsf/Downloads/PPR-'"$i"'.csv/$FILE/PPR-'"$i"'.csv' >PPR-$i.csv
done

for f in PPR-*.csv
do
  echo Appending $f
  cat $f | tr -d '\015' | tr -d '\200' | tail -n+2 >>PPR_IMP.csv
done

