-- Create replication slot
SELECT pg_create_logical_replication_slot('dvdrental_slot', 'pgoutput');

-- Create publication for all tables
CREATE PUBLICATION dvdrental_publication FOR ALL TABLES;

-- Grant replication privilege to the datastream user
-- Note: In Cloud SQL, you might need to use the 'cloudsqlsuperuser' role or similar if available,
-- but typically ALTER USER ... WITH REPLICATION should work if run by a privileged account.
ALTER USER dvdrental_user WITH REPLICATION;
