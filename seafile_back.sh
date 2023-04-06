#!/bin/bash
username=$1
db_passwd=$2
passwd=$3
back_time_dir=$(date +%Y%m%d_%H)
back_dir=/opt/seafile-backup
back_database_path=$back_dir/$back_time_dir/databases
back_data_path=$back_dir/$back_time_dir/data

echo "check the path of database backup" $back_database_path
if [ ! -d $back_database_path ];then
	mkdir -p $back_database_path
else
	echo $back_database_path exist
fi

echo "check the path of data backup" $back_data_path
if [ ! -d $back_data_path ];then
	mkdir -p $back_data_path
else
	echo $back_data_path exist
fi

echo "begin to backup db data"
cd $back_database_path
sudo docker exec -it seafile-mysql mysqldump  -uroot -p$db_passwd --opt ccnet_db > ccnet_db.sql
sudo docker exec -it seafile-mysql mysqldump  -uroot -p$db_passwd --opt seafile_db > seafile_db.sql
sudo docker exec -it seafile-mysql mysqldump  -uroot -p$db_passwd --opt seahub_db > seahub_db.sql
echo "end to backup db data"

echo "begin to backup seafile data"
sudo rsync -az /opt/seafile-data/seafile $back_data_path
echo "end to backup seafile data"

echo "zip backup data"
sudo chown -R $username:$username $back_dir
cd $back_data_path && rm -rf ccnet
cd $back_dir
zip -P $passwd  -r -q $back_time_dir.zip $back_time_dir
echo "clean to tmp files"
rm -rf $back_time_dir
echo "finished"
