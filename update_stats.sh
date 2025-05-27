#!/bin/sh

cd "$(dirname "$0")"

(

TOTAL=$(
cat <<EOF | psql -qAt asahistats
select count(*) as count from stats where not(hide);
EOF
)

cat <<EOF
<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.0.0/dist/css/bootstrap.min.css" integrity="sha384-Gn5384xqQ1aoWXA+058RXPxPg6fy4IWvTNh0E263XmFcJlSAwiGgFAW/dAiS6JXm" crossorigin="anonymous">

    <title>Asahi Linux install statistics.</title>
  </head>
  <body>
    <div class="container">
      <h2>Breakdown by device:</h2>
      <div class="table-responsive">
        <table class="table table-striped">
          <thead>
            <tr>
              <th scope="col">Count</th>
              <th scope="col">Device class</th>
              <th scope="col">Description</th>
            </tr>
          </thead>
          <tbody>
EOF

cat <<EOF | psql -qAt asahistats
select
    '<tr><td>' || count::text || '</td><td>' || device_class || '</td><td>' || description || '</td></tr>'
from (
select
    count(*) as count,
    stats.data->>'device_class' as device_class,
    devices.description as description
from stats
left join devices on stats.data->>'device_class'=devices.device_class
where not(hide)
group by stats.data->>'device_class', devices.description
order by count(*) desc) as a;
EOF

cat <<EOF
          </tbody>
        </table>
      </div>
      <p>Total installs: $TOTAL</p>
      <p>Note: Devices with only a few installs are development tests (or people having fun).</p>
    </div>
  </body>
</html>

EOF



) > htdocs/stats.txt
