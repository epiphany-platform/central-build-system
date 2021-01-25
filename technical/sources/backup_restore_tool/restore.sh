#!/bin/bash

set -e

for db in "registry" "notarysigner" "notaryserver"
do
	# block and terminate SQL connections to database we want to restore
	kubectl exec -n harborrestoretest -it harbor-harbor-database-0 -- \
		psql -U postgres postgres -c "UPDATE pg_database SET datallowconn = 'false' WHERE datname = '$db'";
	kubectl exec -n harborrestoretest -it harbor-harbor-database-0 -- \
		psql -U postgres postgres -c "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = '$db';"

	# recreate empty database
	kubectl exec -n harborrestoretest -it harbor-harbor-database-0 -- psql -U postgres -c "drop database $db;"
	kubectl exec -n harborrestoretest -it harbor-harbor-database-0 -- psql -U postgres -c "create database $db;"

	# restore database from backup
	kubectl exec -n harborrestoretest -i harbor-harbor-database-0 -- pg_restore --no-acl --no-owner -U postgres -d "$db" < "$db.dump"
done

echo "Restore complete"
