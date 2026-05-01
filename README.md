# Docker Project Scaffolder

A tool to quickly scaffold Dockerised projects for Python, React, and Angular — with a single interactive script.

## Prerequisites

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) running
- macOS (graphical folder picker uses the native macOS dialog)

## Usage

```bash
./create_project.sh
```

The script will guide you through three steps:

1. **Select project type** — a macOS dialog lets you choose Python, React, or Angular
2. **Select target folder** — a native folder picker lets you browse to where you want the project created
3. **Enter a project name** — typed in the terminal; the project is created at `<folder>/<name>`

Once scaffolded:

```bash
cd <your-project-folder>
docker compose up --build
```

## Project Types

### Python
- Copies template files instantly
- Runs on **http://localhost:8000**
- Edit `main.py` to start building
- Add dependencies to `requirements.txt`

### React (Vite)
- Scaffolded via `npm create vite@latest` inside Docker — always uses the latest React + Vite
- Runs on **http://localhost:5173**
- Takes ~1 min on first scaffold (pulls node image)

### Angular
- Scaffolded via `ng new` inside Docker — always uses the latest Angular CLI
- Runs on **http://localhost:4200**
- Takes ~2 min on first scaffold (pulls node image + installs Angular CLI)

## Repository Structure

```
docker-package-support/
├── create_project.sh        # The scaffold script
└── Templates/
    ├── Python/              # Dockerfile, docker-compose.yml, main.py, requirements.txt
    ├── React/               # Dockerfile, docker-compose.yml, .dockerignore
    └── Angular/             # Dockerfile, docker-compose.yml, .dockerignore
```

## Port Reference

| Type    | URL                      |
|---------|--------------------------|
| Python  | http://localhost:8000    |
| React   | http://localhost:5173    |
| Angular | http://localhost:4200    |
