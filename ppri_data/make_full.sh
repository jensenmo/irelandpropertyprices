
full=PPR_IMP.csv

echo -n > $full
# echo "Date of Sale (dd/mm/yyyy),Address,Postal Code,County,Price (<80>),Not Full Market Price,VAT Exclusive,Description of Property,Property Size Description" >$full

for f in PPR-*.csv
do
  echo Appending $f
  cat $f | tr -d '\015' | tr -d '\200' | tail -n+2 >>$full
done
