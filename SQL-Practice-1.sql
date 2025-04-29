--Create the schema which defines the logical structure of data
create schema assignment;
set search_path to assignment;

--Creating the table named customers
create table customers (
customer_id SERIAL primary key,
first_name varchar(50) not null,
last_name varchar(50) not null,
email varchar(100) not null,
phone_number char(13) unique not null,
city varchar(50)
);

insert into customers (first_name,last_name,email,phone_number,city)
values
('John', 'Doe', 'john.doe@gmail.com', '+254711223344', 'Nairobi'),
('Jane', 'Smith', 'jane.smith@gmail.com', '+254798678734', 'Mombasa'),
('Paul', 'Otieno','paul.otieno@gmail.com','+254798431245', 'Kisumu'),
('Mary', 'Okello', 'mary.okello@gmail.com','+254798563908', 'Nairobi');

select * from customers;

create table books (
book_id SERIAL primary key,
title varchar(50) not null,
author varchar(100) not null,
price numeric (8,2),
published_date DATE
);

insert into books (title, author,price,published_date)
values
('Understanding SQL', 'David Kimani', 1500.00, '2023-01-15'),
('Advanced PostgreSQL', 'Grace Achieng', 2500.00, '2023-02-20'),
('Learning Python', 'James Mwangi', 3000.00, '2022-11-10'),
('Data Anlytics Basics', 'Susan Njeri', 2200.00, '2023-02-05');

select * from books;

create table orders (
order_id SERIAL primary key,
customer_id INT references customers(customer_id),
book_id INT references books(book_id),
order_date DATE default CURRENT_DATE
);


insert into orders(customer_id, book_id, order_date)
values
(1,3, '2023-04-01'),  --John ordered Learning Python
(2,1, '2023-04-02'),  --Jane ordered Understanding sql
(3,2, '2023-04-03'),  --Paul ordered Advanced PostgreSQL
(4,4, '2023-04-04');  --Mary ordered data Analytics Basics


select * from orders;

alter table orders 
add column quantity int;

update orders
set quantity = case order_id
when 1 then 2
when 2 then 1
when 3 then 3
when 4 then 2
end;

--ASSIGNMENT QUESTIONS
--QUIZ 1. 
--List all customers with their full name and city

select concat(first_name, ' ', last_name) as full_name, city
from customers;

--QUIZ 2 
--Show all books priced above 2000

select* from books
where price > 2000;

--QUIZ 3
--List customers who live in Nairobi

select * from customers
where city = 'Nairobi';

--QUIZ 4
--Retrieve all book titles that were published in 2023

select title from books
where published_date > '2023-01-01';

--FILTERING AND SORTING
--QUIZ 5
--Show all orders placed after March 1st 2025

select * from orders
where order_date > '2025-03-1'; --We have no orders for 2025

--QUIZ 6
--list all books ordered, sorted by price (descending)

select orders.order_id, books.title, books.price
from books
inner join orders on books.book_id = orders.book_id
order by price desc;

--QUIZ 7
--Show all customers whose name start with 'J'
select * from customers
where first_name like 'J%';

--QUIZ 8
--List books with prices between 1500 and 3000
select * from books
where price between 1500 and 3000;

--AGGREGATE FUNCTIONS AND GROUPING
--QUIZ 9
--Count the number of customers in each city
select city, count(*) as number_of_customer
from customers
group by city;

--quiz 10
--Show the total number of orders per customer

select customer_id, count(customer_id) as total_order
from orders
group by customer_id;

--QUIZ 11
--Find the average price of books in the store.

select avg(price) as avg_price
from books;

--QUIZ 12
--List the book title and total quantity ordered for each book.
select books.title, sum(orders.quantity) as quantity_ordered
from books
left join orders on books.book_id = orders.book_id
group by books.title;

--QUIZ 13
--Show customers who have placed more orders than customer with ID = 1.
select customer_id, count(*) as customer_orders
from orders
group by customer_id
having count(*) > (select count(*) 
from orders
where customer_id = 1);

--QUIZ 14
--List books that are more expensive than the average book price.
select title
from books
where price > (select avg(price) from books);

--QUIZ 15
--Show each customer and the number of orders they placed using a subquery in SELECT.
select c.customer_id, c.first_name, (
        select count(*) 
        FROM orders o 
        WHERE o.customer_id = c.customer_id
    ) "total_orders"
from customers c;

--QUIZ 16
--Show full name of each customer and the titles of books they ordered
select c.first_name, c.last_name, b.title
from customers c
left join orders o on c.customer_id = o.customer_id
left join books b on o.book_id = b.book_id;

--QUIZ 17
--List all orders including book title, quantity, and total cost (price × quantity)
select books.title, orders.quantity, books.price * orders.quantity as Total_cost
from books
join orders on books.book_id = orders.book_id;

--QUIZ 18
-- Show customers who haven't placed any orders (LEFT JOIN).
select customers.first_name, customers.last_name, orders.order_id
from customers
left join orders on customers.customer_id = orders.customer_id
where order_id isnull;

--QUIZ 19
--List all books and the names of customers who ordered them, if any (LEFT JOIN)
select books.title, customers.first_name, customers.last_name
from orders
left join books on orders.book_id = books.book_id
left join customers on orders.customer_id = customers.customer_id;

--QUIZ 20
--Show customers who live in the same city (SELF JOIN).
select a.first_name, a.last_name, b.city
from customers a
join customers b on a.city = b.city
where a.customer_id <> b.customer_id;

--COMBINED LOGIC
--QUIZ 21
--Show all customers who placed more than 2 orders for books priced over 2000
select c.customer_id, c.first_name, c.last_name,  count(*) "Order > 2"
from customers c
join orders o on c.customer_id = o.customer_id
join books b on o.book_id = b.book_id
where b.price > 2000
group by c.customer_id, c.first_name, c.last_name
having count(*) > 2;

--QUIZ 21
--List customers who ordered the same book more than once
select distinct books.title,
	o.customer_id,
	c.first_name,
	count(o.book_id) as total_order
from customers c 
inner join orders o 
using(customer_id)
inner join books
using(book_id)
group by o.customer_id, c.first_name,books.title
having count(o.book_id) > 1;

--QUIZ 22 
--List customers who ordered the same book more than once.
select distinct books.title,
orders.customer_id,
customers.first_name,
count(orders.book_id) as totalorder_
from customers 
inner join orders 
using(customer_id)
inner join books 
using(book_id)
group by orders.customer_id, customers.first_name, books.title
having count(orders.book_id) > 1;

--QUIZ 23 
--Show each customer's full name, total quantity of books ordered, and total amount spent.
select concat(customers.first_name, ' ', customers.last_name) as Names, sum(orders.quantity) as totalqantity,
books.price * orders.quantity as Totalamount
from orders
join books on orders.book_id = books.book_id
join customers on customers.customer_id = orders.customer_id
group by customers.first_name, customers.last_name, books.price, orders.quantity;
 
--24. List books that have never been ordered.
select books.title, orders.order_id
from books
left join orders on books.book_id = orders.book_id
where order_id isnull;
 
--25. Find the customer who has spent the most in total (JOIN + GROUP BY + ORDER BY +LIMIT).
select concat(customers.first_name, ' ', customers.last_name) as Names, sum(orders.quantity * books.price) as totalcost
from orders
join books on orders.book_id = books.book_id
join customers on customers.customer_id = orders.customer_id
group by customers.first_name, customers.last_name
order by sum(orders.quantity * books.price) desc
limit 1;
 
---26. Write a query that shows, for each book, the number of different customers who have ordered it.
select books.title, count(customers.customer_id) as Number_of_customers
from orders
left join books on books.book_id = orders.book_id
left join customers on customers.customer_id = orders.customer_id
group by books.title;
 
---27. Using a subquery, list books whose total order quantity is above the average order quantity.
SELECT
b.book_id,
b.title
FROM
books b
JOIN (
SELECT
book_id,
SUM(quantity) AS total_quantity
FROM
orders
GROUP BY
book_id
HAVING SUM(quantity) > (
SELECT AVG(quantity) FROM orders
)
) o ON b.book_id = o.book_id;

---28. Show the top 3 customers with the highest number of orders and the total amount theyspent.
select concat(customers.first_name, ' ', customers.last_name) as Names, sum(orders.quantity *books.price) as totalamount_spent, count(orders.book_id)
from orders
join books on orders.book_id = books.book_id
join customers on customers.customer_id = orders.customer_id
group by customers.first_name, customers.last_name
order by sum(orders.quantity * books.price) desc
limit 3;




















