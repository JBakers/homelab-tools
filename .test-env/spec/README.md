# BATS Test Suite for Homelab-Tools

Complete test coverage using BATS (Bash Automated Testing System).

## Structure

```
spec/
├── README.md                    # This file
├── support/
│   ├── helpers.sh              # Common helper functions
│   ├── setup.sh                # Test setup/fixtures
│   └── template-assertions.sh  # Template validation assertions
├── motd-generation.bats        # Generate MOTD tests
├── motd-deployment.bats        # Deploy/undeploy tests
├── motd-lifecycle.bats         # End-to-end workflows
├── menu-navigation.bats        # Interactive menu tests
├── ascii-art.bats              # ASCII art validation
├── error-handling.bats         # Error scenario tests
├── integration.bats            # Complex workflows
└── performance.bats            # Speed/load tests
```

## Running Tests

### Run all tests
```bash
bats spec/*.bats
```

### Run specific test file
```bash
bats spec/motd-generation.bats
```

### Run with verbose output
```bash
bats -r spec/
```

### Run single test
```bash
bats spec/motd-generation.bats --filter "service name detection"
```

## Writing Tests

### Basic test structure
```bash
@test "descriptive test name" {
    # Setup
    run command_under_test arg1 arg2
    
    # Assertions
    [ "$status" -eq 0 ]           # Exit code
    [[ "$output" =~ "pattern" ]]  # Output pattern
    [ -f "/path/to/file" ]        # File exists
}
```

### Using helpers
```bash
@test "test with helpers" {
    source "$BATS_TEST_DIRNAME/support/helpers.sh"
    
    setup_mock_env
    run some_command
    assert_template_exists "service"
}
```

## Test Coverage

| Category | Tests | Status |
|----------|-------|--------|
| Menu Navigation | 12 | Planned |
| MOTD Generation | 18 | Planned |
| Deployment | 15 | Planned |
| Undeploy | 6 | Planned |
| Templates | 12 | Planned |
| Integration | 17 | Planned |
| **TOTAL** | **80** | **Phase 3** |

## Documentation

- See [TESTING-TODO.md](../../TESTING-TODO.md) for complete testing plan
- See [../../.github/copilot-instructions.md](.github/copilot-instructions.md) for development rules
