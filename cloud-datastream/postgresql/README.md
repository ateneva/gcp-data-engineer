# Setup Prerequisites

- postgresql db exists
- logical replication has been enabled

```tf
    database_flags {
      name  = "cloudsql.logical_decoding"
      value = "on"
    }
```

- datastream db user has been created
- datastream user has usage privilesges on needed tables and schemas

```sql
--- 1. Create replication user
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'datastream_user') 
    THEN
        CREATE USER datastream_user WITH REPLICATION PASSWORD 'your_secure_password';
    END IF
END
$$;

--- 2. Grant table and schema privileges to datastream user
GRANT USAGE ON SCHEMA public TO datastream_user;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO datastream_user;

--- 3. Ensure datastream_user can read future tables created in public schema
ALTER DEFAULT PRIVILEGES IN SCHEMA public
GRANT SELECT ON TABLES TO datastream_user;
```

- publication and replication slots have been created

```sql
--- 1. Create publication for all tables
--- publication must be unique per stream
CREATE PUBLICATION dvdrental_publication FOR ALL TABLES;

--- 2. Create replication slot
--- replication slot must be unique per stream
SELECT pg_create_logical_replication_slot('dvdrental_slot', 'pgoutput');

```

- primary keys have been defined for the tables being replicated

```sql
-- Add primary key to the customer table
ALTER TABLE customer ADD PRIMARY KEY (customer_id);

-- Add primary key to the payment table
ALTER TABLE payment ADD PRIMARY KEY (payment_id);
```

---

## More info

- https://docs.cloud.google.com/datastream/docs/configure-cloudsql-psql

- https://docs.cloud.google.com/sql/docs/postgres/replication/configure-logical-replication#configure-your-postgresql-instance

- https://docs.cloud.google.com/sql/docs/postgres/replication/configure-logical-replication