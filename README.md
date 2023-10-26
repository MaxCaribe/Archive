Task “The Archive”

We record vehicle events in our database. Assume the table is called “car_snapshots” and
looks roughly as follows:

| id   | timestamp  |         data |
|------|:----------:|-------------:|
| 1234 | 1551343776 | ignition_off |

(assume the table only has an index on “id” and “timestamp” and is otherwise a plain table)

Over time, that table grew to millions and millions of entries and we don’t need older ones
anymore (but still do not want to lose them). The table is “insert only”, so an event is only
added but never modified.

What would be your approach to archive these rows in the production environment? Please
remember there are a lot of rows and data is constantly added with a rate of 10 rows per
second. Write a small concept - a high level idea is enough.

----

I have mostly worked with PostgreSQL, so my response will be applied using this database management system.

The best approach for the task is to use table partitioning.
PostgreSQL provides 3 types of partitioning:
1) Range Partitioning - it can be applied to our usecase, but if we need to access data by some period.
It may not be good if we need to gather data for last week or month often but it's divided into 2 parts of the table. 
I don't think that's the best approach.
2) List Partitioning - definitely no. This approach is best for enums/STI.
3) Hash Partitioning - also no. It doesn't allow us to get rid of historical data, which is our requirement.

So nothing from built-in solutions fits the task. 
Instead, I would suggest creating custom partitioning. 
It will consist of the following steps: 
1) Create copy of car_snapshots table, f.e. car_snapshots_archive.
2) Create SQL request that will insert data from car_snapshots to car_snapshots_archive.
Example query: 
   </br>`INSERT INTO car_snapshots_archive (id, created_at, data)`
   </br>`SELECT id, created_at, data FROM car_snapshots`
   </br>`WHERE car_snapshots.created_at < (CURRENT_DATE - '1 month'::interval)`
3) Create SQL request that will delete the archived records.
Example query:
   </br>`DELETE FROM car_snapshots`
   </br>`WHERE car_snapshots.created_at < (CURRENT_DATE - '1 month'::interval)`
4) Create a cron that will perform create and delete queries monthly (interval may be different),
and we will always have access to last month's data.
**pg_cron** may be used for that purpose or just cron that runs rails job.

Archived data may be dumped and removed from the table if physical space needs to be freed. 
Basically same cron may be responsible in this case, but with different interval for WHERE condition query.

