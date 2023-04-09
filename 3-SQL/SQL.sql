/*Q1. Write a query to display customer_id, customer full name with their title (Mr/Ms),  both first name and last name are in upper case, customer email id,  customer creation year and display customer’s category after applying below categorization rules:
 i. if CUSTOMER_CREATION_DATE year <2005 then category A
 ii. if CUSTOMER_CREATION_DATE year >=2005 and <2011 then category B 
 iii. if CUSTOMER_CREATION_DATE year>= 2011 then category C
 Hint: Use CASE statement, no permanent change in the table is required. 
 Expected 52 rows in final output.
 [Note: TABLE to be used - ONLINE_CUSTOMER TABLE] 
*/

## Answer 1.

Use orders;

Show tables;

select * from online_customer;

SELECT 
  CONCAT(CASE WHEN CUSTOMER_GENDER = 'M' THEN 'Mr.' ELSE 'Ms.' END, ' ', 
  UPPER(CUSTOMER_FNAME), ' ', UPPER(CUSTOMER_LNAME)) AS CUSTOMER_FULL_NAME, 
  CUSTOMER_EMAIL, 
  CUSTOMER_CREATION_DATE, 
  CASE 
    WHEN YEAR(CUSTOMER_CREATION_DATE) < 2005 THEN 'Category A' 
    WHEN YEAR(CUSTOMER_CREATION_DATE) >= 2005 AND YEAR(CUSTOMER_CREATION_DATE) < 2011 THEN 'Category B' 
    ELSE 'Category C' 
  END AS category 
FROM ONLINE_CUSTOMER;

/*Explanation of the code:
1)This query first concatenates the title (Mr or Ms) with the first name and last name of the customer in upper case using the CONCAT function and assigns the result to a column full_name.
2)Next, it uses the CASE statement to determine the category based on the customer's creation date, as specified by the conditions you provided. 
3)The YEAR function is used to extract the year component of the creation_date field.
 */  
 
  /* Q2. Write a query to display the following information for the products, which have not been sold: product_id, product_desc, product_quantity_avail, product_price, inventory values ( product_quantity_avail * product_price), New_Price after applying discount as per below criteria. Sort the output with respect to decreasing value of Inventory_Value. 
i) If Product Price > 200,000 then apply 20% discount 
ii) If Product Price > 100,000 then apply 15% discount 
iii) if Product Price =< 100,000 then apply 10% discount 
Hint: Use CASE statement, no permanent change in table required. 
Expected 13 rows in final output.
[NOTE: TABLES to be used - PRODUCT, ORDER_ITEMS TABLE] */

## Answer 2.

Use orders;

select * from PRODUCT ;

select * from ORDER_ITEMS;


SELECT PRODUCT.PRODUCT_ID FROM PRODUCT,ORDER_ITEMS;
SELECT PRODUCT_DESC, PRODUCT_QUANTITY_AVAIL,PRODUCT_PRICE, (PRODUCT_QUANTITY_AVAIL * PRODUCT_PRICE) AS Inventory_Value, 
    CASE 
        WHEN PRODUCT_PRICE > 20000 THEN PRODUCT_PRICE * 0.8 
        WHEN PRODUCT_PRICE > 10000 THEN PRODUCT_PRICE * 0.85 
        ELSE PRODUCT_PRICE * 0.9 
    END AS New_Price 
FROM  PRODUCT AS P
LEFT JOIN ORDER_ITEMS  AS OI 
    ON OI.PRODUCT_ID = P.PRODUCT_ID 
WHERE OI.PRODUCT_ID IS NULL

ORDER BY Inventory_Value DESC;

/*Explanation of the code:
1)SELECT statement: The first line of the code selects the PRODUCT_ID column from the PRODUCT table.
2)Then in the next step selects several columns from the PRODUCT table. The columns are PRODUCT_DESC, PRODUCT_QUANTITY_AVAIL, PRODUCT_PRICE, and an expression that calculates the Inventory_Value (product quantity available multiplied by product price). The code also includes a CASE statement that calculates a New_Price based on discounts applied to the product price.
3)FROM clause: The FROM clause specifies the PRODUCT table with an alias P, and performs a LEFT JOIN with the ORDER_ITEMS table with an alias OI. The LEFT JOIN will return all rows from the PRODUCT table and the matching rows from the ORDER_ITEMS table. If there's no match, the result will contain NULL values for the columns from the ORDER_ITEMS table.
4)WHERE clause and ORDER BY clause: The WHERE clause filters the results to only include rows where the PRODUCT_ID in the ORDER_ITEMS table is NULL. The ORDER BY clause sorts the results in descending order based on the Inventory_Value.
*/

/* Q3. Write a query to display Product_class_code, Product_class_description, 
Count of Product type in each product class, 
Inventory Value (p.product_quantity_avail*p.product_price).
Information should be displayed for only those product_class_code which
 have more than 1,00,000 Inventory Value. Sort the output with respect to
 decreasing value of Inventory_Value. 
Expected 9 rows in final output.
[NOTE: TABLES to be used - PRODUCT, PRODUCT_CLASS] */

## Answer 3.

use orders;

SELECT 
  PRODUCT_CLASS.PRODUCT_CLASS_CODE, 
  PRODUCT_CLASS.PRODUCT_CLASS_DESC, 
  COUNT(PRODUCT.PRODUCT_ID) AS PRODUCT_COUNT, 
  SUM(PRODUCT.PRODUCT_QUANTITY_AVAIL * PRODUCT.PRODUCT_PRICE) AS INVENTORY_VALUE 
FROM 
  PRODUCT 
  INNER JOIN PRODUCT_CLASS ON PRODUCT.PRODUCT_CLASS_CODE = PRODUCT_CLASS.PRODUCT_CLASS_CODE 
GROUP BY 
  PRODUCT_CLASS.PRODUCT_CLASS_CODE, 
  PRODUCT_CLASS.PRODUCT_CLASS_DESC 
HAVING 
  INVENTORY_VALUE > 100000 
ORDER BY 
  INVENTORY_VALUE DESC;

/*Explanation of the code:
1)Joining the tables: The code performs an inner join between the "PRODUCT" and "PRODUCT_CLASS" tables on the "PRODUCT_CLASS_CODE" column. This returns only the rows where there is a match between the two tables.
2)Aggregating data: The code then groups the result of the join by "PRODUCT_CLASS_CODE" and "PRODUCT_CLASS_DESC" and calculates the count of products (PRODUCT_COUNT) and the sum of the product quantity available multiplied by the price (INVENTORY_VALUE) for each product class.
3)Filtering and sorting: The code filters the result using the HAVING clause to only show product classes where the INVENTORY_VALUE is greater than 100000. The result is finally sorted in descending order based on the INVENTORY_VALUE.

/* Q4. Write a query to display customer_id, full name, customer_email, customer_phone and
 country of customers who have cancelled all the orders placed by them.
Expected 1 row in the final output
 [NOTE: TABLES to be used - ONLINE_CUSTOMER, ADDRESSS, OREDER_HEADER] */
 
## Answer 4.


SELECT 
  ONLINE_CUSTOMER.CUSTOMER_ID,
  CONCAT(ONLINE_CUSTOMER.CUSTOMER_FNAME, ' ', ONLINE_CUSTOMER.CUSTOMER_LNAME) AS FULL_NAME,
  ONLINE_CUSTOMER.CUSTOMER_EMAIL,
  ONLINE_CUSTOMER.CUSTOMER_PHONE,
  ADDRESS.COUNTRY
FROM
  (
    SELECT 
      CUSTOMER_ID, 
      CUSTOMER_FNAME, 
      CUSTOMER_LNAME, 
      CUSTOMER_EMAIL, 
      CUSTOMER_PHONE, 
      ADDRESS_ID
    FROM 
      ONLINE_CUSTOMER
  ) ONLINE_CUSTOMER
  JOIN ADDRESS ON ONLINE_CUSTOMER.ADDRESS_ID = ADDRESS.ADDRESS_ID
  LEFT JOIN 
  (
    SELECT 
      CUSTOMER_ID
    FROM 
      ORDER_HEADER
  ) ORDER_HEADER ON ONLINE_CUSTOMER.CUSTOMER_ID = ORDER_HEADER.CUSTOMER_ID
WHERE
  ORDER_HEADER.CUSTOMER_ID IS NULL
GROUP BY 
  ONLINE_CUSTOMER.CUSTOMER_ID,
  FULL_NAME,
  ONLINE_CUSTOMER.CUSTOMER_EMAIL,
  ONLINE_CUSTOMER.CUSTOMER_PHONE,
  ADDRESS.COUNTRY
  LIMIT 1;

/*Explanation of the code:
1.The code starts by selecting specific columns from the ONLINE_CUSTOMER table and concatenating the CUSTOMER_FNAME and CUSTOMER_LNAME columns into a full name column.
2.Then, it joins the ADDRESS table on ADDRESS_ID and performs a left join with the ORDER_HEADER table on CUSTOMER_ID.
3.Finally, the code filters the results to only include customers who have not placed any orders (ORDER_HEADER.CUSTOMER_ID IS NULL) and groups the results by all selected columns. The final result is limited to only show 1 row using the LIMIT 1 clause.
*/

/* Q5. Write a query to display Shipper name, City to which it is catering,
 num of customer catered by the shipper in the city , number of consignment
 delivered to that city for Shipper DHL 
Hint: The answer should only be based on Shipper_Name -- DHL.
Expected 9 rows in the final output
[NOTE: TABLES to be used - SHIPPER, ONLINE_CUSTOMER, ADDRESSS, ORDER_HEADER] */

## Answer 5.  

SELECT
SHIPPER.SHIPPER_NAME,
ADDRESS.CITY,
COUNT(DISTINCT ONLINE_CUSTOMER.CUSTOMER_ID) AS NUM_OF_CUSTOMERS,
COUNT(ORDER_HEADER.SHIPPER_ID) AS NUM_OF_CONSIGNMENTS
FROM
SHIPPER
JOIN ORDER_HEADER ON SHIPPER.SHIPPER_ID = ORDER_HEADER.SHIPPER_ID
JOIN ONLINE_CUSTOMER ON ORDER_HEADER.CUSTOMER_ID = ONLINE_CUSTOMER.CUSTOMER_ID
JOIN ADDRESS ON ONLINE_CUSTOMER.ADDRESS_ID = ADDRESS.ADDRESS_ID
WHERE
SHIPPER.SHIPPER_NAME = 'DHL'
GROUP BY
SHIPPER.SHIPPER_NAME,
ADDRESS.CITY;

/*Explanation of the code:
1)Joining the tables: The query starts by joining the SHIPPER table with the ORDER_HEADER table on the SHIPPER_ID column. Then, it joins the ONLINE_CUSTOMER table with the ORDER_HEADER table on the CUSTOMER_ID column. Finally, it joins the ADDRESS table with the ONLINE_CUSTOMER table on the ADDRESS_ID column.
2)Filtering the data: The query filters the data to include only the shipper with the name 'DHL' by using a WHERE clause.
3)Grouping and aggregating the data: The query groups the data by SHIPPER_NAME and CITY and counts the number of distinct CUSTOMER_ID values as NUM_OF_CUSTOMERS and counts the number of SHIPPER_ID values as NUM_OF_CONSIGNMENTS. The final result displays the shipper name, city, number of customers, and number of consignments.


/* Q6. Write a query to display product_id, product_desc, product_quantity_avail, quantity sold and show inventory Status of products as per below condition: 
a. For Electronics and Computer categories, 
if sales till date is Zero then show  'No Sales in past, give discount to reduce inventory', 
if inventory quantity is less than 10% of quantity sold, show 'Low inventory, need to add inventory', 
if inventory quantity is less than 50% of quantity sold, show 'Medium inventory, 
need to add some inventory',
if inventory quantity is more or equal to 50% of quantity sold, show 'Sufficient inventory' 

b. For Mobiles and Watches categories, 
if sales till date is Zero then show 'No Sales in past, give discount to reduce inventory', 
if inventory quantity is less than 20% of quantity sold, show 'Low inventory, need to add inventory', 
if inventory quantity is less than 60% of quantity sold, show 'Medium inventory, 
need to add some inventory', 
if inventory quantity is more or equal to 60% of quantity sold, show 'Sufficient inventory' 

c. Rest of the categories, 
if sales till date is Zero then show 'No Sales in past, give discount to reduce inventory', 
if inventory quantity is less than 30% of quantity sold, show 'Low inventory, need to add inventory', 
if inventory quantity is less than 70% of quantity sold, show 'Medium inventory, 
need to add some inventory',
if inventory quantity is more or equal to 70% of quantity sold, show 'Sufficient inventory'
Expected 60 rows in final output
[NOTE: (USE CASE statement) ; TABLES to be used - PRODUCT, PRODUCT_CLASS, ORDER_ITEMS] */

## Answer 6.


SELECT
PRODUCT.PRODUCT_ID,
PRODUCT.PRODUCT_DESC,
PRODUCT.PRODUCT_QUANTITY_AVAIL,
SUM(ORDER_ITEMS.PRODUCT_QUANTITY) AS QUANTITY_SOLD,
CASE
WHEN PRODUCT_CLASS.PRODUCT_CLASS_DESC IN ('Electronics', 'Computers') THEN
CASE
WHEN SUM(ORDER_ITEMS.PRODUCT_QUANTITY) = 0 THEN 'No Sales in past, give discount to reduce inventory'
WHEN PRODUCT.PRODUCT_QUANTITY_AVAIL < SUM(ORDER_ITEMS.PRODUCT_QUANTITY) * 0.1 THEN 'Low inventory, need to add inventory'
WHEN PRODUCT.PRODUCT_QUANTITY_AVAIL < SUM(ORDER_ITEMS.PRODUCT_QUANTITY) * 0.5 THEN 'Medium inventory, need to add some inventory'
ELSE 'Sufficient inventory'
END
WHEN PRODUCT_CLASS.PRODUCT_CLASS_DESC IN ('Mobiles', 'Watches') THEN
CASE
WHEN SUM(ORDER_ITEMS.PRODUCT_QUANTITY) = 0 THEN 'No Sales in past, give discount to reduce inventory'
WHEN PRODUCT.PRODUCT_QUANTITY_AVAIL < SUM(ORDER_ITEMS.PRODUCT_QUANTITY) * 0.2 THEN 'Low inventory, need to add inventory'
WHEN PRODUCT.PRODUCT_QUANTITY_AVAIL < SUM(ORDER_ITEMS.PRODUCT_QUANTITY) * 0.6 THEN 'Medium inventory, need to add some inventory'
ELSE 'Sufficient inventory'
END
ELSE
CASE
WHEN SUM(ORDER_ITEMS.PRODUCT_QUANTITY) = 0 THEN 'No Sales in past, give discount to reduce inventory'
WHEN PRODUCT.PRODUCT_QUANTITY_AVAIL < SUM(ORDER_ITEMS.PRODUCT_QUANTITY) * 0.3 THEN 'Low inventory, need to add inventory'
WHEN PRODUCT.PRODUCT_QUANTITY_AVAIL < SUM(ORDER_ITEMS.PRODUCT_QUANTITY) * 0.7 THEN 'Medium inventory, need to add some inventory'
ELSE 'Sufficient inventory'
END
END AS INVENTORY_STATUS
FROM
PRODUCT
JOIN PRODUCT_CLASS ON PRODUCT.PRODUCT_CLASS_CODE = PRODUCT_CLASS.PRODUCT_CLASS_CODE
JOIN ORDER_ITEMS ON PRODUCT.PRODUCT_ID = ORDER_ITEMS.PRODUCT_ID
GROUP BY
PRODUCT.PRODUCT_ID,
PRODUCT.PRODUCT_DESC,
PRODUCT.PRODUCT_QUANTITY_AVAIL,
PRODUCT_CLASS.PRODUCT_CLASS_DESC;

/*Explanation of the code:
1)Joining of tables: The "PRODUCT", "PRODUCT_CLASS", and "ORDER_ITEMS" tables are joined on common columns. This allows the data from these tables to be combined and used in the same query.
2)Grouping of data: The query uses the "GROUP BY" clause to group the data by product ID, description, quantity available, and product class description. This allows the calculation of aggregate values such as the sum of product quantities sold.
3)Calculating Inventory Status: The query uses a "CASE" statement to calculate the inventory status based on the values of product quantity available and the sum of product quantities sold. The inventory status is calculated differently based on the product class description, with three possible values: "No Sales in past, give discount to reduce inventory", "Low inventory, need to add inventory", "Medium inventory, need to add some inventory", and "Sufficient inventory". The calculated inventory status is assigned to the "INVENTORY_STATUS" column in the result set.
4)Finally, the query selects the product ID, description, quantity available, quantity sold, and inventory status columns from the result set.
*/

/* Q7. Write a query to display order_id and volume of the biggest order (in terms of volume) 
that can fit in carton id 10 .
Expected 1 row in final output
[NOTE: TABLES to be used - CARTON, ORDER_ITEMS, PRODUCT] */

## Answer 7.

use orders;

SELECT oi.ORDER_ID, SUM(oi.PRODUCT_QUANTITY * p.LEN * p.WIDTH * p.HEIGHT) AS total_volume
FROM ORDER_ITEMS AS oi
JOIN PRODUCT AS p ON oi.PRODUCT_ID = p.PRODUCT_ID
WHERE oi.ORDER_ID NOT IN (
  SELECT ORDER_ID
  FROM ORDER_ITEMS AS oi2
  JOIN PRODUCT AS p2 ON oi2.PRODUCT_ID = p2.PRODUCT_ID
  WHERE oi2.ORDER_ID = oi.ORDER_ID
  GROUP BY oi2.ORDER_ID
  HAVING SUM(oi2.PRODUCT_QUANTITY * p2.LEN * p2.WIDTH * p2.HEIGHT) > (
    SELECT CARTON.LEN * CARTON.WIDTH * CARTON.HEIGHT
    FROM CARTON
    WHERE CARTON_ID = 10
  )
)
GROUP BY oi.ORDER_ID
ORDER BY total_volume DESC
limit 1;

/*Explanation of the code:
1)First, the query joins the ORDER_ITEMS table and PRODUCT table based on the PRODUCT_ID.
2)The query then filters the results based on the order_id of the ORDER_ITEMS table. The filtered order_ids are the ones that do not belong to an order that has a total volume greater than the carton id 10. This is done by using a subquery to calculate the total volume for each order and then excluding the orders whose volume exceeds the carton id 10.
3)Finally, the query groups the results by order_id, sums up the total volume of the products, and orders the results in descending order based on the total volume. It then returns only the first result, which is the order with the biggest volume that can fit in the carton id 10.


/* Q8. Write a query to display customer id, customer full name, total quantity and total value (quantity*price) shipped where mode of payment is Cash and customer last name starts with 'G'
Expected 2 rows in final output
[NOTE: TABLES to be used - ONLINE_CUSTOMER, ORDER_ITEMS, PRODUCT, ORDER_HEADER] */

## Answer 8.

SELECT 
  ONLINE_CUSTOMER.CUSTOMER_ID, 
  CONCAT(ONLINE_CUSTOMER.CUSTOMER_FNAME, ' ', ONLINE_CUSTOMER.CUSTOMER_LNAME) AS CUSTOMER_FULL_NAME, 
  SUM(ORDER_ITEMS.PRODUCT_QUANTITY) AS TOTAL_QUANTITY, 
  SUM(ORDER_ITEMS.PRODUCT_QUANTITY * PRODUCT.PRODUCT_PRICE) AS TOTAL_VALUE
FROM 
  ORDER_HEADER 
  JOIN ONLINE_CUSTOMER ON ORDER_HEADER.CUSTOMER_ID = ONLINE_CUSTOMER.CUSTOMER_ID 
  JOIN ORDER_ITEMS ON ORDER_HEADER.ORDER_ID = ORDER_ITEMS.ORDER_ID 
  JOIN PRODUCT ON ORDER_ITEMS.PRODUCT_ID = PRODUCT.PRODUCT_ID
WHERE 
  ORDER_HEADER.PAYMENT_MODE = 'Cash' 
  AND ONLINE_CUSTOMER.CUSTOMER_LNAME LIKE 'G%'
GROUP BY 
  ONLINE_CUSTOMER.CUSTOMER_ID, CUSTOMER_FULL_NAME;

/*Explanation of the code:
1)SELECT the columns for customer id, customer full name (created using concatenation of first name and last name), total quantity (sum of product quantity from ORDER_ITEMS table) and total value (sum of product quantity * product price from PRODUCT table).
2)FROM the ORDER_HEADER table, join the ONLINE_CUSTOMER and ORDER_ITEMS tables using the customer id and order id columns respectively. Join the PRODUCT table using the product id column.
3)WHERE the payment method is 'Cash' and the last name of the customer starts with 'G' (specified using the LIKE operator with a wildcard character %).
4)GROUP the result BY customer id and customer full name.


/* Q9. Write a query to display product_id, product_desc and total quantity of products
 which are sold together with product id 201 and are not shipped to city Bangalore and New Delhi. 
Display the output in descending order with respect to the tot_qty. 
Expected 6 rows in final output

Hint:  (USE SUB-QUERY)
[NOTE: TABLES to be used - ORDER_ITEMS, PRODUCT, ORDER_HEADER, ONLINE_CUSTOMER, ADDRESS]*/

## Answer 9.

SELECT oi.PRODUCT_ID, p.PRODUCT_DESC, SUM(oi.PRODUCT_QUANTITY) as tot_qty
FROM ORDER_ITEMS AS oi
JOIN PRODUCT AS p ON oi.PRODUCT_ID = p.PRODUCT_ID
JOIN ORDER_HEADER AS oh ON oi.ORDER_ID = oh.ORDER_ID
JOIN ONLINE_CUSTOMER AS oc ON oh.CUSTOMER_ID = oc.CUSTOMER_ID
JOIN ADDRESS AS a ON oc.ADDRESS_ID = a.ADDRESS_ID
WHERE oi.PRODUCT_ID != 201
AND oi.ORDER_ID IN (
  SELECT oi2.ORDER_ID
  FROM ORDER_ITEMS AS oi2
  WHERE oi2.PRODUCT_ID = 201
)
AND a.CITY NOT IN ('Bangalore', 'New Delhi')
GROUP BY oi.PRODUCT_ID, p.PRODUCT_DESC
ORDER BY tot_qty DESC
limit 6;

/*Explanation of the code:
1)Joining Tables: The query starts by joining multiple tables such as ORDER_ITEMS, PRODUCT, ORDER_HEADER, ONLINE_CUSTOMER, and ADDRESS using JOIN clauses.
2)Filtering Data: After joining tables, a WHERE clause is used to filter the data. The data is filtered based on the conditions - only those products are selected whose product_id is not 201 and those are only sold with product_id 201, and which are not shipped to Bangalore and New Delhi cities.
3)Grouping and Sorting Data: The query uses a GROUP BY clause to group the data based on product_id and product_desc, and then uses SUM function to calculate the total quantity of each product. Finally, the data is sorted in descending order of tot_qty.

/* Q10. Write a query to display the order_id, customer_id and customer fullname,
 total quantity of products shipped for order ids which are even and shipped to
 address where pincode is not starting with "5" 
Expected 15 rows in final output
[NOTE: TABLES to be used - ONLINE_CUSTOMER, ORDER_HEADER, ORDER_ITEMS, ADDRESS] */

## Answer 10.

SELECT oh.ORDER_ID, oh.CUSTOMER_ID,
concat(oc.CUSTOMER_FNAME, ' ', oc.CUSTOMER_LNAME) AS FULL_NAME,
SUM(oi.PRODUCT_QUANTITY) as total_quantity
FROM ORDER_HEADER AS oh
JOIN ONLINE_CUSTOMER AS oc ON oh.CUSTOMER_ID = oc.CUSTOMER_ID
JOIN ORDER_ITEMS AS oi ON oh.ORDER_ID = oi.ORDER_ID
JOIN ADDRESS AS a ON oc.ADDRESS_ID = a.ADDRESS_ID
WHERE oh.ORDER_ID % 2 = 0
AND a.PINCODE NOT LIKE '5%'
GROUP BY oh.ORDER_ID, oh.CUSTOMER_ID, FULL_NAME 
ORDER BY oh.ORDER_ID desc
limit 15;

/*Explanation of the code:
1)Retrieval of information from multiple tables: The query retrieves information from the ORDER_HEADER, ONLINE_CUSTOMER, ORDER_ITEMS, and ADDRESS tables. The JOIN clause is used to link the data from these tables based on the common columns: oh.CUSTOMER_ID = oc.CUSTOMER_ID, oh.ORDER_ID = oi.ORDER_ID and oc.ADDRESS_ID = a.ADDRESS_ID.
2)Filtering the result set: The WHERE clause specifies the conditions to filter the result set. The query selects only the orders where the order ID is even (oh.ORDER_ID % 2 = 0) and the pincode in the address table does not start with 5 (a.PINCODE NOT LIKE '5%').
3)Modifying and aggregating the result set: The query uses the concat function to concatenate the customer's first name and last name and assign it to the FULL_NAME column. The SUM function is used to calculate the total product quantity per order, and the GROUP BY clause groups the result by the order ID, customer ID, and full name. Finally, the ORDER BY clause sorts the result set by the order ID in descending order, and the LIMIT clause restricts the result set to 15 rows.
*/