while read -r line; do 
#could be done with IFS=- read var1 var2 <<< text 
#but i prefere to keep  single file opration in a different file
./parsefile.sh $line; 

done
rm tmp*
rm *.jpg
rm *.tif
