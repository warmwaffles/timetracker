# Fish shell completion for tt (timetracker)
# Install to: ~/.config/fish/completions/tt.fish

# Function to find the database path (mirrors Python logic from tt script)
function __tt_find_database
    # First, check for .timetracker directory in current or parent directories
    set -l current_dir (pwd)
    set -l search_dir $current_dir
    
    while test "$search_dir" != "/"
        if test -d "$search_dir/.timetracker"
            echo "$search_dir/.timetracker/database.db"
            return 0
        end
        set search_dir (dirname "$search_dir")
    end
    
    # Fall back to XDG_HOME (note: tt uses XDG_HOME, not XDG_DATA_HOME)
    set -l xdg_home $XDG_HOME
    if test -z "$xdg_home"
        set xdg_home $HOME
    end
    
    echo "$xdg_home/.local/state/timetracker/database.db"
    return 0
end

# Function to get task names from database
# Usage: __tt_get_tasks [--include-archived]
function __tt_get_tasks
    set -l include_archived 0
    
    # Check if --include-archived flag is passed
    if test (count $argv) -gt 0; and test "$argv[1]" = "--include-archived"
        set include_archived 1
    end
    
    # Find database path
    set -l db_path (__tt_find_database)
    
    # Return nothing if database doesn't exist (common before first use)
    if not test -f "$db_path"
        return 0
    end
    
    # Check if sqlite3 is available
    if not command -q sqlite3
        return 0
    end
    
    # Query database for task names
    set -l query
    if test $include_archived -eq 1
        set query "SELECT name FROM tasks ORDER BY name;"
    else
        set query "SELECT name FROM tasks WHERE archived = 0 ORDER BY name;"
    end
    
    # Execute query and return results (one per line)
    # Suppress errors to avoid breaking completion experience
    sqlite3 "$db_path" "$query" 2>/dev/null
end

# Complete command names (first argument)
complete -c tt -f -n "__fish_use_subcommand" -a "start" -d "Start tracking a task"
complete -c tt -f -n "__fish_use_subcommand" -a "stop" -d "Stop tracking a task"
complete -c tt -f -n "__fish_use_subcommand" -a "note" -d "Edit task notes"
complete -c tt -f -n "__fish_use_subcommand" -a "edit" -d "Edit task name and entries"
complete -c tt -f -n "__fish_use_subcommand" -a "archive" -d "Archive a task"
complete -c tt -f -n "__fish_use_subcommand" -a "cancel" -d "Cancel running task"
complete -c tt -f -n "__fish_use_subcommand" -a "delete" -d "Delete task permanently"
complete -c tt -f -n "__fish_use_subcommand" -a "show" -d "Show task details"
complete -c tt -f -n "__fish_use_subcommand" -a "ls" -d "List tasks"

# Complete task names for commands that need non-archived tasks only
complete -c tt -f -n "__fish_seen_subcommand_from start stop note edit archive cancel" -a "(__tt_get_tasks)"

# Complete task names for commands that include archived tasks
complete -c tt -f -n "__fish_seen_subcommand_from show delete" -a "(__tt_get_tasks --include-archived)"
