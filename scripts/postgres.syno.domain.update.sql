-- synology ---
-- RoundCube Webmail update script for Postgres databases
-- Updates from version 0.4.2 for domain user functions

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

INSERT INTO users_type (user_id) SELECT user_id from users;
