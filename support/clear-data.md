## Clearing Data

If youn want to re-run this same demo a few times using the seat simulator you will need to clear the data between runs. To do use the instructions below.


### Clear MySQL

```
oc rsh mysql-XXXX

mysql -u root
use sampledb;
delete from bookedseat;
commit;
```

### Clear Postgres

```
oc rsh postgres-XXXX
psql
# List databases
/l
# Use database
\c sampledb
# List tables
\dt
# Delete reservation seats
DELETE FROM reservationlist;
```
