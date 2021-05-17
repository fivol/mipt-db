-- queries.sql

-- Среднее количество комнат, созданных пользователем
select avg(counts.count)
from (select count(*) as count
      from "user" u
               join room r on u.id = r.user_id
      group by u.id) counts;

-- Максимальное, минимальное, среднее количество содержимого в одной комнате
select max(room_contents.count), min(room_contents.count), avg(room_contents.count)
from (select count(*)
      from content
      group by room_id
     ) room_contents;

-- Сколько фотографий загружено в систему
select count(*)
from content
where content.type_value = 'photo';

-- Вывести ники пользователей и количество загруженного ими материала, или оно больше 100
select u.id, u.username_nm, count(*) as content_count
from "user" u
         left join room r on u.id = r.user_id
         join content c on r.id = c.room_id
group by u.id
having count(*) > 100;

-- Сводная таблица по пользователям и типу комнаты (публичная или приватная) сколько контента туда загружено
-- отсортированная в порядке убывания количества контента
with user_content(id, username_nm, private_flg, count) as (
    select u.id, u.username_nm, r.private_flg, count(*)
    from "user" u
             left join room r on u.id = r.user_id
             left join content c on r.id = c.room_id
    group by u.id, u.username_nm, r.private_flg
), result as (
select id, '@' || username_nm, (
    select count from user_content
    where id = u.id and private_flg = false
    ) as private, (
    select count from user_content
    where id = u.id and private_flg = true
    )  as public
from (select distinct * from "user") u)
select * from result order by coalesce(private, 0) + coalesce(public, 0) desc ;

