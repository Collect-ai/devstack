#!/bin/bash

set -e
set -u

function wait_for_postgres() {
    local max_attempts=30
    local attempt=1
    
    echo "Waiting for PostgreSQL to be ready..."
    while [ $attempt -le $max_attempts ]; do
        if pg_isready -U "$POSTGRES_USER" -d postgres > /dev/null 2>&1; then
            echo "PostgreSQL is ready!"
            return 0
        fi
        
        echo "Attempt $attempt of $max_attempts: PostgreSQL is not ready yet... waiting 2 seconds"
        attempt=$((attempt + 1))
        sleep 2
    done
    
    echo "Failed to connect to PostgreSQL after $max_attempts attempts"
    return 1
}

function create_user_and_database() {
    local database=$1
    echo "Creating user and database '$database'"
    psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname postgres <<-EOSQL
        CREATE DATABASE $database;
        GRANT ALL PRIVILEGES ON DATABASE $database TO $POSTGRES_USER;
EOSQL
}

if [ -n "$POSTGRES_MULTIPLE_DATABASES" ]; then
    # Wait for PostgreSQL to be ready before proceeding
    wait_for_postgres || exit 1
    
    echo "Multiple database creation requested: $POSTGRES_MULTIPLE_DATABASES"
    for db in $(echo $POSTGRES_MULTIPLE_DATABASES | tr ',' ' '); do
        create_user_and_database $db
    done
    echo "Multiple databases created"
fi
