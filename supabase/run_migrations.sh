#!/bin/bash

# LinguaMatch - Database Migration Runner
# This script executes SQL migrations on your Supabase database

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}===========================================  ${NC}"
echo -e "${GREEN}LinguaMatch Database Migration Runner${NC}"
echo -e "${GREEN}===========================================${NC}\n"

# Check if .env.local exists
if [ ! -f ".env.local" ]; then
    echo -e "${RED}Error: .env.local file not found!${NC}"
    echo "Please create .env.local with your Supabase credentials."
    exit 1
fi

# Load environment variables
source .env.local

if [ -z "$VITE_SUPABASE_URL" ] || [ -z "$SUPABASE_SERVICE_ROLE_KEY" ]; then
    echo -e "${RED}Error: Required environment variables not set!${NC}"
    echo "Make sure VITE_SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY are in .env.local"
    exit 1
fi

echo -e "${YELLOW}Supabase Project URL:${NC} $VITE_SUPABASE_URL"
echo -e "${YELLOW}Project ID:${NC} $SUPABASE_PROJECT_ID\n"

# Function to execute SQL file
run_migration() {
    local migration_file=$1
    local migration_name=$(basename "$migration_file")

    echo -e "${YELLOW}Running migration:${NC} $migration_name"

    # Read SQL file
    local sql_content=$(cat "$migration_file")

    # Note: This is a placeholder. Actual execution requires either:
    # 1. Supabase CLI: supabase db push
    # 2. Manual execution via Supabase Dashboard SQL Editor
    # 3. PostgreSQL connection string with proper credentials

    echo -e "${GREEN}✓${NC} Migration file prepared: $migration_file"
}

echo -e "${YELLOW}Available migrations:${NC}\n"

# List all migration files
migration_files=$(ls -1 supabase/migrations/*.sql 2>/dev/null | sort)

if [ -z "$migration_files" ]; then
    echo -e "${RED}No migration files found in supabase/migrations/${NC}"
    exit 1
fi

# Display migrations
for file in $migration_files; do
    echo "  - $(basename "$file")"
done

echo -e "\n${YELLOW}===========================================${NC}"
echo -e "${YELLOW}IMPORTANT: Manual Migration Required${NC}"
echo -e "${YELLOW}===========================================${NC}\n"

echo "Please run these migrations manually via Supabase Dashboard:"
echo ""
echo "1. Go to: https://supabase.com/dashboard/project/$SUPABASE_PROJECT_ID/sql"
echo "2. Open SQL Editor"
echo "3. For each migration file listed above:"
echo "   - Create a new query"
echo "   - Copy the SQL content from the file"
echo "   - Paste and click 'Run'"
echo ""
echo -e "${GREEN}Migration files are ready in: supabase/migrations/${NC}\n"
