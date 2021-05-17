-- views.sql

select *
from "user";

drop view user_view;
-- view для таблицы "user"
create or replace view user_view as
select id,
       coalesce('@' || username_nm || ' ', '') || coalesce(first_nm || ' ', '') ||
       coalesce("user".second_nm || ' ', '') as nm,
       now() - create_dttm                   as authorized_ago
from "user";

select *
from user_view;

-- view для таблицы room
drop view room_view;
create view room_view
as
select id,
       name_nm,
       repeat('*', length(key_value))                         as key_value,
       case when private_flg then 'private' else 'public' end as status,
       user_id,
       now() - create_dttm                                    as create_ago
from room;

select *
from room_view;

-- view для таблицы message
create view message_view as
select id,
       content_id,
       user_id,
       case when txt is not null then substr(txt, 0, 12) || '...' end as txt,
       now() - create_dttm                                            as create_ago
from message;

select *
from message_view;

-- view для таблицы content

create view content_view as
select id, room_id, type_value, now() - create_dttm as create_ago
from content;
select *
from content_view;