#!/bin/bash
set -e # Exit on error

# Define colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if environment variable is provided
if [ $# -ne 1 ]; then
    echo -e "${RED}Error: Please specify an environment ('dev' or 'prod')${NC}"
    echo "Usage: $0 <environment>"
    exit 1
fi

ENVIRONMENT=$1

# Validate environment
if [ "$ENVIRONMENT" != "dev" ] && [ "$ENVIRONMENT" != "prod" ]; then
    echo -e "${RED}Error: Environment must be 'dev' or 'prod'${NC}"
    exit 1
fi

echo -e "${YELLOW}Setting up workspace for $ENVIRONMENT environment...${NC}"

# Initialize Terraform if not already initialized
if [ ! -d ".terraform" ]; then 
    echo -e "${YELLOW}Initializing Terraform...${NC}"
    terraform init
fi

# Check if workspace exists
WORKSPACE_EXISTS=$(terraform workspace list | grep $ENVIRONMENT || echo "")

if [ -z "$WORKSPACE_EXISTS" ]; then
    echo -e "${YELLOW}Creating new workspace: $ENVIRONMENT${NC}"
    terraform workspace new $ENVIRONMENT
else
    echo -e "${YELLOW}Selecting existing workspace: $ENVIRONMENT${NC}"
    terraform workspace select $ENVIRONMENT
fi

# Verify correct workspace
CURRENT_WORKSPACE=$(terraform workspace show)
if [ "$CURRENT_WORKSPACE" != "$ENVIRONMENT" ]; then
    echo -e "${RED}Error: Failed to select workspace $ENVIRONMENT${NC}"
    exit 1
fi

echo -e "${GREEN}Workspace $ENVIRONMENT is ready!${NC}"
echo -e "${YELLOW}Run terraform commands with -var-file=environments/$ENVIRONMENT.tfvars${NC}"

# Example command
echo -e "${GREEN}Example: terraform plan -var-file=environments/$ENVIRONMENT.tfvars${NC}"