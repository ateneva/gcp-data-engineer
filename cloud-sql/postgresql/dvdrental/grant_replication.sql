
--- 1. Grant super user privileges to replication user
GRANT cloudsqlsuperuser TO datastream_user;

--- 2. Create publication for all tables
CREATE PUBLICATION dvdrental_publication FOR ALL TABLES;

--- 3. Create replication slot
SELECT pg_create_logical_replication_slot('dvdrental_slot', 'pgoutput');

--- 4. Grant table and schema privileges to datastream user
GRANT USAGE ON SCHEMA public TO datastream_user;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO datastream_user;
    
--- 5. Ensure datastream_user can read future tables created in public schema
ALTER DEFAULT PRIVILEGES IN SCHEMA public 
GRANT SELECT ON TABLES TO datastream_user;