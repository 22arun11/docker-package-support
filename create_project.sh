#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "$0")" && pwd)"

# ── 1. Project type ───────────────────────────────────────────────────────
echo ""
echo "Select project type:"
select project_type in Python React Angular; do
  [[ -n "$project_type" ]] && break
done

# ── 2. Version ────────────────────────────────────────────────────────────
case "$project_type" in
  Python)  versions=("3.13" "3.12" "3.11" "3.10"); ver_label="Python version" ;;
  React)   versions=("22" "20" "18");               ver_label="Node version" ;;
  Angular) versions=("22" "20");                    ver_label="Node version" ;;
esac

echo ""
echo "Select $ver_label:"
select version in "${versions[@]}"; do
  [[ -n "$version" ]] && break
done

# ── 3. Project name ───────────────────────────────────────────────────────
echo ""
read -p "Project name (no spaces): " name
[[ -z "$name" ]]      && { echo "Project name required" >&2; exit 1; }
[[ "$name" == *" "* ]] && { echo "Project name cannot contain spaces" >&2; exit 1; }

# ── 4. Target directory ───────────────────────────────────────────────────
default_base="$HOME/Developer"

echo ""
echo "Base path: $default_base"
echo ""

# List folders in the base path as a hint
if [[ -d "$default_base" ]]; then
  echo "Folders available in $default_base:"
  for d in "$default_base"/*/; do
    [[ -d "$d" ]] && echo "  $(basename "$d")/"
  done
  echo ""
fi

echo "Enter a sub-folder relative to $default_base to create the project in"
echo "Or leave empty to use: $default_base/$name"
echo "(e.g. type  Python-Project  to create at $default_base/Python-Project/$name)"
read -p "> " target_input

if [[ -z "$target_input" ]]; then
  target="$default_base/$name"
elif [[ "$target_input" = /* ]]; then
  # Absolute path — append project name
  target="${target_input%/}/$name"
else
  # Relative to default base — append project name
  target="$default_base/${target_input%/}/$name"
fi

# ── 5. Create / validate target directory ────────────────────────────────
if [[ -e "$target" ]]; then
  [[ ! -d "$target" ]] && { echo "Path exists and is not a directory: $target" >&2; exit 1; }
  if [[ $(ls -A "$target") ]]; then
    read -p "Directory exists and is not empty. Continue? [y/N]: " yn
    case "$yn" in [Yy]*) ;; *) echo "Aborting."; exit 1;; esac
  fi
else
  mkdir -p "$target"
fi

echo ""
echo "Scaffolding $project_type $version project '$name'..."
echo "Target: $target"
echo ""

# ── Helpers ───────────────────────────────────────────────────────────────
safe_copy_file() {
  local src="$1" dst="$2"
  if [[ -e "$dst" ]]; then
    read -p "File $(basename "$dst") exists. Overwrite? [y/N]: " ans
    case "$ans" in [Yy]*) cp "$src" "$dst" ;; *) echo "Skipping $(basename "$dst")"; return ;; esac
  else
    cp "$src" "$dst"
  fi
}

copy_template_dir() {
  local src_dir="$1"
  for f in "$src_dir"/* "$src_dir"/.[!.]*; do
    [[ -e "$f" ]] || continue
    local base; base=$(basename "$f")
    if [[ -d "$f" ]]; then
      mkdir -p "$target/$base"
      cp -R "$f/." "$target/$base/"
    else
      safe_copy_file "$f" "$target/$base"
    fi
  done
}

# ── 6. Scaffold ───────────────────────────────────────────────────────────
case "$project_type" in
  Python)
    copy_template_dir "$repo_root/Templates/Python"
    sed -i '' "s|FROM python:[^-]*-slim|FROM python:${version}-slim|" "$target/Dockerfile"
    ;;

  React)
    echo "Running npm create vite via Docker — this may take a minute..."
    docker run --rm -v "$target:/app" -w /app "node:${version}-alpine" \
      sh -c "npm create vite@latest . -- --template react"
    for f in Dockerfile docker-compose.yml .dockerignore; do
      src="$repo_root/Templates/React/$f"
      [[ -f "$src" ]] && safe_copy_file "$src" "$target/$f"
    done
    sed -i '' "s|node:18-alpine|node:${version}-alpine|g" "$target/Dockerfile"
    ;;

  Angular)
    echo "Running ng new via Docker — this may take a minute..."
    docker run --rm -v "$target:/app" -w /tmp "node:${version}-alpine" \
      sh -c "npm install -g @angular/cli@latest && ng new myapp --skip-git --defaults --style=css --routing && cp -r myapp/. /app/"
    for f in Dockerfile docker-compose.yml .dockerignore; do
      src="$repo_root/Templates/Angular/$f"
      [[ -f "$src" ]] && safe_copy_file "$src" "$target/$f"
    done
    sed -i '' "s|node:20-alpine|node:${version}-alpine|g" "$target/Dockerfile"
    ;;
esac

echo ""
echo "Done! Project scaffolded at: $target"
echo ""
echo "Next steps:"
echo "  cd $target"
echo "  docker compose up --build"

