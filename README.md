# Docker Project Scaffolder

A tool to quickly scaffold Dockerised projects for Python, React, and Angular — with a single interactive terminal script.

## Prerequisites

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) running
- macOS / Linux with `bash`

## Usage

```bash
./create_project.sh
```

The script walks you through four prompts:

1. **Project type** — choose Python, React, or Angular
2. **Version** — pick the Python or Node version to use
3. **Project name** — no spaces allowed
4. **Location** — shows existing folders inside `~/Developer/` as a hint; enter a sub-path relative to it, or leave empty to create directly inside `~/Developer/<name>`

**Example session:**
```
Select project type:
1) Python  2) React  3) Angular
? 2

Select Node version:
1) 22  2) 20  3) 18
? 1

Project name (no spaces): my-react-app

Base path: /Users/you/Developer

Folders available in /Users/you/Developer:
  Angular/
  Python-Project/

Enter a sub-path relative to /Users/you/Developer (e.g. Projects/my-react-app)
Or leave empty to use: /Users/you/Developer/my-react-app
>
```

Once scaffolded:

```bash
cd ~/Developer/my-react-app
docker compose up --build
```

## Project Types

### Python
- Template files copied instantly
- Edit `main.py` to start building; add dependencies to `requirements.txt`
- Runs on **http://localhost:8000**

### React (Vite)
- Scaffolded via `npm create vite@latest` inside Docker — always the latest React + Vite
- Runs on **http://localhost:5173**
- Takes ~1 min on first scaffold (pulls Node image)

### Angular
- Scaffolded via `ng new` inside Docker — always the latest Angular CLI
- Runs on **http://localhost:4200**
- Takes ~2 min on first scaffold (pulls Node image + installs Angular CLI)

## Repository Structure

```
docker-package-support/
├── create_project.sh    # The scaffold script
├── README.md
└── Templates/
    ├── Python/          # Dockerfile, docker-compose.yml, main.py, requirements.txt
    ├── React/           # Dockerfile, docker-compose.yml, .dockerignore
    └── Angular/         # Dockerfile, docker-compose.yml, .dockerignore
```

## Port Reference

| Type    | URL                    |
|---------|------------------------|
| Python  | http://localhost:8000  |
| React   | http://localhost:5173  |
| Angular | http://localhost:4200  |
