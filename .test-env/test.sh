#!/bin/bash
set -euo pipefail

# ═══════════════════════════════════════════════════════════════════════════════
# HOMELAB-TOOLS TEST LAUNCHER
# Start Docker environment and run all tests
# ═══════════════════════════════════════════════════════════════════════════════

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BOLD='\033[1m'
RESET='\033[0m'

echo -e "${BOLD}${CYAN}╔══════════════════════════════════════════════════════════╗"
echo -e "║         🧪 HOMELAB-TOOLS TEST LAUNCHER                    ║"
echo -e "╚══════════════════════════════════════════════════════════╝${RESET}"
echo ""

# Check Docker
if ! command -v docker &>/dev/null; then
    echo -e "${RED}Error: Docker not installed${RESET}"
    echo "Install Docker: https://docs.docker.com/get-docker/"
    exit 1
fi

if ! docker info &>/dev/null; then
    echo -e "${RED}Error: Docker not running${RESET}"
    echo "Start Docker and try again."
    exit 1
fi

# Check docker-compose
if ! command -v docker-compose &>/dev/null && ! docker compose version &>/dev/null; then
    echo -e "${RED}Error: docker-compose not available${RESET}"
    exit 1
fi

# Use docker compose or docker-compose
if docker compose version &>/dev/null 2>&1; then
    COMPOSE="docker compose"
else
    COMPOSE="docker-compose"
fi

cd "$SCRIPT_DIR"

# Mode selection
MODE="${1:-full}"

case "$MODE" in
    build)
        echo -e "${YELLOW}Building test containers...${RESET}"
        $COMPOSE build
        echo -e "${GREEN}✓ Build complete${RESET}"
        ;;
    
    start)
        echo -e "${YELLOW}Starting test environment...${RESET}"
        $COMPOSE up -d
        echo -e "${GREEN}✓ Environment started${RESET}"
        echo ""
        echo "To run tests:"
        echo "  docker exec -it hlt-testhost /workspace/.test-env/run-tests.sh"
        ;;
    
    stop)
        echo -e "${YELLOW}Stopping test environment...${RESET}"
        $COMPOSE down
        echo -e "${GREEN}✓ Environment stopped${RESET}"
        ;;
    
    shell)
        echo -e "${YELLOW}Opening shell in test container...${RESET}"
        $COMPOSE up -d
        docker exec -it hlt-testhost /bin/bash
        ;;
    
    full|test)
        echo -e "${YELLOW}Building and starting test environment...${RESET}"
        $COMPOSE build
        $COMPOSE up -d
        
        echo ""
        echo -e "${YELLOW}Waiting for containers to be ready...${RESET}"
        sleep 3
        
        echo ""
        echo -e "${BOLD}Running tests...${RESET}"
        echo ""
        
        # Run tests inside container
        docker exec -it hlt-testhost /workspace/.test-env/run-tests.sh
        result=$?
        
        echo ""
        echo -e "${YELLOW}Stopping containers...${RESET}"
        $COMPOSE down
        
        exit $result
        ;;
    
    clean)
        echo -e "${YELLOW}Cleaning up...${RESET}"
        bash "$SCRIPT_DIR/cleanup.sh"
        ;;
    
    local)
        echo -e "${YELLOW}Running tests locally (no Docker)...${RESET}"
        echo ""
        bash "$SCRIPT_DIR/run-tests.sh"
        ;;
    
    *)
        echo "Usage: $0 [mode]"
        echo ""
        echo "Modes:"
        echo "  full    - Build, start, test, stop (default)"
        echo "  build   - Build containers only"
        echo "  start   - Start containers"
        echo "  stop    - Stop containers"
        echo "  shell   - Open shell in test container"
        echo "  test    - Same as 'full'"
        echo "  local   - Run tests locally (no Docker)"
        echo "  clean   - Remove containers and images"
        ;;
esac
