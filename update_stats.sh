#!/bin/sh

cd "$(dirname "$0")"

(

echo "Total installs:"

cat <<EOF | su - postgres -s /bin/sh -c "psql asahistats"
select count(*) as count from stats;
EOF

echo "Breakdown by device:"

cat <<EOF | su - postgres -s /bin/sh -c "psql asahistats"
select
    count(*) as count,
    stats.data->>'device_class' as device_class,
    devices.description as description
from stats
left join devices on stats.data->>'device_class'=devices.device_class
group by stats.data->>'device_class', devices.description
order by count desc;
EOF

echo

echo "Note: Devices with only a few installs are development tests (or people having fun)."

) > htdocs/stats.txt
