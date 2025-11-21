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
4. **`tt archive <TASK NAME>`** - Archive a task (stops it if running)
5. **`tt ls`** - List all unarchived tasks with checkbox-style format
6. **`tt ls -a`** - List ALL tasks including archived ones
7. **`tt show <TASK NAME>`** - Show task details with entries table
8. **`tt cancel <TASK NAME>`** - Cancel running task and delete the running entry
9. **`tt delete <TASK NAME>`** - Delete task and all its entries permanently

### Key Features

- Tasks are uniquely identified by name
- **Task names can contain spaces** (e.g., `./tt start Fix login bug`)
- Multiple time entries per task (start/stop multiple times)
- Only one running entry per task at a time
- Time displayed in human-readable format (e.g., "1hr 34m")
- **Checkbox-style list format**: `[ ]` not running, `[~]` running, `[x]` archived
- **List archived tasks** with `-a` flag
- Notes editable with $EDITOR environment variable
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
