-- RoundCube Webmail update script for Postgres databases
-- Updates from version 0.3-stable

CREATE INDEX messages_index_idx ON messages (user_id, cache_key, idx);
TRUNCATE messages;
DROP INDEX contacts_user_id_idx;
CREATE INDEX contacts_user_id_idx ON contacts (user_id, email);
