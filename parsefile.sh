#setup 
#source S3 
S3dirDown=customly-test-resizing; 
#destination
S3dir=customly-test-resizing;
#end setup 
if [ "$3" = "1" ]
then
exit 0;
elif [ $# == 4 ]
then
fil=$4 ;
elif [ $# == 5 ]
then
fil=$4" "$5;
elif [ $# == 6 ]
then
fil=$4" "$5" "$6;
elif [ $# == 7 ]
then
fil=$4" "$5" "$6" "$7;
else
echo "too many spaces" ;
exit 2;
fi

echo _$fil"____________________________"

if [ $(basename "$fil" "-H.jpg") != $(basename "$fil") ] 
then
echo $(basename "$fil" ) $(basename "$fil" "-H.jpg") " this is  H: ignored"
exit
fi
if [ $(basename "$fil" "-L.jpg") != $(basename "$fil") ] 
then
echo $(basename "$fil" ) " this is  L: ignored"
exit
fi
if [ $(basename "$fil" "-S.jpg") != $(basename "$fil") ] 
then
echo $(basename "$fil" ) " this is  S: ignored"
exit
fi
if [ $(basename "$fil" "-M.jpg") != $(basename "$fil") ] 
then
echo $(basename "$fil" ) " this is  M: ignored"
exit
fi

#processing filenames
extension="${fil##*.}";
fbname=$(basename "$fil" .$extension);
dirna=$(dirname "$fil")/;
if [ "$dirna" == "./" ] 
then 
#echo "dir nulla"
dirna=

fi
echo "dirname: " $dirna
fil2=$fbname.$extension


#get the remote file
aws s3 cp s3://$S3dirDown/$fil .

#if the file is loacally present
if [ -f $fbname.$extension ]
then
#upscale to a better resolution
convert -resize 200%% -filter Lagrange -interpolate filter  ./$fbname.$extension tmp.tif 
#reduce high frequency details, for a sharper result reduce 0.5 param for faster calculation reduce 5 (not less than 2)
convert -auto-level -filter Lanczos -interpolate filter   -adaptive-blur 5x0.5 tmp.tif tmp2.tif
#scale down the image L
convert  -resize 50%% -filter Lanczos	 -interpolate filter -strip  -quality %2  -define jpeg:dct-method=float -sampling-factor 4:2:0  -interlace Plane tmp2.tif $fbname-L.$extension
if [ -f $fbname-L.$extension ] 
then 
echo "sending : " s3://$S3dir/$dirna$fbname-L.$extension 
aws s3 cp ./$fbname-L.$extension s3://$S3dir/$dirna$fbname-L.$extension --metadata-directive REPLACE --expires 2100-01-01T00:00:00Z --acl public-read --cache-control max-age=2592000,public
else 
echo "Failed converting " $fbname-L.$extension 
fi

#scale down the image M
convert  -resize 31% -filter Lanczos -interpolate filter -strip  -quality $2  -define jpeg:dct-method=float -sampling-factor 4:2:0  -interlace Plane tmp2.tif $fbname-M.$extension
if [ -f $fbname-M.$extension ] 
then 
echo "sending : " s3://$S3dir/$dirna$fbname-M.$extension 
aws s3 cp ./$fbname-L.$extension s3://$S3dir/$dirna$fbname-M.$extension --metadata-directive REPLACE --expires 2100-01-01T00:00:00Z --acl public-read --cache-control max-age=2592000,public
else
echo "Failed converting " $fbname-M.$extension 
fi

#scale down the image S
convert  -resize 24% -filter Lanczos -interpolate filter -strip  -quality $2  -define jpeg:dct-method=float -sampling-factor 4:2:0  -interlace Plane tmp2.tif $fbname-S.$extension
if [ -f $fbname-S.$extension ] 
then 
echo "sending : " s3://$S3dir/$dirna$fbname-S.$extension 
aws s3 cp ./$fbname-L.$extension s3://$S3dir/$dirna$fbname-S.$extension --metadata-directive REPLACE --expires 2100-01-01T00:00:00Z --acl public-read --cache-control max-age=2592000,public
else
echo "Failed converting " $fbname-S.$extension 
fi


else "Failed:not downloaded " $fil

fi

#cleanup
rm tmp*.*
rm ./$fbname*
