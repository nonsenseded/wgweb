# This file contains utility functions that are used by the install and uninstall scripts to perform common tasks.

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to print messages in a specific color
print_message() {
    local color="$1"
    shift
    echo -e "${color}$*${NC}"
}

# Function to install a package if it's not already installed
install_package() {
    if ! command_exists "$1"; then
        apt-get install -y "$1"
    else
        print_message "${GREEN}" "$1 is already installed."
    fi
}

# Function to remove a package
remove_package() {
    apt-get remove -y --purge "$1"
}

# Function to create a directory if it doesn't exist
create_directory() {
    if [ ! -d "$1" ]; then
        mkdir -p "$1"
    fi
}

# Function to check if a file exists
file_exists() {
    [ -f "$1" ]
}

# Function to prompt for confirmation
confirm_action() {
    read -p "$1 [y/N] " -n 1 -r
    echo
    [[ ! $REPLY =~ ^[Yy]$ ]] && return 1
    return 0
}