default:
    just --list

up:
    just --justfile backend/justfile up

down:
    just --justfile backend/justfile down

restart:
    just --justfile backend/justfile restart

health:
    just --justfile backend/justfile health

logs:
    just --justfile backend/justfile logs

db-cli:
    just --justfile backend/justfile db-cli

prisma-generate:
    just --justfile backend/justfile prisma-generate

prisma-migrate-dev name:
    just --justfile backend/justfile prisma-migrate-dev {{name}}

prisma-migrate-deploy:
    just --justfile backend/justfile prisma-migrate-deploy

prisma-studio:
    just --justfile backend/justfile prisma-studio

dev:
    just --justfile backend/justfile dev

build:
    just --justfile backend/justfile build

clean:
    just --justfile backend/justfile clean
