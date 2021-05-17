-- insert.sql

-- generating users (table "user")

insert into "user" (id, username_nm, first_nm, second_nm)
values (1, 'fivol61', 'Boris', 'Bondarenko');
insert into "user" (id, username_nm, first_nm, second_nm)
values (2, 'neafiol', 'Petr', 'Volnov');
insert into "user" (id, username_nm, first_nm)
values (3, 'alexxx', 'Александр');
insert into "user" (id, username_nm, second_nm)
values (4, 'vladistlove', 'Сажин');
insert into "user" (id)
values (5);
insert into "user" (id, username_nm)
values (6, 'kek');
insert into "user" (id, username_nm)
values (7, 'ubil_deda_ne_problema');
insert into "user" (id, first_nm)
values (8, 'Who am I?');
insert into "user" (id, second_nm)
values (9, 'God');
insert into "user" (id, username_nm, first_nm)
values (10, '___', 'Slave');

insert into "user" (id, username_nm)
    (select generate_series, 'fake_user_' || generate_series::varchar from generate_series(50, 60));

select *
from "user";


-- generate values for table "room"

insert into room (name_nm, private_flg, user_id)
values ('Фотки', false, 1);
insert into room (key_value, private_flg, user_id)
values ('Club', true, 1);
insert into room (name_nm, private_flg, user_id)
values ('Дача', false, 2);
insert into room (name_nm, key_value, private_flg, user_id)
values (null, 'Девченки', true, 3);
insert into room (name_nm, key_value, private_flg, user_id)
values (null, 'Домашнее', true, 3);
insert into room (name_nm, key_value, private_flg, user_id)
values ('Test11', null, false, 3);
insert into room (name_nm, key_value, private_flg, user_id)
values ('Что такое комната?', null, false, 5);
insert into room (key_value, private_flg, user_id)
values ('Videos', true, 7);
insert into room (key_value, private_flg, user_id)
values ('One day', true, 4);
insert into room (name_nm, private_flg, user_id)
values ('Девушка', false, 2);
insert into room (key_value, private_flg, user_id)
values ('Home videos', true, 2);
insert into room (key_value, private_flg, user_id)
values ('Друг кек', true, 2);

insert into room (name_nm, private_flg, user_id)
    (select substr(gen_random_uuid()::varchar, 1, 5), false, round((50 + random() * 10)) from generate_series(1, 15));

insert into room (name_nm, private_flg, user_id)
    (select substr(gen_random_uuid()::varchar, 1, 3), false, round((4 + random() * 9)) from generate_series(1, 5));

select *
from room;

-- generating data for table "content"
delete
from content;
-- Создаем 1000 строк контента на основе рандома, заполняем
-- разные type_value и соответствующие им поля file_id_value и txt
insert into content(room_id, type_value, file_id_value, txt)
    (select (select id + length(content_type.type_value) * 0 from room order by random() limit 1),
            content_type.type_value,
            (case
                 when content_type.type_value in ('photo', 'video', 'voice')
                     then gen_random_uuid()::varchar || '___file_id'
                end),
            (case
                 when type_value = 'text'
                     then gen_random_uuid()::varchar || '___message_text'
                end)
     from (select (case
                       when random() > 0.8 then 'photo'
                       when random() > 0.6 then 'video'
                       when random() > 0.4 then 'text'
                       else 'voice'
         end) as type_value
           from generate_series(1, 1000)) content_type);

select *
from content;

-- generating data for table "message"

-- 10000 сообщений для различных пользователей, иногда соотносящихся определенному контенту (вероятность 0.1)
-- со случайным содержимым
delete from message;
with random_user (series, id) as (
    select generate_series, (select id + generate_series * 0 from "user" order by random() limit 1)
    from generate_series(1, 10000)
),
     random_user_content (id, user_id) as (
         select c.id, random_user.id as user_id
         from content c
                  join room r on c.room_id = r.id
                  join random_user on random_user.id = r.user_id
     )
insert
into message(id, content_id, txt, user_id)
    (select u.series, u.content_id, gen_random_uuid()::varchar || '___message_txt', u.id
     from (select random_user.series as series,
                  random_user.id     as id,
                  case when random() < 0.1 then (select random_user_content.id
                   from random_user_content
                   where random_user_content.user_id = random_user.id
                   order by random()
                   limit 1) end as content_id
           from random_user) u
    );

select * from message;