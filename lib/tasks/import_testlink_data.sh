#!/bin/sh
#filename="pro_testlink_"$(date -d "today" +"%Y%m%d_%H%M%S")".sql"
#echo $filename
mysql -utestplus -ptestplus123 -e"call testlink.import_test_to_testplus"
curl http://192.168.28.210/import_data/refresh_testlink_data