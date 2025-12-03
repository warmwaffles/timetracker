# Tab Completion for tt (Time Tracker)

This directory contains shell completion scripts for the `tt` time tracking command-line tool.

## Overview

The completion scripts provide intelligent tab completion for:

- **Command names**: `tt <TAB>` shows all available commands
- **Task names**: `tt start <TAB>` shows task names from your database
- **Context-aware filtering**: Different commands show different task lists based on context

### Completion Behavior

| Command | Completes With |
|---------|----------------|
| `start` | Non-archived tasks only |
| `stop` | Non-archived tasks only |
| `note` | Non-archived tasks only |
| `edit` | Non-archived tasks only |
| `archive` | Non-archived tasks only |
| `cancel` | Non-archived tasks only |
| `delete` | **All tasks (including archived)** |
| `show` | **All tasks (including archived)** |
| `ls` | No task name completion |

## Requirements

- **sqlite3**: Command-line tool for querying the task database
  - Usually pre-installed on most systems
  - Install with: `sudo apt install sqlite3` (Debian/Ubuntu) or `brew install sqlite3` (macOS)

## Quick Install (Automatic)

The easiest way to install completions is using the automated installer:

```bash
cd completions
./install.sh
```

This will:
1. Auto-detect your shell(s) (Fish and/or Bash)
2. Install completions for detected shells
3. Create necessary directories if they don't exist
4. Provide activation instructions

### Install Options

```bash
./install.sh           # Auto-detect and install for all shells
./install.sh --fish    # Install Fish completion only
./install.sh --bash    # Install Bash completion only
./install.sh --uninstall  # Remove all installed completions
./install.sh --help    # Show help message
```

## Manual Installation

If you prefer to install manually, follow the instructions for your shell:

### Fish Shell

1. Copy the completion file:
   ```bash
   mkdir -p ~/.config/fish/completions
   cp completions/tt.fish ~/.config/fish/completions/
   ```

2. Reload completions:
   ```bash
   # Either restart Fish, or run:
   source ~/.config/fish/completions/tt.fish
   ```

3. Test it:
   ```fish
   tt <TAB>  # Should show command names
   ```

### Bash Shell

1. Copy the completion file:
   ```bash
   mkdir -p ~/.local/share/bash-completion/completions
   cp completions/tt.bash ~/.local/share/bash-completion/completions/tt
   ```
   
   **Note**: The destination file should be named `tt` (without the `.bash` extension).

2. Reload completions:
   ```bash
   # Either restart Bash, or run:
   source ~/.local/share/bash-completion/completions/tt
   ```
   
   Alternatively, you can add this to your `~/.bashrc`:
   ```bash
   source ~/.local/share/bash-completion/completions/tt
   ```

3. Test it:
   ```bash
   tt <TAB>  # Should show command names
   ```

## Usage Examples

Once installed, you can use tab completion in the following ways:

### Command Name Completion

```bash
$ tt <TAB>
start  stop  note  edit  archive  cancel  delete  show  ls
```

### Task Name Completion

```bash
# Complete task names (single match)
$ tt start ENG-12<TAB>
$ tt start ENG-1234

# Show multiple matches
$ tt start ENG-<TAB>
ENG-1234  ENG-1289  ENG-5000

# Works with partial matches
$ tt stop Fix<TAB>
$ tt stop "Fix login bug"
```

### Context-Aware Completion

```bash
# Non-archived tasks only (for start, stop, etc.)
$ tt start <TAB>
ENG-1234  ENG-5000  PROJ-100

# All tasks including archived (for show, delete)
$ tt show <TAB>
ENG-1234  ENG-5000  PROJ-100  OLD-999  ARCHIVED-123

$ tt delete OLD-<TAB>
OLD-999  OLD-1000  # Includes archived tasks
```

### Task Names with Spaces

The completion scripts properly handle task names containing spaces:

```bash
$ tt start Fix<TAB>
$ tt start "Fix login bug"  # Properly quoted

$ tt show Implement<TAB>
$ tt show "Implement new feature"
```

## How It Works

### Database Location

The completion scripts mirror the database path finding logic from the main `tt` script:

1. Search current directory and parent directories for `.timetracker/database.db`
2. Fall back to `$XDG_HOME/.local/state/timetracker/database.db` (or `$HOME/.local/state/timetracker/database.db`)

### Task Querying

Completions query the SQLite database directly:

**Non-archived tasks** (most commands):
```sql
SELECT name FROM tasks WHERE archived = 0 ORDER BY name;
```

**All tasks** (show and delete commands):
```sql
SELECT name FROM tasks ORDER BY name;
```

### Error Handling

The completion scripts fail silently if:
- Database doesn't exist (common before first use)
- `sqlite3` command is not available
- Database query fails for any reason

This ensures the shell completion experience is never broken by errors.

## Troubleshooting

### Completions Not Working

**Problem**: Tab completion doesn't work after installation.

**Solution**: 
- Restart your shell (close and reopen terminal)
- Or manually source the completion file:
  - Fish: `source ~/.config/fish/completions/tt.fish`
  - Bash: `source ~/.local/share/bash-completion/completions/tt`

### No Tasks Showing

**Problem**: Commands complete but no task names appear.

**Possible causes**:
1. **No database**: Have you created any tasks yet? Run `tt start test-task` to create your first task.
2. **Wrong directory**: Are you in the right project directory? The completion looks for `.timetracker/database.db` walking up from your current directory.
3. **sqlite3 missing**: Check if `sqlite3` is installed: `which sqlite3`

### sqlite3 Not Found

**Problem**: `sqlite3: command not found`

**Solution**: Install sqlite3:
```bash
# Debian/Ubuntu
sudo apt install sqlite3

# RHEL/CentOS/Fedora
sudo yum install sqlite

# macOS
brew install sqlite3

# Arch Linux
sudo pacman -S sqlite
```

### Task Names with Spaces Not Completing

**Problem**: Task names containing spaces don't complete properly.

**Solution**:
- Make sure you're using quotes when typing partial names with spaces
- Both completion scripts properly escape/quote task names with spaces
- Try: `tt start "Fix log"<TAB>` instead of `tt start Fix log<TAB>`

### Bash Completion Not Loading Automatically

**Problem**: Bash completion requires sourcing every time you open a new shell.

**Solution**: Add this line to your `~/.bashrc`:
```bash
[[ -f ~/.local/share/bash-completion/completions/tt ]] && source ~/.local/share/bash-completion/completions/tt
```

Or ensure your system's bash-completion package is properly configured (check `/etc/profile.d/bash_completion.sh`).

## Uninstallation

### Automatic Uninstall

```bash
cd completions
./install.sh --uninstall
```

### Manual Uninstall

Remove the completion files:

```bash
# Fish
rm ~/.config/fish/completions/tt.fish

# Bash
rm ~/.local/share/bash-completion/completions/tt
```

Then restart your shell or reload completions.

## Development

### File Structure

```
completions/
├── tt.fish       # Fish shell completion script
├── tt.bash       # Bash completion script
├── install.sh    # Automated installer/uninstaller
└── README.md     # This file
```

### Testing Completions

After making changes to completion scripts:

1. **Fish**: Reload with `source ~/.config/fish/completions/tt.fish`
2. **Bash**: Reload with `source ~/.local/share/bash-completion/completions/tt`

Test scenarios:
- `tt <TAB>` - Should show all command names
- `tt start <TAB>` - Should show non-archived tasks
- `tt show <TAB>` - Should show all tasks including archived
- `tt start ENG-<TAB>` - Should show tasks starting with "ENG-"
- Test with task names containing spaces

### Adding New Commands

If you add a new command to `tt`, update both completion scripts:

1. **tt.fish**: Add to the `complete -c tt` lines
2. **tt.bash**: Add to the `commands` list in the completion function

Decide whether the new command should:
- Show non-archived tasks only (like `start`, `stop`)
- Show all tasks including archived (like `show`, `delete`)
- Have no task name completion (like `ls`)

## Support

For issues, questions, or contributions related to tab completion:

1. Check the troubleshooting section above
2. Ensure you're using the latest version of the completion scripts
3. Test that `sqlite3` is installed and the database exists
4. Try manual installation if automatic installation fails

## License

These completion scripts are part of the tt (timetracker) project and follow the same license as the main project.
