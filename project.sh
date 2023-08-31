#!/bin/bash

# JSON file path
json_file="data.json"

# Parse JSON using jq
repository=$(jq -r '.project.repository' "$json_file")
project=$(jq -r '.project.name' "$json_file")

filename=$(jq -r '.configuration.filename' "$json_file")
server_name=$(jq -r '.configuration.server_name' "$json_file")
port=$(jq -r '.configuration.port' "$json_file")

# Enter to /var/www/
cd /var/www/

# Clone repository
git clone $repository $project

# Enter to project
cd $project

# Configure service file
host='$host'
remote_addr='$remote_addr'
cat <<EOF >"/etc/nginx/sites-enabled/${server_name}"
server {
        listen 80;
        listen [::]:80;

        root /var/www/$project;

        server_name $server_name;

        location / {
                proxy_pass http://localhost:$port;
                proxy_set_header Host $host;
                proxy_set_header X-Real-IP $remote_addr;
        }
}
EOF

nginx -t

systemctl restart nginx

# Write to env file
echo "NODE_ENV=production" >".env"
echo "PORT=${port}" >>".env"

npm install

npm run build

npm install pm2 -g

pm2 start ecosystem.config.js
