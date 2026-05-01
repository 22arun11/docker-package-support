# dockgen — Docker Project Scaffold

A CLI tool to scaffold Dockerised projects for Python, FastAPI, React, Vue, Next.js, and Angular — with a fully interactive terminal UI and arrow-key navigation.

## Prerequisites

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) running
- macOS with `bash` and `zsh`

## Installation

```bash
git clone https://github.com/22arun11/docker-package-support.git
cd docker-package-support
chmod +x install.sh
./install.sh
source ~/.zshrc
```

The installer creates a `dockgen` command at `~/.local/bin/dockgen` and adds it to your PATH.  
> **Note:** If you move the repo folder later, re-run `./install.sh` from the new location to update the path.

## Usage

```bash
dockgen
```

The script walks you through an interactive arrow-key UI:

1. **Project type** — arrow-key select from Python, FastAPI, React, Vue, NextJS, Angular
2. **Version** — pick the Python or Node version
3. **Project name** — no spaces allowed
4. **Location** — browse your filesystem with arrow keys, navigate into folders, or create a new subfolder

**Example session:**
```
  ╭────────────────────────────────────────────────────╮
  │  Select project type                               │
  ├────────────────────────────────────────────────────┤
  │ > Python                                           │
  │   FastAPI                                          │
  │   React                                            │
  │   Vue                                              │
  │   NextJS                                           │
  │   Angular                                          │
  ╰────────────────────────────────────────────────────╯

  ╭────────────────────────────────────────────────────╮
  │  Select Python version                             │
  ├────────────────────────────────────────────────────┤
  │ > 3.12                                             │
  │   3.11                                             │
  │   3.10                                             │
  ╰────────────────────────────────────────────────────╯

  Project name: my-api

  ╭────────────────────────────────────────────────────╮
  │  /Users/you/Developer                              │
  ├────────────────────────────────────────────────────┤
  │ > [confirm] Use this folder                        │
  │   [new]     Create subfolder here                  │
  │   [..]      Go up                                  │
  │   1  Projects                                      │
  │   2  Work                                          │
  ╰────────────────────────────────────────────────────╯
  arrows move  enter select  [new] = new folder
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

### FastAPI
- Template files copied instantly
- Edit `main.py` to start building; add dependencies to `requirements.txt`
- API docs auto-available at **http://localhost:8000/docs**
- Runs on **http://localhost:8000**

### React (Vite)
- Scaffolded via `npm create vite@latest` inside Docker — always the latest React + Vite
- Runs on **http://localhost:5173**
- Takes ~1 min on first scaffold (pulls Node image)

### Vue (Vite)
- Scaffolded via `npm create vite@latest --template vue` inside Docker
- Runs on **http://localhost:5173**
- Takes ~1 min on first scaffold (pulls Node image)

### Next.js
- Scaffolded via `create-next-app` inside Docker — TypeScript, Tailwind, App Router included
- Runs on **http://localhost:3000**
- Takes ~1–2 min on first scaffold (pulls Node image)

### Angular
- Scaffolded via `ng new` inside Docker — always the latest Angular CLI
- Runs on **http://localhost:4200**
- Takes ~2 min on first scaffold (pulls Node image + installs Angular CLI)

## Repository Structure

```
docker-package-support/
├── create_project.sh    # The scaffold script
├── install.sh           # Installs `dockgen` command globally
├── README.md
└── Templates/
    ├── Python/          # Dockerfile, docker-compose.yml, main.py, requirements.txt
    ├── FastAPI/         # Dockerfile, docker-compose.yml, main.py, requirements.txt
    ├── React/           # Dockerfile, docker-compose.yml, .dockerignore
    ├── Vue/             # Dockerfile, docker-compose.yml, .dockerignore
    ├── NextJS/          # Dockerfile, docker-compose.yml, .dockerignore
    └── Angular/         # Dockerfile, docker-compose.yml, .dockerignore
```

## Port Reference

| Type    | URL                    |
|---------|------------------------|
| Python  | http://localhost:8000  |
| FastAPI | http://localhost:8000  |
| React   | http://localhost:5173  |
| Vue     | http://localhost:5173  |
| Next.js | http://localhost:3000  |
| Angular | http://localhost:4200  |
