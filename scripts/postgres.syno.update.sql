-- Updates from version 0.3.1

DROP INDEX identities_user_id_idx;
CREATE INDEX identities_user_id_idx ON identities (user_id, del);

ALTER TABLE identities ADD changed timestamp with time zone DEFAULT now() NOT NULL;

CREATE SEQUENCE contactgroups_ids
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;
		
CREATE TABLE contactgroups (
    contactgroup_id integer DEFAULT nextval('contactgroups_ids'::text) PRIMARY KEY,
    user_id 	integer		NOT NULL
        REFERENCES users(user_id) ON DELETE CASCADE ON UPDATE CASCADE,
    changed 	timestamp with time zone DEFAULT now() NOT NULL,
    del 	smallint 	NOT NULL DEFAULT 0,
    name 	varchar(128) 	NOT NULL DEFAULT ''
);

CREATE INDEX contactgroups_user_id_idx ON contactgroups (user_id, del);

CREATE TABLE contactgroupmembers (
    contactgroup_id 	integer NOT NULL
	REFERENCES contactgroups(contactgroup_id) ON DELETE CASCADE ON UPDATE CASCADE,
    contact_id 		integer NOT NULL
	REFERENCES contacts(contact_id) ON DELETE CASCADE ON UPDATE CASCADE,
    created timestamp with time zone DEFAULT now() NOT NULL,
    PRIMARY KEY (contactgroup_id, contact_id)
);

-- Updates from version 0.4-beta

ALTER TABLE users ALTER last_login DROP NOT NULL;
ALTER TABLE users ALTER last_login SET DEFAULT NULL;

-- Updates from version 0.4.2

DROP INDEX users_username_id_idx;
ALTER TABLE users ADD CONSTRAINT users_username_key UNIQUE (username, mail_host);
ALTER TABLE contacts ALTER email TYPE varchar(255);

TRUNCATE messages;

-- Updates from version 0.5.1
-- Updates from version 0.5.2
-- Updates from version 0.5.3
-- Updates from version 0.5.4

ALTER TABLE contacts ADD words TEXT NULL;
CREATE INDEX contactgroupmembers_contact_id_idx ON contactgroupmembers (contact_id);

TRUNCATE messages;
TRUNCATE cache;

-- Updates from version 0.6

CREATE TABLE dictionary (
    user_id integer DEFAULT NULL
        REFERENCES users (user_id) ON DELETE CASCADE ON UPDATE CASCADE,
   "language" varchar(5) NOT NULL,
    data text NOT NULL,
    CONSTRAINT dictionary_user_id_language_key UNIQUE (user_id, "language")
);

CREATE SEQUENCE search_ids
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;

CREATE TABLE searches (
    search_id integer DEFAULT nextval('search_ids'::text) PRIMARY KEY,
    user_id integer NOT NULL
        REFERENCES users (user_id) ON DELETE CASCADE ON UPDATE CASCADE,
    "type" smallint DEFAULT 0 NOT NULL,
    name varchar(128) NOT NULL,
    data text NOT NULL,
    CONSTRAINT searches_user_id_key UNIQUE (user_id, "type", name)
);

DROP SEQUENCE message_ids;
DROP TABLE messages;

CREATE TABLE cache_index (
    user_id integer NOT NULL
    	REFERENCES users (user_id) ON DELETE CASCADE ON UPDATE CASCADE,
    mailbox varchar(255) NOT NULL,
    changed timestamp with time zone DEFAULT now() NOT NULL,
    valid smallint NOT NULL DEFAULT 0,
    data text NOT NULL,
    PRIMARY KEY (user_id, mailbox)
);

CREATE INDEX cache_index_changed_idx ON cache_index (changed);

CREATE TABLE cache_thread (
    user_id integer NOT NULL
    	REFERENCES users (user_id) ON DELETE CASCADE ON UPDATE CASCADE,
    mailbox varchar(255) NOT NULL,
    changed timestamp with time zone DEFAULT now() NOT NULL,
    data text NOT NULL,
    PRIMARY KEY (user_id, mailbox)
);

CREATE INDEX cache_thread_changed_idx ON cache_thread (changed);

CREATE TABLE cache_messages (
    user_id integer NOT NULL
    	REFERENCES users (user_id) ON DELETE CASCADE ON UPDATE CASCADE,
    mailbox varchar(255) NOT NULL,
    uid integer NOT NULL,
    changed timestamp with time zone DEFAULT now() NOT NULL,
    data text NOT NULL,
    flags integer NOT NULL DEFAULT 0,
    PRIMARY KEY (user_id, mailbox, uid)
);

CREATE INDEX cache_messages_changed_idx ON cache_messages (changed);

-- Updates from version 0.7-beta

ALTER TABLE "session" ALTER sess_id TYPE varchar(128);

-- Updates from version 0.7

DROP INDEX contacts_user_id_idx;
CREATE INDEX contacts_user_id_idx ON contacts USING btree (user_id, del);
ALTER TABLE contacts ALTER email TYPE text;


-- synology ---
-- RoundCube Webmail update script for Postgres databases
-- Updates from version 0.4.2 for pop3 functions

CREATE TABLE popinfo (
    identity_id integer PRIMARY KEY,
    changed timestamp with time zone DEFAULT now() NOT NULL,
    ext integer DEFAULT 0 NOT NULL,
    extusername varchar(128),
    extpd varchar(128),
    popserver varchar(128),
    popport integer DEFAULT 110 NOT NULL,
    ifssl integer DEFAULT 0 NOT NULL,
    select_folder varchar(128) DEFAULT 'INBOX',
    remove_mail integer DEFAULT 0 NOT NULL,
    select_smtp integer
);

CREATE SEQUENCE smtp_ids
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;

CREATE TABLE smtp (
    smtp_id integer DEFAULT nextval('smtp_ids'::text) PRIMARY KEY,
    user_id integer NOT NULL
    REFERENCES users (user_id) ON DELETE CASCADE ON UPDATE CASCADE,
    changed timestamp with time zone DEFAULT now() NOT NULL,
    del smallint DEFAULT 0 NOT NULL,
    smtpdesc varchar(128) ,
    smtpserver varchar(128) NOT NULL,
    smtpport integer NOT NULL,
    smtpuser varchar(128) NOT NULL,
    smtppass varchar(128) NOT NULL,
    iftls integer DEFAULT 0 NOT NULL,
    ifdefault integer DEFAULT 0 NOT NULL

);

CREATE INDEX smtp_user_id_idx ON smtp (user_id, del);

