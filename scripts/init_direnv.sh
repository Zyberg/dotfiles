#!bash

init_nix_direnv() {
    local repo_dir=$1

    if [[ ! -d "$repo_dir" ]]; then
        echo "Error: $repo_dir is not a valid directory."
        return 1
    fi

    cd "$repo_dir" || return 1

    local git_exclude_file=".git/info/exclude"

    # Ensure .git/info/exclude exists
    if [[ ! -f "$git_exclude_file" ]]; then
        echo "Error: $git_exclude_file does not exist in $repo_dir."
        return 1
    fi

    # Check if a .envrc already exists
    if [[ -f ".envrc" ]]; then
        # Case 1: .envrc exists
        if [[ ! -f ".envrc.local" ]]; then
            touch .envrc.local
            echo "Created empty .envrc.local"
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
        echo "use nix" > .envrc
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

# Loop through provided directories
for dir in "$@"; do
    init_nix_direnv "$dir"
done
