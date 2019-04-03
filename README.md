# Chinook

**TODO: Add description**

## Installation


## Creating a new configuration setting for Postgres

We have to options:

###1. Define a new configuration parameter within postgresql.conf

```
# postgresql.conf
chinook.app_user = 0
```

###2. Create a new configuration parameter using `ALTER DATABASE`:

```sql
ALTER DATABASE chinook SET chinook.app_user to 0;
```

This create a default value

You might need to execute this command with `superuser` role.

## Creating roles in database

```sql
CREATE ROLE chinook_admin;
CREATE ROLE chinook_supervisor;
CREATE ROLE chinook_agent;
CREATE ROLE chinook_customer;
```

### Create a role for the app and add members

```sql
CREATE ROLE chinook_app;
GRANT chinook_admin to chinook_app;
GRANT chinook_supervisor to chinook_app;
GRANT chinook_agent to chinook_app;
GRANT chinook_customer to chinook_app;
```

### Grant access to the tables for every role
**chinook_admin**
GRANT ALL PRIVILEGES ON app_user to chinook_admin;
GRANT ALL PRIVILEGES ON "Customer" to chinook_admin;
GRANT ALL PRIVILEGES ON "Employee" to chinook_admin; 

**chinook_supevisor**
GRANT ALL PRIVILEGES ON app_user to chinook_supervisor;
GRANT ALL PRIVILEGES ON "Customer" to chinook_supervisor;
GRANT ALL PRIVILEGES ON "Employee" to chinook_supervisor; 

**chinook_agent**
GRANT ALL PRIVILEGES ON app_user to chinook_agent;
GRANT ALL PRIVILEGES ON app_user to chinook_agent;
GRANT ALL PRIVILEGES ON "Customer" to chinook_agent;

**chinook_customer**
GRANT ALL PRIVILEGES ON app_user to chinook_customer;
GRANT ALL PRIVILEGES ON "Customer" to chinook_customer;

### Create RLS for each user


### Don't limit admin access3

### Limit SUpervisor access to Customer table
CREATE POLICY supervisor_customer ON "Customer" to chinook_supervisor
  USING (
    "SupportRepId" IN (
      SELECT e2."EmployeeId"
      FROM "Employee" e1 
      JOIN "Employee" e2 ON 
        e2."ReportsTo" = e1."EmployeeId" OR e2.user_id = current_setting('chinook.app_user')::integer
      WHERE e1.user_id = current_setting('chinook.app_user')::integer
    )
  ); 


#### Limit agent access to Customer table
CREATE POLICY agent_customer ON "Customer" TO chinook_agent 
  USING ("SupportRepId" = (SELECT "EmployeeId" FROM "Employee" e WHERE e.user_id = current_setting('chinook.app_user')::integer));


#### Limit customer access to Customer table
CREATE POLICY customer_itself on "Customer" to chinook_customer
  USING (user_id = current_setting('chinook.app_user')::integer);
