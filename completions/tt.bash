# Bash completion for tt (timetracker)
# Install to: ~/.local/share/bash-completion/completions/tt
# Or source from ~/.bashrc: source /path/to/tt.bash

# Main completion function for tt command
_tt_completion() {
    local cur prev words cword
    
    # Use _init_completion if available (from bash-completion package)
    if declare -F _init_completion >/dev/null 2>&1; then
        _init_completion || return
    else
        # Fallback if bash-completion not available
        COMPREPLY=()
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
        words=("${COMP_WORDS[@]}")
        cword=$COMP_CWORD
    fi
    
    # Helper function to find database path (mirrors Python logic)
    _tt_find_database() {
        local current_dir="$PWD"
        local search_dir="$current_dir"
        
        # Walk up directory tree looking for .timetracker/database.db
        while [[ "$search_dir" != "/" ]]; do
            if [[ -d "$search_dir/.timetracker" ]]; then
                echo "$search_dir/.timetracker/database.db"
                return 0
            fi
            search_dir="$(dirname "$search_dir")"
        done
        
        # Fall back to XDG_HOME (note: tt uses XDG_HOME, not XDG_DATA_HOME)
        local xdg_home="${XDG_HOME:-$HOME}"
        echo "$xdg_home/.local/state/timetracker/database.db"
        return 0
    }
    
    # Helper function to get task names from database
    # Usage: _tt_get_tasks [include_archived]
    # include_archived: 0 (default) or 1
    _tt_get_tasks() {
        local include_archived="${1:-0}"
        local db_path
        local query
        local tasks
        
        # Find database path
        db_path="$(_tt_find_database)"
        
        # Return nothing if database doesn't exist (common before first use)
        if [[ ! -f "$db_path" ]]; then
            return 0
        fi
        
        # Check if sqlite3 is available
        if ! command -v sqlite3 >/dev/null 2>&1; then
            return 0
        fi
        
        # Build query based on archived flag
        if [[ "$include_archived" -eq 1 ]]; then
            query="SELECT name FROM tasks ORDER BY name;"
        else
            query="SELECT name FROM tasks WHERE archived = 0 ORDER BY name;"
        fi
        
        # Execute query and return results
        # Suppress errors to avoid breaking completion experience
        sqlite3 "$db_path" "$query" 2>/dev/null
    }
    
    # First argument: complete command names
    if [[ $cword -eq 1 ]]; then
        local commands="start stop note edit archive cancel delete show ls"
        COMPREPLY=($(compgen -W "$commands" -- "$cur"))
        return 0
    fi
    
    # Second argument: complete task names based on command
    if [[ $cword -eq 2 ]]; then
        local command="${words[1]}"
        local tasks
        local task
        
        case "$command" in
            start|stop|note|edit|archive|cancel)
                # Non-archived tasks only
                tasks="$(_tt_get_tasks 0)"
                ;;
            show|delete)
                # All tasks including archived
                tasks="$(_tt_get_tasks 1)"
                ;;
            ls)
                # No task name completion for ls
                return 0
                ;;
            *)
                # Unknown command, no completion
                return 0
                ;;
        esac
        
        # Generate completions from task list
        # We need to handle task names with spaces properly
        local IFS=$'\n'
        local escaped_tasks=()
        
        for task in $tasks; do
            # Only include tasks that match the current prefix
            if [[ "$task" == "$cur"* ]]; then
                # Escape the task name for bash completion
                escaped_tasks+=("$(printf %q "$task")")
            fi
        done
        
        COMPREPLY=("${escaped_tasks[@]}")
        return 0
    fi
    
    # No completion for subsequent arguments
    return 0
}

# Register the completion function for tt command
complete -F _tt_completion tt
