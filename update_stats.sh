#!/bin/sh

cd "$(dirname "$0")"

(

echo "Total installs:"

cat <<EOF | su - postgres -s /bin/sh -c "psql asahistats"
select count(*) as count from stats where not(hide);
EOF

echo "Breakdown by device:"

cat <<EOF | su - postgres -s /bin/sh -c "psql asahistats"
select
    count(*) as count,
    stats.data->>'device_class' as device_class,
    devices.description as description
from stats
left join devices on stats.data->>'device_class'=devices.device_class
where not(hide)
group by stats.data->>'device_class', devices.description
order by count desc;
EOF

echo

echo "Note: Devices with only a few installs are development tests (or people having fun)."

echo

echo "Breakdown by installed OS:"

cat <<EOF | su - postgres -s /bin/sh -c "psql asahistats"
select
    count(*) as count,
    trim(regexp_replace(data->>'os_name', '([^a-zA-Z])\(?[0-9]+\)? ?([^a-zA-Z]|$)', '\1\3', 'g')) as os
from stats
group by os
order by count desc;
EOF

) > htdocs/stats.txt
