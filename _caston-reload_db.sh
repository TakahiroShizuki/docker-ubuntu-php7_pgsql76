ps -a | grep postmaster;
if [ 0 = $? ]; then
  pg_ctl stop -m fast
fi
sleep 5

pg_ctl start
sleep 5

psql -d postgres -c "select * from pg_database" | grep caston;
if [ 0 = $? ]; then
  dropdb caston
fi
createdb caston -E UTF-8
createlang plpgsql -d caston -U postgres
psql caston caston < _caston-dump-20160412230001.dmp 
psql caston caston < /opt/caston/services/db/_func_caston.sql
