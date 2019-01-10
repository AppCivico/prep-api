-- Deploy prep_api:0000-appschema to pg

BEGIN;

CREATE TABLE "user"
(
    id                 SERIAL PRIMARY KEY,
    fb_id              TEXT,
    name               TEXT,
    picture            TEXT,
    email              TEXT NOT NULL UNIQUE,
    password           TEXT NOT NULL,
    email_confirmed    BOOLEAN NOT NULL DEFAULT false,
    email_confirmed_at TIMESTAMP WITHOUT TIME ZONE,
    updated_at         TIMESTAMP WITHOUT TIME ZONE,
    created_at         TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT now()
);

CREATE TABLE chatbot_session (
    user_id            INTEGER PRIMARY KEY REFERENCES "user"(id),
    session_content    JSON NOT NULL,
    session_updated_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE TABLE user_session
(
  id           serial primary key,
  user_id      integer not null references "user"(id),
  api_key      text not null unique,
  created_at   timestamp without time zone not null default now(),
  valid_until  timestamp without time zone not null
);

CREATE TABLE role (
    id   INTEGER PRIMARY KEY,
    name TEXT    NOT NULL UNIQUE
);

INSERT INTO role VALUES (1, 'super_admin');
INSERT INTO role VALUES (2, 'admin');
INSERT INTO role VALUES (3, 'recipient');

CREATE TABLE user_role (
    user_id integer references "user"(id),
    role_id integer references role(id),
    CONSTRAINT user_role_pkey PRIMARY KEY (user_id, role_id)
);

INSERT INTO "user" (password, email, email_confirmed, email_confirmed_at) VALUES ('$2y$10$O4iFv47vPptdx1NdDWXjn.8DQeP.XMSui.e7m3ex391.rNoIYbIgu', 'lucas.ansei@appcivico.com', true, now());
INSERT INTO user_role (role_id, user_id) VALUES (1, 1);

COMMIT;
