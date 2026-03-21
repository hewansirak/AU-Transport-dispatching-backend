# README

# AU Transport System - API
 
Built with Ruby on Rails 7.2 · PostgreSQL · JWT Auth · Docker
 
## Getting started
 
```bash
git clone <repo-url> && cd au_transport
.env                        # fill in your DB and JWT values
docker compose build
docker compose run --rm app rails db:create db:migrate db:seed
docker compose up
```
 
API is live at `http://localhost:3000/api/v1` 
— see `AU_Transport_API_Reference.docx` for all endpoints, request bodies, and test credentials.
 
