#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "$0")" && pwd)"

# ── Arrow-key menu ────────────────────────────────────────────────────────
# Usage: pick "Prompt" item1 item2 ...
# Result stored in MENU_RESULT
pick() {
  local prompt="$1"; shift
  local options=("$@")
  local sel=0 n=${#options[@]}
  local C='\033[1;36m'   # cyan border
  local G='\033[1;32m'   # green selected
  local R='\033[0m'      # reset
  local D='\033[2m'      # dim hint
  local W=44             # inner box width (number of ─ chars)

  _draw_pick() {
    if [[ ${__pick_drawn:-0} -eq 1 ]]; then
      tput cuu $(( n + 5 ))
    fi
    __pick_drawn=1
    local bar; bar=$(printf '%*s' "$W" '' | tr ' ' '─')
    printf "${C}╭${bar}╮${R}\n"
    printf "${C}│${R}  %-$(( W - 2 ))s${C}│${R}\n" "$prompt"
    printf "${C}├${bar}┤${R}\n"
    local i
    for (( i = 0; i < n; i++ )); do
      if [[ $i -eq $sel ]]; then
        printf "${C}│${R} ${G}▶ %-$(( W - 4 ))s ${R}${C}│${R}\n" "${options[$i]}"
      else
        printf "${C}│${R}   %-$(( W - 4 ))s ${C}│${R}\n" "${options[$i]}"
      fi
    done
    printf "${C}╰${bar}╯${R}\n"
    printf "${D}   ↑ ↓ move   ↵ select${R}\n"
  }

  tput civis
  __pick_drawn=0
  _draw_pick

  while true; do
    IFS= read -r -s -n1 k
    if [[ "$k" == $'\x1b' ]]; then
      IFS= read -r -s -n2 k2
      case "$k2" in
        '[A') if (( sel > 0 ));     then (( sel-- )); fi ;;
        '[B') if (( sel < n - 1 )); then (( sel++ )); fi ;;
      esac
    elif [[ -z "$k" ]]; then
      break
    fi
    _draw_pick
  done

  tput cnorm
  # Replace hint line with confirmation
  tput cuu 1; tput el
  printf "   ${G}✓  ${options[$sel]}${R}\n"
  MENU_RESULT="${options[$sel]}"
}

# ── Arrow-key folder browser ──────────────────────────────────────────────
# Result stored in BROWSE_RESULT
browse_dir() {
  local cur="${1:-$HOME/Developer}"
  local C='\033[1;36m' G='\033[1;32m' Y='\033[1;33m' R='\033[0m' D='\033[2m'
  local W=52
  local sel=0
  local __drawn=0

  _draw_browser() {
    local entries=("$@")
    local n=${#entries[@]}
    if [[ $__drawn -gt 0 ]]; then
      tput cuu "$__drawn"
    fi
    local bar; bar=$(printf '%*s' "$W" '' | tr ' ' '─')
    local pathdisp="$cur"
    (( ${#pathdisp} > W - 4 )) && pathdisp="...${pathdisp: -(( W - 7 ))}"
    printf "${C}╭${bar}╮${R}\n"
    printf "${C}│${R}  %-$(( W - 2 ))s${C}│${R}\n" "$pathdisp"
    printf "${C}├${bar}┤${R}\n"
    local i
    for (( i = 0; i < n; i++ )); do
      if [[ $i -eq $sel ]]; then
        printf "${C}│${R} ${G}> %-$(( W - 4 ))s ${R}${C}│${R}\n" "${entries[$i]}"
      else
        printf "${C}│${R}   %-$(( W - 4 ))s ${C}│${R}\n" "${entries[$i]}"
      fi
    done
    printf "${C}╰${bar}╯${R}\n"
    printf "${D}  arrows move  enter select  [new] = new folder${R}\n"
    __drawn=$(( n + 5 ))
  }

  tput civis

  while true; do
    local entries=()
    entries+=("[confirm] Use this folder")
    entries+=("[new]     Create subfolder here")
    [[ "$cur" != "/" ]] && entries+=("[..]      Go up")
    while IFS= read -r -d '' d; do
      entries+=("$(basename "$d")")
    done < <(find "$cur" -maxdepth 1 -mindepth 1 -type d -not -name '.*' -print0 2>/dev/null | sort -z)

    local n=${#entries[@]}
    (( sel >= n )) && sel=$(( n - 1 ))

    _draw_browser "${entries[@]}"

    IFS= read -r -s -n1 k
    if [[ "$k" == $'\x1b' ]]; then
      IFS= read -r -s -n2 k2
      case "$k2" in
        '[A') (( sel > 0 ))     && (( sel-- )) ;;
        '[B') (( sel < n - 1 )) && (( sel++ )) ;;
      esac
      continue
    fi

    if [[ -z "$k" ]]; then
      local chosen="${entries[$sel]}"
      if [[ "$chosen" == "[confirm]"* ]]; then
        break
      elif [[ "$chosen" == "[new]"* ]]; then
        tput cnorm
        tput cuu "$__drawn"; tput ed
        __drawn=0
        printf "${Y}  New folder name: ${R}"
        local newname
        IFS= read -r newname
        if [[ -n "$newname" ]]; then
          cur="$cur/$newname"
          mkdir -p "$cur"
        fi
        sel=0
        tput civis
      elif [[ "$chosen" == "[..]"* ]]; then
        cur="$(dirname "$cur")"
        sel=0
      else
        cur="$cur/$chosen"
        sel=0
      fi
    fi
  done

  tput cnorm
  tput cuu "$__drawn"; tput ed
  printf "   ${G}✓  $cur${R}\n"
  BROWSE_RESULT="$cur"
}


echo ""
pick "Select project type" Python FastAPI React Vue NextJS Angular
project_type="$MENU_RESULT"

# ── 2. Version ────────────────────────────────────────────────────────────
case "$project_type" in
  Python|FastAPI) versions=("3.13" "3.12" "3.11" "3.10"); ver_label="Python version" ;;
  React|Vue)      versions=("22" "20" "18");               ver_label="Node version" ;;
  NextJS)         versions=("22" "20" "18");               ver_label="Node version" ;;
  Angular)        versions=("22" "20");                    ver_label="Node version" ;;
esac

echo ""
pick "Select $ver_label" "${versions[@]}"
version="$MENU_RESULT"

# ── 3. Project name ───────────────────────────────────────────────────────
echo ""
read -p "Project name (no spaces): " name
[[ -z "$name" ]]      && { echo "Project name required" >&2; exit 1; }
[[ "$name" == *" "* ]] && { echo "Project name cannot contain spaces" >&2; exit 1; }

# ── 4. Target directory ───────────────────────────────────────────────────
echo ""
browse_dir "$HOME/Developer"
target="$BROWSE_RESULT/$name"

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

  FastAPI)
    copy_template_dir "$repo_root/Templates/FastAPI"
    sed -i '' "s|FROM python:[^-]*-slim|FROM python:${version}-slim|" "$target/Dockerfile"
    ;;

  Vue)
    echo "Running npm create vite (Vue) via Docker — this may take a minute..."
    docker run --rm -v "$target:/app" -w /app "node:${version}-alpine" \
      sh -c "npm create vite@latest . -- --template vue"
    for f in Dockerfile docker-compose.yml .dockerignore; do
      src="$repo_root/Templates/Vue/$f"
      [[ -f "$src" ]] && safe_copy_file "$src" "$target/$f"
    done
    sed -i '' "s|node:20-alpine|node:${version}-alpine|g" "$target/Dockerfile"
    ;;

  NextJS)
    echo "Running create-next-app via Docker — this may take a minute..."
    docker run --rm -v "$target:/app" -w /tmp "node:${version}-alpine" \
      sh -c "npx create-next-app@latest myapp --ts --eslint --tailwind --src-dir --app --skip-install && cp -r myapp/. /app/"
    for f in Dockerfile docker-compose.yml .dockerignore; do
      src="$repo_root/Templates/NextJS/$f"
      [[ -f "$src" ]] && safe_copy_file "$src" "$target/$f"
    done
    sed -i '' "s|node:20-alpine|node:${version}-alpine|g" "$target/Dockerfile"
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

