#!/bin/bash
db_date=$2
echo $db_date
db_name=gmall
import_data(){
/opt/module/sqoop/bin/sqoop import \
--connect jdbc:mysql://hadoop102:3306/$db_name
--username=root \
--password=123456 \
#hive表在hdfs的路径 $1是表名
--target-dir /origin_data/$db_name/db/$1/$db_date \
--delete-target-dir \
#对应hdfs里卖弄会生成几份文件
--num-mappers 1 \
--fields-terminated-by "\t" \
--query "$2"' and $CONDINATIONS;'
}
#判断全量表
import_sku_info(){
 import data "sku_info" "select 
 id,spu_id,price,sku_name,sku_desc,weight,tm_id,category3_id,create_time
 from sku_info where 1=1"
}
import_base_category1(){
 import data "base_category1" "select 
 id,spu_id,price,sku_name,sku_desc,weight,tm_id,category3_id,create_time
 from sku_info where 1=1"
}
#判断增量表
import_order_detail(){
 import data "order_detail" "select 
 id,spu_id,price,sku_name,sku_desc,weight,tm_id,category3_id,create_time
 from order_info o,order_detail od where o.id=od.order_id
 and DATE_FORMART(create_time,'%Y-%m-%d')='$db_date'
 "
}
#判断增量和变化 判断新增时间和更新时间是否都是今天
import_order_info(){
 import data "order_info" "select 
 id,spu_id,price,sku_name,sku_desc,weight,tm_id,category3_id,create_time
 from order_info 
 where (DATE_FORMART(create_time,'%Y-%m-%d')='$db_date' or 
 DATE_FORMART(opereate_time,'%Y-%m-%d')='$db_date'
 )
 "
}
case $1 in
  "base_category1")
     import_base_category1
;; 
   "sku_info")
     import_sku_info
;; 
   "order_detail")
     import_order_detail
;; 
   "order_info")
     import_order_info
;; 
   "all")
     import_base_category1
	 import_sku_info
	 import_order_detail
	 import_order_info
;; 
esac
echo "test case end"