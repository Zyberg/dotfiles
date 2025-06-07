#!bash

init_nix_direnv() {
    local flake_name=$1
    local repo_dir=$2

    if [[ -z "$flake_name" ]]; then
        echo "Error: Flake name must be provided as the first parameter."
        return 1
    fi

    if [[ ! -d "$repo_dir" ]]; then
        echo "Error: $repo_dir is not a valid directory."
        return 1
    fi

    local flake_path="~/fabrikas/devshells/$flake_name"
   # if [[ ! -d "$flake_path" ]]; then
   #     echo "Error: Flake path $flake_path does not exist."
   #     return 1
   # fi

    cd "$repo_dir" || return 1

    local git_exclude_file=".git/info/exclude"

    # Ensure .git/info/exclude exists
    if [[ ! -f "$git_exclude_file" ]]; then
        echo "Error: $git_exclude_file does not exist in $repo_dir."
        return 1
    fi

    echo "Adding directory .local-config to ignore at $git_exclude_file"
    grep -qxF '.local-config/' "$git_exclude_file" || echo '.local-config/' >> "$git_exclude_file"

    # Check if a .envrc already exists
    if [[ -f ".envrc" ]]; then
        # Case 1: .envrc exists
        if [[ ! -f ".envrc.local" ]]; then
            echo "use flake $flake_path" >> .envrc.local
            echo "Created .envrc.local"
        fi

        # Add a link from .envrc to .envrc.local
        if ! grep -q "source_env .envrc.local" .envrc; then
            echo 'source_env ".envrc.local"' >> .envrc
            echo "Linked .envrc.local in .envrc"
        fi

        # Ignore .envrc.local and .direnv/
        grep -qxF '.envrc.local' "$git_exclude_file" || echo '.envrc.local' >> "$git_exclude_file"
        grep -qxF '.direnv/' "$git_exclude_file" || echo '.direnv/' >> "$git_exclude_file"
        echo "Updated $git_exclude_file to ignore .envrc.local and .direnv/"
    else
        # Case 2: .envrc does not exist
        echo "use flake $flake_path" > .envrc
        echo "Created .envrc with 'use nix'"

        # Ignore .envrc and .direnv/
        grep -qxF '.envrc' "$git_exclude_file" || echo '.envrc' >> "$git_exclude_file"
        grep -qxF '.direnv/' "$git_exclude_file" || echo '.direnv/' >> "$git_exclude_file"
        echo "Updated $git_exclude_file to ignore .envrc and .direnv/"
    fi

    # Ensure direnv allows the new .envrc
    direnv allow .

    echo "Initialization complete for $repo_dir."
}

flake_name=$1
shift

# Loop through provided directories
for dir in "$@"; do
    init_nix_direnv "$flake_name" "$dir"
done
