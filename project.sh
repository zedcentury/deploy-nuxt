#!/bin/bash

# JSON file path
json_file="data.json"

# Parse JSON using jq
repository=$(jq -r '.repository' "$json_file")
project=$(basename "$repository" .git)
url=$(jq -r '.url' "$json_file")
port=$(jq -r '.port' "$json_file")

# Enter to /var/www/
cd /var/www/

# Clone repository
git clone $repository

# Enter to project
cd $project

# Configure service file
host='$host'
remote_addr='$remote_addr'
cat <<EOF >"/etc/nginx/sites-enabled/${project}"
server {
        listen 80;
        listen [::]:80;

        root /var/www/$project;

        server_name $url;

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
