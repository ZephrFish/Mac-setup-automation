#!/bin/bash

# 1Password CLI Setup and Integration
# Provides secure credential management for development

echo "Setting up 1Password CLI integration..."

# Check if 1Password CLI is installed
if ! command -v op &> /dev/null; then
    echo "Installing 1Password CLI..."
    brew install --cask 1password 1password-cli
else
    echo "1Password CLI already installed"
fi

# Enable biometric unlock for CLI
echo "Enabling biometric unlock for 1Password CLI..."
op account add --address my.1password.com --email "" 2>/dev/null || true

# Create helper scripts directory
mkdir -p ~/Tools/1password-helpers

# Create SSH agent integration script
cat > ~/Tools/1password-helpers/setup-ssh-agent.sh << 'EOF'
#!/bin/bash

# Configure 1Password SSH Agent
echo "Setting up 1Password SSH agent..."

# Add to ~/.ssh/config
mkdir -p ~/.ssh
if ! grep -q "IdentityAgent" ~/.ssh/config 2>/dev/null; then
    cat >> ~/.ssh/config << 'SSH_CONFIG'
Host *
    IdentityAgent "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
SSH_CONFIG
    echo "SSH config updated"
fi

echo "1Password SSH agent configured"
echo "Note: Add your SSH keys to 1Password and enable the SSH agent in 1Password settings"
EOF

# Create environment variable loader
cat > ~/Tools/1password-helpers/op-env.sh << 'EOF'
#!/bin/bash

# Load environment variables from 1Password
# Usage: source op-env.sh <item-name>

if [ -z "$1" ]; then
    echo "Usage: source op-env.sh <item-name>"
    return 1
fi

echo "Loading environment variables from 1Password item: $1"

# Ensure signed in
if ! op account get &>/dev/null; then
    eval $(op signin)
fi

# Load variables
eval $(op item get "$1" --format json | op inject)
echo "Environment variables loaded"
EOF

# Create secure .env loader
cat > ~/Tools/1password-helpers/load-env.sh << 'EOF'
#!/bin/bash

# Load .env.op template files with 1Password references
# Usage: source load-env.sh [.env.op file]

ENV_FILE="${1:-.env.op}"

if [ ! -f "$ENV_FILE" ]; then
    echo "Error: $ENV_FILE not found"
    return 1
fi

echo "Loading environment from $ENV_FILE with 1Password..."

# Ensure signed in
if ! op account get &>/dev/null; then
    eval $(op signin)
fi

# Process the template and export variables
while IFS= read -r line; do
    if [[ ! "$line" =~ ^[[:space:]]*# && ! -z "$line" ]]; then
        # Process 1Password references
        processed_line=$(echo "$line" | op inject)
        export $processed_line
    fi
done < "$ENV_FILE"

echo "Environment loaded from $ENV_FILE"
EOF

# Create Git credential helper
cat > ~/Tools/1password-helpers/git-credential-1password.sh << 'EOF'
#!/bin/bash

# 1Password Git Credential Helper
# Integrates Git with 1Password for secure credential storage

echo "Configuring Git to use 1Password..."

# Set up Git to use 1Password for HTTPS credentials
git config --global credential.helper osxkeychain
git config --global credential.helper '!op plugin run -- git credential-osxkeychain'

echo "Git configured to use 1Password"
echo "Note: Ensure 1Password CLI integration is enabled in 1Password settings"
EOF

# Create AWS credential helper
cat > ~/Tools/1password-helpers/aws-1password.sh << 'EOF'
#!/bin/bash

# AWS credentials from 1Password
# Usage: source aws-1password.sh <profile-name>

PROFILE="${1:-default}"

echo "Loading AWS credentials for profile: $PROFILE"

# Ensure signed in
if ! op account get &>/dev/null; then
    eval $(op signin)
fi

# Get credentials from 1Password
AWS_ACCESS_KEY_ID=$(op item get "AWS-$PROFILE" --fields access_key_id 2>/dev/null)
AWS_SECRET_ACCESS_KEY=$(op item get "AWS-$PROFILE" --fields secret_access_key 2>/dev/null)
AWS_SESSION_TOKEN=$(op item get "AWS-$PROFILE" --fields session_token 2>/dev/null || echo "")

if [ -z "$AWS_ACCESS_KEY_ID" ]; then
    echo "Error: Could not find AWS credentials for profile $PROFILE in 1Password"
    return 1
fi

export AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY
[ ! -z "$AWS_SESSION_TOKEN" ] && export AWS_SESSION_TOKEN

echo "AWS credentials loaded for profile: $PROFILE"
EOF

# Create database connection helper
cat > ~/Tools/1password-helpers/db-connect.sh << 'EOF'
#!/bin/bash

# Database connection using 1Password
# Usage: db-connect.sh <database-name>

DB_NAME="$1"

if [ -z "$DB_NAME" ]; then
    echo "Usage: db-connect.sh <database-name>"
    exit 1
fi

echo "Connecting to database: $DB_NAME"

# Ensure signed in
if ! op account get &>/dev/null; then
    eval $(op signin)
fi

# Get database credentials
DB_HOST=$(op item get "DB-$DB_NAME" --fields host 2>/dev/null)
DB_PORT=$(op item get "DB-$DB_NAME" --fields port 2>/dev/null)
DB_USER=$(op item get "DB-$DB_NAME" --fields username 2>/dev/null)
DB_PASS=$(op item get "DB-$DB_NAME" --fields password 2>/dev/null)
DB_DATABASE=$(op item get "DB-$DB_NAME" --fields database 2>/dev/null)

if [ -z "$DB_HOST" ]; then
    echo "Error: Could not find database $DB_NAME in 1Password"
    exit 1
fi

# Determine database type and connect
DB_TYPE=$(op item get "DB-$DB_NAME" --fields type 2>/dev/null || echo "postgres")

case "$DB_TYPE" in
    postgres|postgresql)
        PGPASSWORD="$DB_PASS" psql -h "$DB_HOST" -p "${DB_PORT:-5432}" -U "$DB_USER" -d "$DB_DATABASE"
        ;;
    mysql|mariadb)
        mysql -h "$DB_HOST" -P "${DB_PORT:-3306}" -u "$DB_USER" -p"$DB_PASS" "$DB_DATABASE"
        ;;
    mongodb)
        mongosh "mongodb://$DB_USER:$DB_PASS@$DB_HOST:${DB_PORT:-27017}/$DB_DATABASE"
        ;;
    *)
        echo "Unsupported database type: $DB_TYPE"
        exit 1
        ;;
esac
EOF

# Make all helper scripts executable
chmod +x ~/Tools/1password-helpers/*.sh

# Add 1Password functions to zsh configuration
cat >> ~/.zshrc.custom << 'EOF'

# 1Password CLI Integration
export OP_BIOMETRIC_UNLOCK_ENABLED=true

# Quick signin alias
alias ops='eval $(op signin)'

# Environment loading
alias openv='source ~/Tools/1password-helpers/op-env.sh'
alias loadenv='source ~/Tools/1password-helpers/load-env.sh'

# Database connections
alias dbconnect='~/Tools/1password-helpers/db-connect.sh'

# AWS profiles
alias awsop='source ~/Tools/1password-helpers/aws-1password.sh'

# Get password to clipboard
opp() {
    if [ -z "$1" ]; then
        echo "Usage: opp <item-name> [field]"
        return 1
    fi
    op item get "$1" --fields "${2:-password}" | pbcopy
    echo "Password copied to clipboard"
}

# Get TOTP code
otp() {
    if [ -z "$1" ]; then
        echo "Usage: otp <item-name>"
        return 1
    fi
    op item get "$1" --otp
}

# Create secure note
opnote() {
    if [ -z "$1" ]; then
        echo "Usage: opnote <title>"
        return 1
    fi
    op item create --category "Secure Note" --title "$1"
}

# Quick secret retrieval
ops_get() {
    op item get "$1" --fields "$2"
}

# List all items in vault
oplist() {
    op item list --format json | jq -r '.[] | "\(.title) [\(.category)]"'
}
EOF

echo "1Password CLI integration complete!"
echo ""
echo "Next steps:"
echo "  1. Sign in to 1Password CLI: eval \$(op signin)"
echo "  2. Configure SSH agent: ~/Tools/1password-helpers/setup-ssh-agent.sh"
echo "  3. Set up Git credentials: ~/Tools/1password-helpers/git-credential-1password.sh"
echo ""
echo "Available commands:"
echo "   ops         - Sign in to 1Password"
echo "   opp <item>  - Copy password to clipboard"
echo "   otp <item>  - Get TOTP code"
echo "   openv       - Load environment variables from 1Password"
echo "   dbconnect   - Connect to database using 1Password credentials"
echo "   awsop       - Load AWS credentials from 1Password"