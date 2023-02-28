create database instd;
Create table users (
id INT primary key auto_increment,
username Varchar(30) NOT NULL,
password Varchar(30) NOT NULL,
email Varchar(50) NOT NUll,
gender Char(1) Not NULL,
age INT NOT NULL,
job_title Varchar(40) NOT NULL,
ip Varchar(30) Not NULL);

Create table addresses (
id INT primary key auto_increment,
address Varchar(30) NOT NULL,
town Varchar(30) NOT NULL,
country Varchar(30) NOT NUll,
user_id INT Not null,
constraint fk_addresses_users
foreign key (user_id)
references users (id) );

Create table photos (
id INT primary key auto_increment,
`description` TEXT NOT NULL,
`date` datetime Not null,
views INT NOT NULL default 0
);

Create table comments (
id INT primary key auto_increment,
`comment` Varchar(255) NOT NULL,
`date` datetime NOT NULL,
photo_id INT not null,
constraint fk_comments_photos
foreign key (photo_id)
references photos (id));

Create table users_photos (
user_id INT not null,
photo_id int not null,
constraint fk_up_photos
foreign key (photo_id)
references photos(id),
constraint fk_up_users
foreign key (user_id)
references users(id)
);

Create table likes (
id INT primary key auto_increment,
photo_id int,
user_id int,
constraint fk_likes_photos
foreign key (photo_id)
references photos(id),
constraint fk_likes_users
foreign key (user_id)
references users(id)
);
----------------------------------------------
select * from addresses;

-----------------------------
Insert into addresses (address, town, country, user_id)
select username, password, ip, age from users
where gender = 'M';

-------------------------
UPDATE addresses 
set country = (case 
when left(country,1) ='B' then 'Blocked'
when left(country,1) = 'T' then 'Test'
when left(country,1) = 'P' then 'In Progress'
else `country`
end);

----------------------------------
delete from addresses
where id%3=0;

---------------------------------
select username, gender, age from users
order by age desc, username asc;

---------------------------------------
select p.id, p.date as 'date_and_time', 
p.description,  count(c.id) as 'commentsCount'
from photos as p
join comments as c
on p.id=c.photo_id
group by p.id
order by count(c.id) desc, p.id asc
limit 5;

-------------------------------
select concat(u.id, ' ', u.username), u.email 
from users as u
join users_photos as up
on u.id = up.user_id
join photos as p
on up.photo_id = p.id
where up.user_id=up.photo_id;
select * from likes;
----------------------------------
select p.id as photo_id, 
count(distinct l.id) as likes_count, 
count(distinct c.id) as comments_count 
from photos as p
left join likes as l
on p.id=l.photo_id
left join comments as c
on p.id=c.photo_id
group by p.id
order by likes_count  desc, comments_count desc, p.id asc;
---------------------------------

select concat(left(`description`, 30), '...') as summary,
`date` from photos
where (day(`date`))=10
order by `date` desc;

--------------------------------
delimiter %%
create function udf_users_photos_count
(username VARCHAR(30)) 
returns int
deterministic
begin
return
(select Count(usp.photo_id) from users_photos as usp
join users as u
on usp.user_id=u.id
where u.username=username
group by usp.user_id
);
end
%%

select udf_users_photos_count ('ssantryd') as 'count';

---------------------------------------
delimeter %%
create procedure uudp_modify_user (address VARCHAR(30),
town VARCHAR(30))
begin
select u.username, u.email, 
u.gender, u.age, u.job_title from users as u
join addresses as a
on a.user_id=u.id
where a.address=address and a.town=town;
Update users as u
set age = age+10
where u.id > 0;
end
%%


CALL uudp_modify_user ('97 Valley Edge Parkway',
'Divinópolis');
SELECT u.username, u.email,u.gender,u.age,u.job_title
FROM users AS u
WHERE u.username = 'eblagden21';



