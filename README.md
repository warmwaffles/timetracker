# Time Tracker Quick Reference

## Commands

### Starting and Stopping Tasks
```bash
./tt start ENG-1234              # Start a task
./tt start Fix login bug         # Task names can have spaces
./tt stop ENG-1234               # Stop a task
./tt stop Fix login bug          # Stop task with spaces
```

### Viewing Tasks
```bash
./tt ls                          # List all unarchived tasks
./tt ls -a                       # List ALL tasks (including archived)
./tt show ENG-1234               # Show task details and time entries
./tt show Fix login bug          # Show task with spaces
```

### Managing Tasks
```bash
./tt note ENG-1234               # Edit task notes in $EDITOR
./tt edit ENG-1234               # Edit task name and entries in $EDITOR
./tt archive ENG-1234            # Archive task (hides from ls, keeps data)
./tt cancel ENG-1234             # Cancel running entry (deletes current entry only)
./tt delete ENG-1234             # Delete task and ALL entries permanently
```

## Command Differences

### Archive vs Delete
- **archive**: Stops the task if running, marks as archived, keeps all data, hides from `ls`
- **delete**: Permanently removes the task and ALL its time entries from database

### Cancel vs Delete
- **cancel**: Removes only the currently running entry (must be running)
- **delete**: Removes the entire task and all its entries (running or not)

### Note vs Edit
- **note**: Edit only the task notes/description in $EDITOR
- **edit**: Edit task name AND all time entries in $EDITOR (rename, add, delete, modify entries)

## Output Format

### List Output (`tt ls`)
```
[ ] ENG-123 --- 20m             # Not running
[~] ENG-4569 --- 1hr 34m        # Running
[ ] ENG-895 --- 100hr           # Not running
```

### List Output with -a flag (`tt ls -a`)
```
[ ] ENG-123 --- 20m             # Not running
[~] ENG-4569 --- 1hr 34m        # Running
[ ] ENG-895 --- 100hr           # Not running
[x] ENG-999 --- 50hr            # Archived
```

**Legend:**
- `[ ]` = Task not running
- `[~]` = Task currently running
- `[x]` = Task archived (only shown with `-a` flag)

### Show Output (`tt show`)
```
ENG-123 *running*

Here are some notes about the task.
Worked on things

| Start At            | Stop At             | Elapsed |
| ------------------- | ------------------- | ------- |
| 2025-11-21 13:29:00 | 2025-11-21 13:49:00 | 20m     |
| 2025-11-21 14:00:00 |                     | 5m      |
| Total               |                     | 25m     |
```

## Database Location

1. **Local (project-specific)**: `.timetracker/database.db` 
   - Searches current directory and parent directories (like git)
   
2. **Global (fallback)**: `~/.local/state/timetracker/database.db`
   - Used when no `.timetracker` directory found

## Edit Command Format

When you run `tt edit <TASK NAME>`, a file opens with this format:

```
TaskName
edit 123 2025-11-21 12:00:00 to 2025-11-21 13:00:00
edit 456 2025-11-21 14:00:00 running
add 2025-11-22 10:00:00 to 2025-11-22 11:00:00
delete 789

# Commands:
#   edit <ID> <START> to <STOP>       - Edit an existing entry
#   edit <ID> <START> running         - Mark entry as running
#   add <START> to <STOP>             - Add new completed entry
#   add <START> running               - Add new running entry
#   delete <ID>                       - Delete an entry
#
# Shortcuts: e=edit, a=add, d=delete
# Only the last entry can be 'running'
# Times must be in format: YYYY-MM-DD HH:MM:SS
```

**Edit Operations:**
- Change task name on first line (checks for conflicts)
- Modify entry times using `edit` or `e`
- Add new entries using `add` or `a`
- Delete entries using `delete` or `d`
- Only the last entry can be marked `running`
- All changes are validated before saving

## Tips

- Task names are unique - starting an existing task name won't create a duplicate
- You can start/stop the same task multiple times - each creates a new entry
- Running tasks include current time in duration calculations
- Time format: hours and minutes only (e.g., "3hr 17m")
- All commands support task names with spaces
- Use `edit` command to fix mistakes or adjust time entries after the fact
