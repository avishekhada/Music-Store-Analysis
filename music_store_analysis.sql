
create database music_store_analysis;





--1. Who is the senior most employee based on job title?
select top(1)  first_name,last_name, title,levels
from employee
order by levels desc;


--2. Which countries have the most Invoices?
select count(*) as c ,billing_country as country
from invoice
group by billing_country
order by c;

--3. What are top 3 values of total invoice?
select top(3) total as total_invoice,billing_country as country
from invoice
order by total_invoice;


--4.Which city has the best customers? We would like to throw a promotional Music 
--Festival in the city we made the most money. Write a query that returns one city that 
--has the highest sum of invoice totals. Return both the city name & sum of all invoice  totals
select top(1) billing_city as city,sum(total) as total_invoice
from invoice
group by billing_city
order by  total_invoice desc;



--5. Who is the best customer? The customer who has spent the most money will be 
--declared the best customer. Write a query that returns the person who has spent the 
--most money

select top(1) c.first_name,c.last_name,sum(inv.total) as total from customer c 
inner join invoice inv on  inv.customer_id=c.customer_id
group by  c.first_name,c.last_name
order  by total desc;



--6.Write query to return the email, first name, last name, & Genre of all Rock Music 
--listeners. Return your list ordered alphabetically by email starting with A
select c.first_name,c.last_name,c.email,g.name
from customer c
inner join invoice inv on inv.customer_id=c.customer_id
inner join invoice_line inl on inl.invoice_id=inv.invoice_id
inner join track tk on tk.track_id=inl.track_id
inner join genre g  on g.genre_id=tk.genre_id
where g.name like 'Rock'
group by c.first_name,c.last_name,c.email,g.name;

or 

select distinct c.first_name,c.last_name,c.email
from customer c
inner join invoice inv on inv.customer_id=c.customer_id
inner join invoice_line inl on inl.invoice_id=inv.invoice_id
where track_id in 
(
 select track_id from track 
 inner join genre  on genre.genre_id=track.genre_id
 where genre.name like 'Rock'
 )
 order by c.email;



-- 7. Let's invite the artists who have written the most rock music in our dataset. Write a 
--query that returns the Artist name and total track count of the top 10 rock bands

 select top(10) at.artist_id, at.name ,count(at.artist_id) as total_song from artist at
 inner join album ab on ab.artist_id =at.artist_id
 inner join track tk on tk.album_id=ab.album_id
 inner join genre g on g.genre_id=tk.genre_id
 where g.name like 'rock'
 group by at.artist_id, at.name
 order by total_song desc;




 --8. Return all the track names that have a song length longer than the average song length. 
--Return the Name and Milliseconds for each track. Order by the song length with the 
--longest songs listed first

 select name,milliseconds  from track 
 where milliseconds>(
 select avg(milliseconds) from track
 )
 order by milliseconds desc;


-- 9.Find how much amount spent by each customer on artists? Write a query to return
--customer name, artist name and total spent

select   c.customer_id, c.first_name,c.last_name ,at.name,sum(inl.unit_price*inl.quantity)  as total from customer c
inner join invoice inv on inv.customer_id=c.customer_id
inner join invoice_line inl on inl.invoice_id=inv.invoice_id
inner join track tk on tk.track_id=inl.track_id
inner join album ab on ab.album_id=tk.album_id
inner join artist at on at.artist_id=ab.artist_id
group by  c.customer_id c.first_name,c.last_name ,at.name
order by total desc;

--or

with cte_table as (
select  at.artist_id ,at.name,sum(inl.unit_price*inl.quantity) as total_sales
from artist at
inner join album ab on ab.artist_id=at.artist_id
inner join track tk on tk.album_id=ab.album_id
inner join invoice_line inl on inl.track_id =tk.track_id
  group by at.artist_id ,at.name
  
)
select c.customer_id,c.first_name,c.last_name,cte.name,sum(inl.unit_price*inl.quantity) as total_sales

from customer c
inner join invoice inv on inv.customer_id=c.customer_id
inner join invoice_line inl on inl.invoice_id=inv.invoice_id
inner join track tk on tk.track_id=inl.track_id
inner join album ab on ab.album_id=tk.album_id
inner join cte_table cte on cte.artist_id=ab.artist_id
group by c.customer_id,c.first_name,c.last_name,cte.name
order by total_sales desc



--10.We want to find out the most popular music Genre for each country. We determine the 
--most popular genre as the genre with the highest amount of purchases. Write a query 
--that returns each country along with the top Genre. For countries where the maximum 
--number of purchases is shared return all Genres


with cte_tab as(
select g.genre_id,g.name,count(inl.quantity)as total_sales,inv.billing_country as country
from genre g
inner join track tk on  g.genre_id=tk.genre_id
inner join invoice_line  inl on inl.track_id=tk.track_id
inner join invoice inv on inv.invoice_id =inl.invoice_id
group by  g.genre_id,g.name,inv.billing_country

)
select * from  cte_tab