CREATE DATABASE Coffee_Shop_Sales_Db;

SELECT * FROM `coffee shop sales`;

DESCRIBE `coffee shop sales`;


SET SQL_SAFE_UPDATES=0;
UPDATE `coffee shop sales`
SET transaction_date=STR_TO_DATE(transaction_date,'%d-%m-%Y');

ALTER TABLE `coffee shop sales`
MODIFY COLUMN transaction_date DATE;


UPDATE `coffee shop sales`
SET  transaction_time=STR_TO_DATE(transaction_time,'%H:%i:%s');

ALTER TABLE `coffee shop sales`
MODIFY COLUMN transaction_time TIME;

ALTER TABLE `coffee shop sales`
CHANGE COLUMN ï»¿transaction_id transaction_id INT;

SELECT ROUND(SUM(transaction_qty*unit_price))
FROM `coffee shop sales`
WHERE MONTH(transaction_date)=5;


