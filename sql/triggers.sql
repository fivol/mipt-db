-- triggers.sql

-- Будем сохранять удаленный пользователем контент в отдельную таблицу (вроде карзины или архива)
-- для возможности восстановления
drop table if exists deleted_content;
create table if not exists deleted_content
(
    LIKE content INCLUDING ALL
);
alter table deleted_content
    add column delete_dttm timestamp default now();

create or replace function save_deleted_content()
    returns trigger as
$$
begin
    execute 'insert into deleted_content (room_id, type_value, file_id_value, txt, create_dttm, id) ' ||
            'values ($1, $2, $3, $4, $5, $6)'
        using old.room_id, old.type_value, old.file_id_value, old.txt, old.create_dttm, old.id;
    return new;
end;
$$ language plpgsql;

drop trigger if exists deleted_content_save_trigger on content;
create trigger deleted_content_save_trigger
    after delete
    on content
    for each row
execute procedure save_deleted_content();

delete
from deleted_content
where id = 22222;

insert into content(id, room_id, type_value, file_id_value, txt)
values (22222, 1, 'text', null, 'TEXT')
on conflict do nothing;

delete
from content
where id = 22222;
select *
from deleted_content;
select *
from content
where id = 22222;

-- Проверка на количество создаваемого, если человек делает больше 10000 единиц
-- (очень большое ограничение) выкидывается ошибка, нужно во избежание заспамливания
-- базы данных. Дублирует проверку на сервере для надежности
create or replace function check_content_amount_function()
    returns trigger as
$$
declare
    user_content_count integer;
begin
    select count(*)
    into user_content_count
    from content c
    where c.room_id = new.room_id;
    assert user_content_count < 10000, 'Too many content in this room: stop spam!';
    return new;
end;
$$ language plpgsql;

drop trigger if exists check_content_amount_trigger on content;
create trigger check_content_amount_trigger
    before insert
    on content
    for each row
execute procedure check_content_amount_function();

-- Создадим комнату для эксперимента
insert into room(id, name_nm, key_value, private_flg, user_id)
VALUES (123123, 'spam_room', null, false, 1)
on conflict do nothing;

-- Проверим что вставка работает
insert into content(room_id, type_value, file_id_value, txt)
values (123123, 'text', null, 'Example');

-- Добавим туда 15000 элементов контента за раз и убедимся что запрос упал
insert into content (room_id, type_value, file_id_value, txt)
    (
        select 123123, 'text', null, 'some text'
        from generate_series(1, 15000)
    );


select count(*)
from content
where room_id = 123123;