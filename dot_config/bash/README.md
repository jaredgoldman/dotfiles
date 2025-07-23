# Modular Bash Configuration

This directory contains a modular bash configuration that replaces the original monolithic `.bashrc` file.

## Structure

```
.config/bash/
├── init.sh                    # Main entrypoint (sourced by ~/.bashrc)
├── README.md                  # This documentation file
├── display/
│   └── font-config.sh        # Screen resolution detection and font configuration
├── aliases/
│   └── general.sh            # Command aliases (ls, grep, networking, etc.)
├── functions/
│   ├── brightness.sh         # Display brightness control functions
│   ├── git.sh               # Git utility functions (irebase, gcp, etc.)
│   ├── images.sh            # Image processing functions (HEIC conversion, PNG optimization)
│   ├── osf.sh               # OSF/Work-specific functions (remote mounting, AWS logs)
│   ├── packages.sh          # Package management functions
│   ├── ssh.sh               # SSH key management and agent functions
│   └── translations.sh      # Spanish-English translation functions
├── environment/
│   └── variables.sh         # Environment variables and PATH configuration
└── security/
    └── keychain.sh          # SSH keychain initialization
```

## Usage

The main `.bashrc` file now simply sources `~/.config/bash/init.sh`, which in turn loads all the modular configuration files.

## Benefits

- **Modularity**: Each functional area is separated into its own file
- **Maintainability**: Easy to find and modify specific configurations
- **Organization**: Logical grouping of related functions and settings
- **Extensibility**: Easy to add new modules or disable existing ones

## Backup

The original `.bashrc` has been backed up to `~/.bashrc.backup`.

## Adding New Modules

To add a new module:

1. Create a new file in the appropriate directory (or create a new directory)
2. Add a `source` line in `init.sh` to load your new module
3. Make sure your module file starts with `#!/bin/bash` and appropriate comments

## Disabling Modules

To temporarily disable a module, comment out the corresponding `source` line in `init.sh`. 