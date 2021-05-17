-- procedure.sql

-- Добавление сообщение (нужно для дебага и разработки) напряму через бд (не зная реальный id от телеграма)
CREATE PROCEDURE add_message(user_id integer, text text)
LANGUAGE SQL
AS $$
    insert into message(id, content_id, txt, user_id)
    values ((select max(id) from message) + 10, null, text, user_id)
$$;

CALL add_message(1, 'Hello world');
select * from message where user_id = 1 order by create_dttm desc;