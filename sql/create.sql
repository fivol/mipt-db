create database mipt_db;

-- Будем хранить все таблици в схеме bot
create schema bot;
set search_path to bot, public;


create table "user"
(
    id               bigint    not null primary key,
    username_nm      varchar(256),
    first_nm         varchar(256),
    second_nm        varchar(256),
    create_dttm      timestamp not null default now(),
    last_active_dttm timestamp not null default now()
);

create table if not exists room
(
    id          serial primary key not null,
    name_nm     varchar(256),
    key_value   varchar(256),
    private_flg boolean            not null,
    user_id     bigint             not null references "user" (id),
    create_dttm timestamp          not null default now(),
    check ( case
                when private_flg then key_value is not null
                when private_flg = false then name_nm is not null end )
);

create table if not exists content
(
    id            serial primary key not null,
    room_id       integer references room (id),
    type_value    varchar(32)        not null,
    file_id_value varchar,
    txt   text,
    create_dttm   timestamp          not null default now(),
    check ( file_id_value is not null or txt is not null )
);

create table if not exists message
(
    id         bigint    not null primary key,
    content_id integer references content (id),
    txt       text,
    user_id    bigint references "user" (id),
    create_dttm  timestamp not null default now()
);
