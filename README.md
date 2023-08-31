# Deploy nuxt js project

* `install.sh` - bir marta asosiy paketlarni o'rnatib olish uchun ishga tushiriladi.
* `project.sh` - proyektni githubdan yuklab oladi, nginx sozlamalarini amalga oshiradi va pm2 orqali proyekt ishga
  tushiradi.

Variables in `data.json`:

* `repository` - github repository of project (required)
* `url` - project url (required)
* `port` - port number for project (required)
