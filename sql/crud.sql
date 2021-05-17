-- crud.sql

-- CRUD with room table

-- CREATE room
insert into room (name_nm, key_value, private_flg, user_id)
values ('Поход', null, false, 1);

-- READ rooms
select * from room r where private_flg = false and user_id = 1;

-- UPDATE room row
update room
set name_nm = 'Лыжный поход'
where id = 49;

-- DELETE row from room
delete
from room where id = 49;


-- CRUD with message table

-- CREATE message
insert into message (id, content_id, txt, user_id)
values (123022, null, '/help', 1);

-- READ message from user 1
select * from message m join "user" u on m.user_id = u.id where u.id = 1 order by m.create_dttm desc limit 10;

-- UPDATE message row
update message
set txt = 'Помогите мне пожалуйста, ничего не понимаю'
where id = 123022;

-- DELETE row from message
delete
from message where id = 123022;