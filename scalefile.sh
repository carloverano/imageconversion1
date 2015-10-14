extension="${1##*.}"
fbname=$(basename "$1" .$extension)
convert -resize 200%% -filter Lagrange -interpolate filter  ./$fbname.$extension tmp.tif 

convert -auto-level -filter Lanczos -interpolate filter   -adaptive-blur 5x0.5 tmp.tif tmp2.tif
convert  -resize 50%% -filter Lanczos	 -interpolate filter -strip  -quality %2  -define jpeg:dct-method=float -sampling-factor 4:2:0  -interlace Plane tmp2.tif $fbname-L.jpg 
convert  -resize 31% -filter Lanczos -interpolate filter -strip  -quality $2  -define jpeg:dct-method=float -sampling-factor 4:2:0  -interlace Plane tmp2.tif $fbname-M.jpg 
convert  -resize 24% -filter Lanczos -interpolate filter -strip  -quality $2  -define jpeg:dct-method=float -sampling-factor 4:2:0  -interlace Plane tmp2.tif $fbname-S.jpg 
rm tmp*.*
