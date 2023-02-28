create database football;
create table coaches
(id int primary key auto_increment,
first_name varchar (10) not null,
last_name varchar (20) not null,
salary Decimal (10,2) default (0) not null,
coach_level int default (0) not null
);

create table countries
(id int primary key auto_increment,
name varchar (45) not null
);

create table towns
(id int primary key auto_increment,
name varchar (45) not null,
country_id INT not null,
constraint fk_towns_countries
foreign key (country_id)
references countries (id)
);

create table stadiums
(id int primary key auto_increment,
name varchar (45) not null,
capacity int not null,
town_id INT not null,
constraint fk_stadiums_towns
foreign key (town_id)
references towns (id)
);

create table teams(
id int primary key auto_increment,
name varchar(45) not null,
established date not null,
fan_base bigint default (0) not null,
stadium_id int not null,
constraint fk_teams_stadiums
foreign key (stadium_id)
references stadiums (id)
);

create table skills_data (
id int primary key auto_increment,
dribbling int default(0), 
pace int default(0), 
passing int default(0), 
shooting int default(0), 
speed int default(0), 
strength int default(0)
);

create table players(
id int primary key auto_increment,
first_name varchar(10) not null,
last_name varchar(20) not null,
age int default(0) not null,
position Char(1) not null,
salary decimal (10,2) default (0) not null,
hire_date datetime,
skills_data_id int not null,
team_id int,
constraint fk_players_skd
foreign key (skills_data_id)
references skills_data (id),
constraint fk_players_teams
foreign key (team_id)
references teams(id));

create table players_coaches (
player_id int,
coach_id int,
constraint 
primary key (player_id, coach_id),
constraint
foreign key (player_id)
references players(id),
constraint
foreign key (coach_id)
references coaches (id)
);

-----------------------------------------------
insert into coaches 
(first_name, last_name, salary, coach_level)
select p.first_name, p.last_name,
( select p.salary=p.salary*2),
char_length(p.first_name)
from players as p
where p.age >= 45;
-----------------------------------------------
update coaches as c
join players_coaches as pc
on c.id=pc.coach_id
join players as p
on p.id=pc.player_id
set c.coach_level = c.coach_level + '1'
where c.first_name like 'a%' and
( select count(pc1.coach_id)
from players_coaches as pc1
where pc1.coach_id=pc.coach_id
group by pc1.coach_id
having count(pc1.coach_id)=>1);

select c.first_name, count(pc1.coach_id)
from players_coaches as pc1
join coaches as c
on pc1.coach_id=c.id
group by pc1.coach_id
having count(pc1.coach_id)>1;
----------------------------------------
delete from players
where age >= 45;

select * from coaches;

--------------------------------------------

select first_name, age, salary from players
order by salary desc;

------------------------------------------
select p.id, concat(p.first_name, ' ', p.last_name),
p.age, p.position, p.hire_date
from players as p
join skills_data as sd
on p.skills_data_id = sd.id
where hire_date is NULL
and sd.strength > 50
and p.position in ('A')
order by salary, age;

----------------------------------------
select t.name, t.established, t.fan_base, 
count(p.id) as players_cout
from teams as t
join players as p
on t.id=p.team_id
group by t.name
order by count(p.id) desc, fan_base desc; 

--------------------------------------------
select max(sd.speed), tow.name
from skills_data as sd
right join players as p
on sd.id = p.skills_data_id
right join teams as t
on t.id=p.team_id
right join stadiums as s
on s.id=t.stadium_id
right join towns as tow
on tow.id = s.town_id
where t.name != 'Devify'
group by tow.id
order by max(sd.speed) desc, t.name;
----------------------------
select c.name, count(p.id), sum(p.salary)
from players as p
right join teams as t
on t.id=p.team_id
right join stadiums as s
on s.id=t.stadium_id
right join towns as tow
on tow.id = s.town_id
right join countries as c
on c.id=tow.country_id
group by c.name
order by count(p.id) desc, c.name;
----------------------------------------------
delimiter %%
create function udf_stadium_players_count 
(stadium_name VARCHAR(30)) 
returns int 
deterministic
begin
return (
select count(p.id) from players as p
join teams as t
on t.id=p.team_id
join stadiums as s
on s.id=t.stadium_id
where s.name=stadium_name
) ;
end
%%
delimiter ;
SELECT udf_stadium_players_count ('Jaxworks') as `count`; 
-------------------------------
delimiter %%
create procedure udp_find_playmaker 
(min_dribble_points INT,
team_name VARCHAR (45))
begin
select concat(p.first_name, ' ', p.last_name) as 'full_name',
p.age, p.salary,
sd.dribbling, sd.speed, t.name
from skills_data as sd
join players as p
on sd.id=p.skills_data_id
join teams as t
on t.id=p.team_id
where t.name=team_name and
sd.dribbling > min_dribble_points
and sd.speed> (select avg(sd.speed) from skills_data)
order by sd.speed desc
limit 1;
end
%%

delimiter;
drop udp_find_playmaker;

delimiter ;
CALL udp_find_playmaker (20, 'Skyble');