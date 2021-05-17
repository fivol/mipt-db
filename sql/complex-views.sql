-- complex-views.sql

-- Публичный контент каждого пользователя
create or replace view user_public_content as
select u.id, u.nm, c.type_value, substr(c.txt, 0, 10) || '...' as txt
from user_view u
         join room r on u.id = r.user_id
         join content c on r.id = c.room_id
where r.private_flg = false;

select *
from user_public_content;

-- Контент, который в данный момент отображается в чате, то есть является сообщением
create view representing_content as
    select u.id, u.nm, c.type_value, m.create_ago
from content c
         join message_view m on c.id = m.content_id
         join user_view u on m.user_id = u.id;

select * from representing_content;