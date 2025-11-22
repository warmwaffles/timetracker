# Time Tracker Implementation Summary

## Completed

The time tracker has been fully implemented according to the specification in `spec.md`.

## Implementation Details

### Core Script: `tt`

A single self-contained Python script with no external dependencies (uses only standard library).

### Database

- SQLite3 database with two tables: `tasks` and `entries`
- Database location follows this priority:
  1. `.timetracker/database.db` in current directory or any parent directory (like git)
  2. `$XDG_HOME/.local/state/timetracker/database.db` as fallback

### Commands Implemented

1. **`tt start <TASK NAME>`** - Starts tracking a task
2. **`tt stop <TASK NAME>`** - Stops tracking a task
3. **`tt note <TASK NAME>`** - Edit task notes in $EDITOR
4. **`tt edit <TASK NAME>`** - Edit task name and entries in $EDITOR
5. **`tt archive <TASK NAME>`** - Archive a task (stops it if running)
6. **`tt ls`** - List all unarchived tasks with checkbox-style format
7. **`tt ls -a`** - List ALL tasks including archived ones
8. **`tt show <TASK NAME>`** - Show task details with entries table
9. **`tt cancel <TASK NAME>`** - Cancel running task and delete the running entry
10. **`tt delete <TASK NAME>`** - Delete task and all its entries permanently

### Key Features

- Tasks are uniquely identified by name
- **Task names can contain spaces** (e.g., `./tt start Fix login bug`)
- Multiple time entries per task (start/stop multiple times)
- Only one running entry per task at a time
- Time displayed in human-readable format (e.g., "1hr 34m")
- **Checkbox-style list format**: `[ ]` not running, `[~]` running, `[x]` archived
- **List archived tasks** with `-a` flag
- Notes editable with $EDITOR environment variable
- **Interactive entry editing** with structured format in $EDITOR
- ISO8601 formatted timestamps in show command
- **Formatted table in show command** with separators, elapsed time per entry, and total row

## Usage

Make the script executable and use it:

```bash
chmod +x tt
./tt start ENG-1234
./tt start Fix login bug
./tt start this is a valid task name
./tt stop ENG-1234
./tt ls                          # List unarchived tasks
./tt ls -a                       # List ALL tasks (including archived)
./tt show Fix login bug
./tt edit ENG-1234              # Edit task name and entries
./tt archive ENG-1234
./tt delete Fix login bug
```

To use globally, add it to your PATH or create a symlink:

```bash
sudo ln -s $(pwd)/tt /usr/local/bin/tt
```

## Notes

- The database is created automatically on first use
- The `.timetracker` directory must exist for local tracking (script does not create it)
- All timestamps are stored as Unix timestamps (integers)
- Time calculations include currently running tasks
- Archived tasks are hidden from list view
- **Delete vs Archive**: `archive` hides tasks from list view but keeps data; `delete` permanently removes tasks and all entries
- **Cancel vs Delete**: `cancel` removes only the current running entry; `delete` removes the entire task and all its entries

### Edit Command Details

The `edit` command opens a structured file in $EDITOR allowing you to:
- **Rename tasks** - Edit the first line
- **Edit entry times** - Modify start/stop times with `edit` or `e` command
- **Delete entries** - Use `delete` or `d` command
- **Add new entries** - Use `add` or `a` command
- **Mark as running** - Use `running` instead of stop time (only last entry)

All changes are validated before committing:
- Task name conflicts are rejected
- Only the last entry can be marked "running"
- Stop times must be after start times
- Invalid timestamps are rejected
- All changes are atomic (transaction-based)
