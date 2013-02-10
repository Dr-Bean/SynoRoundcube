-- Roundcube Webmail initial database structure

--
-- Sequence "user_ids"
-- Name: user_ids; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE user_ids
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;

--
-- Table "users"
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE users (
    user_id integer DEFAULT nextval('user_ids'::text) PRIMARY KEY,
    username varchar(128) DEFAULT '' NOT NULL,
    mail_host varchar(128) DEFAULT '' NOT NULL,
    alias varchar(128) DEFAULT '' NOT NULL,
    created timestamp with time zone DEFAULT now() NOT NULL,
    last_login timestamp with time zone DEFAULT NULL,
    "language" varchar(5),
    preferences text DEFAULT ''::text NOT NULL
	
-- RC085: Added
	CONSTRAINT users_username_key UNIQUE (username, mail_host)
);

CREATE INDEX users_username_id_idx ON users (username);
CREATE INDEX users_alias_id_idx ON users (alias);

  
--
-- Table "session"
-- Name: session; Type: TABLE; Schema: public; Owner: postgres
--
-- RC085: Edited sess_id to 128

CREATE TABLE "session" (
    sess_id varchar(128) DEFAULT '' PRIMARY KEY,
    created timestamp with time zone DEFAULT now() NOT NULL,
    changed timestamp with time zone DEFAULT now() NOT NULL,
    ip varchar(41) NOT NULL,
    vars text NOT NULL
);

CREATE INDEX session_changed_idx ON session (changed);


--
-- Sequence "identity_ids"
-- Name: identity_ids; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE identity_ids
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;

--
-- Table "identities"
-- Name: identities; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE identities (
    identity_id integer DEFAULT nextval('identity_ids'::text) PRIMARY KEY,
    user_id integer NOT NULL
	REFERENCES users (user_id) ON DELETE CASCADE ON UPDATE CASCADE,
    changed timestamp with time zone DEFAULT now() NOT NULL,
    del smallint DEFAULT 0 NOT NULL,
    standard smallint DEFAULT 0 NOT NULL,
    name varchar(128) NOT NULL,
    organization varchar(128),
    email varchar(128) NOT NULL,
    "reply-to" varchar(128),
    bcc varchar(128),
    signature text,
    html_signature integer DEFAULT 0 NOT NULL
);

CREATE INDEX identities_user_id_idx ON identities (user_id, del);


--
-- Table "popinfo"
-- Name: popinfo; Type: TABLE; Schema: public; Owner: postgres
--

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

--
-- Sequence "smtp_ids"
-- Name: smtp_ids; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE smtp_ids
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;

--
-- Table "smtp"
-- Name: smtp; Type: TABLE; Schema: public; Owner: postgres
--

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

--
-- Sequence "account_type_ids"
-- Name: account_type_ids; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE users_type_ids
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;

--
-- Table "users_type"
-- Name: users_type; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE users_type (
    users_type_id integer DEFAULT nextval('users_type_ids'::text) PRIMARY KEY,
    user_id integer NOT NULL
	REFERENCES users (user_id) ON DELETE CASCADE ON UPDATE CASCADE,
    account_type varchar(128) DEFAULT 'local' NOT NULL,
    domain_name varchar(512) DEFAULT '' NOT NULL

);

CREATE INDEX users_type_user_id_idx ON users_type (users_type_id, account_type, domain_name);

--
-- Sequence "contact_ids"
-- Name: contact_ids; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE contact_ids
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;

--
-- Table "contacts"
-- Name: contacts; Type: TABLE; Schema: public; Owner: postgres
--
-- RC085: Added words

CREATE TABLE contacts (
    contact_id integer DEFAULT nextval('contact_ids'::text) PRIMARY KEY,
    user_id integer NOT NULL
	REFERENCES users (user_id) ON DELETE CASCADE ON UPDATE CASCADE,
    changed timestamp with time zone DEFAULT now() NOT NULL,
    del smallint DEFAULT 0 NOT NULL,
    name varchar(128) DEFAULT '' NOT NULL,
    email varchar(128) DEFAULT '' NOT NULL,
    firstname varchar(128) DEFAULT '' NOT NULL,
    surname varchar(128) DEFAULT '' NOT NULL,
    vcard text
	words text
);

CREATE INDEX contacts_user_id_idx ON contacts (user_id, email);

--
-- Sequence "contactgroups_ids"
-- Name: contactgroups_ids; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE contactgroups_ids
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;

--
-- Table "contactgroups"
-- Name: contactgroups; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE contactgroups (
    contactgroup_id integer DEFAULT nextval('contactgroups_ids'::text) PRIMARY KEY,
    user_id integer NOT NULL
        REFERENCES users(user_id) ON DELETE CASCADE ON UPDATE CASCADE,
    changed timestamp with time zone DEFAULT now() NOT NULL,
    del smallint NOT NULL DEFAULT 0,
    name varchar(128) NOT NULL DEFAULT ''
);

CREATE INDEX contactgroups_user_id_idx ON contactgroups (user_id, del);

--
-- Table "contactgroupmembers"
-- Name: contactgroupmembers; Type: TABLE; Schema: public; Owner: postgres
--
					    
CREATE TABLE contactgroupmembers (
    contactgroup_id integer NOT NULL
        REFERENCES contactgroups(contactgroup_id) ON DELETE CASCADE ON UPDATE CASCADE,
    contact_id integer NOT NULL
        REFERENCES contacts(contact_id) ON DELETE CASCADE ON UPDATE CASCADE,
    created timestamp with time zone DEFAULT now() NOT NULL,
    PRIMARY KEY (contactgroup_id, contact_id)
);

CREATE INDEX contactgroupmembers_contact_id_idx ON contactgroupmembers (contact_id);

--
-- Sequence "cache_ids"
-- Name: cache_ids; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE cache_ids
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;

--
-- Table "cache"
-- Name: cache; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "cache" (
    cache_id integer DEFAULT nextval('cache_ids'::text) PRIMARY KEY,
    user_id integer NOT NULL
	REFERENCES users (user_id) ON DELETE CASCADE ON UPDATE CASCADE,
    cache_key varchar(128) DEFAULT '' NOT NULL,
    created timestamp with time zone DEFAULT now() NOT NULL,
    data text NOT NULL
);

CREATE INDEX cache_user_id_idx ON "cache" (user_id, cache_key);
CREATE INDEX cache_created_idx ON "cache" (created);

--
-- Sequence "message_ids"
-- Name: message_ids; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE message_ids
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;

--
-- Table "messages"
-- Name: messages; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE messages (
    message_id integer DEFAULT nextval('message_ids'::text) PRIMARY KEY,
    user_id integer NOT NULL
	REFERENCES users (user_id) ON DELETE CASCADE ON UPDATE CASCADE,
    del smallint DEFAULT 0 NOT NULL,
    cache_key varchar(128) DEFAULT '' NOT NULL,
    created timestamp with time zone DEFAULT now() NOT NULL,
    idx integer DEFAULT 0 NOT NULL,
    uid integer DEFAULT 0 NOT NULL,
    subject varchar(128) DEFAULT '' NOT NULL,
    "from" varchar(128) DEFAULT '' NOT NULL,
    "to" varchar(128) DEFAULT '' NOT NULL,
    cc varchar(128) DEFAULT '' NOT NULL,
    date timestamp with time zone NOT NULL,
    size integer DEFAULT 0 NOT NULL,
    headers text NOT NULL,
    structure text
);

ALTER TABLE messages ADD UNIQUE (user_id, cache_key, uid);
CREATE INDEX messages_index_idx ON messages (user_id, cache_key, idx);
CREATE INDEX messages_created_idx ON messages (created);

--
-- Table "cache_index"
-- Name: cache_index; Type: TABLE; Schema: public; Owner: postgres
--

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

--
-- Table "cache_thread"
-- Name: cache_thread; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE cache_thread (
    user_id integer NOT NULL
    	REFERENCES users (user_id) ON DELETE CASCADE ON UPDATE CASCADE,
    mailbox varchar(255) NOT NULL,
    changed timestamp with time zone DEFAULT now() NOT NULL,
    data text NOT NULL,
    PRIMARY KEY (user_id, mailbox)
);

CREATE INDEX cache_thread_changed_idx ON cache_thread (changed);

--
-- Table "cache_messages"
-- Name: cache_messages; Type: TABLE; Schema: public; Owner: postgres
--

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

--
-- Table "dictionary"
-- Name: dictionary; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE dictionary (
    user_id integer DEFAULT NULL
    	REFERENCES users (user_id) ON DELETE CASCADE ON UPDATE CASCADE,
   "language" varchar(5) NOT NULL,
    data text NOT NULL,
    CONSTRAINT dictionary_user_id_language_key UNIQUE (user_id, "language")
);

--
-- Sequence "searches_ids"
-- Name: searches_ids; Type: SEQUENCE; Schema: public; Owner: postgres
--
CREATE SEQUENCE search_ids
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;

--
-- Table "searches"
-- Name: searches; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE searches (
    search_id integer DEFAULT nextval('search_ids'::text) PRIMARY KEY,
    user_id integer NOT NULL
        REFERENCES users (user_id) ON DELETE CASCADE ON UPDATE CASCADE,
    "type" smallint DEFAULT 0 NOT NULL,
    name varchar(128) NOT NULL,
    data text NOT NULL,
    CONSTRAINT searches_user_id_key UNIQUE (user_id, "type", name)
);
