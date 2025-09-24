# slwoggy Development Container

This directory contains the development container configuration for the slwoggy C++20 logging library. The devcontainer provides a consistent, pre-configured development environment that works in GitHub Codespaces, VS Code Remote-Containers, and other compatible tools.

## Features

### Included Software
- **Ubuntu 24.04 LTS** - Latest stable Ubuntu base
- **GCC 13** - Full C++20 support with latest features
- **Clang 18** - Alternative compiler with excellent diagnostics  
- **CMake 3.28+** - Latest build system
- **Development Tools**: GDB, Valgrind, Clang-format, Clang-tidy
- **Utilities**: Git, curl, python3, and common development tools

### VS Code Integration
- **C++ Extensions**: IntelliSense, debugging, code navigation
- **CMake Tools**: Project configuration and build integration
- **Catch2 Test Adapter**: Integrated test discovery and running
- **GitHub Extensions**: Copilot, Pull Requests, and CLI
- **Pre-configured Settings**: C++20 standard, formatting, build paths

### Permissions & Security
- **Non-root user**: Runs as `vscode` user for security
- **Proper permissions**: Workspace files owned by container user
- **Debugging support**: `SYS_PTRACE` capability for GDB/LLDB
- **Bind mount compatibility**: Works with Windows, macOS, Linux hosts

## Quick Start

### GitHub Codespaces (Recommended)
1. Go to the repository on GitHub
2. Click the green "Code" button
3. Select "Codespaces" tab
4. Click "Create codespace on main"
5. Wait for container to build and start
6. Run `./build.sh Debug` to build the project

### VS Code Remote-Containers
1. Install the "Remote-Containers" extension
2. Clone this repository locally
3. Open the repository in VS Code
4. When prompted, click "Reopen in Container"
5. Wait for container to build and setup to complete
6. Start developing!

### Docker Compose (Advanced)
```bash
# For more control over the environment
cd .devcontainer
docker-compose up -d
docker-compose exec slwoggy-dev bash
```

## Development Workflow

### Building
```bash
# Debug build with all features enabled
./build.sh Debug

# Release build for performance testing
./build.sh Release

# Memory check build with sanitizers
./build.sh MemCheck
```

### Testing
```bash
cd build
ctest --verbose

# Or run individual tests
./tests/test_log
./tests/test_rotation
./tests/test_log_structured
```

### Code Quality
```bash
# Format all code
find . -name "*.hpp" -o -name "*.cpp" | xargs clang-format -i

# Static analysis
clang-tidy include/*.hpp -- -std=c++20 -Iinclude
```

### Debugging
- Set breakpoints in VS Code and press F5 to debug
- Or use GDB directly: `gdb ./build/bin/slwoggy_demo`
- Valgrind integration: `valgrind --leak-check=full ./build/bin/slwoggy_demo`

## Container Architecture

```
┌─────────────────────────────────────────────────────────────┐
│ Ubuntu 24.04 LTS Container                                  │
├─────────────────────────────────────────────────────────────┤
│ Development Tools:                                          │
│ • GCC 13.x (C++20 default)      • CMake 3.28+             │
│ • Clang 18.x (alternative)      • Ninja Build             │
│ • GDB, LLDB, Valgrind          • Python 3.12+             │
├─────────────────────────────────────────────────────────────┤
│ VS Code Extensions:                                         │
│ • C++ IntelliSense              • CMake Tools              │
│ • Catch2 Test Adapter           • GitHub Integration       │
│ • Clang Format/Tidy             • Hex Editor               │
├─────────────────────────────────────────────────────────────┤
│ User Environment:                                           │
│ • Non-root 'vscode' user        • Proper file permissions  │
│ • Sudo access for system tasks  • Pre-configured shell     │
└─────────────────────────────────────────────────────────────┘
```

## Troubleshooting

### Permission Issues
If you encounter permission errors:
```bash
# Fix workspace ownership
sudo chown -R vscode:vscode /workspace

# For Windows hosts, ensure proper line endings
git config core.autocrlf input
```

### Build Issues
```bash
# Clean and rebuild
rm -rf build
./build.sh Debug

# Check compiler versions
gcc --version
cmake --version
```

### Container Issues
```bash
# Rebuild container completely
# In VS Code: Ctrl+Shift+P -> "Remote-Containers: Rebuild Container"

# For Docker Compose:
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

### Port Forwarding
The devcontainer exposes common development ports:
- `8080` - Web servers, APIs
- `3000` - Development servers
- `5000` - Applications, services

Ports are automatically forwarded in Codespaces and can be manually forwarded in VS Code.

## Customization

### Adding Tools
Edit `.devcontainer/Dockerfile` to add system packages:
```dockerfile
RUN apt-get update && apt-get install -y your-package
```

### VS Code Settings
Modify `.devcontainer/devcontainer.json`:
```json
"customizations": {
    "vscode": {
        "settings": {
            "your.setting": "value"
        },
        "extensions": [
            "your.extension"
        ]
    }
}
```

### Environment Variables
Add to `remoteEnv` in `devcontainer.json`:
```json
"remoteEnv": {
    "YOUR_VAR": "value"
}
```

## Performance Notes

### Container Size
- Base image: ~1.5GB (Ubuntu 24.04 + development tools)
- Build cache friendly: Layers optimized for rebuilds
- Volume mounts: Source code not copied, uses bind mounts

### Build Performance
- Multi-core builds: Uses all available CPU cores
- Ccache: Consider adding for faster rebuilds
- Ninja: Available as faster alternative to Make

### Memory Usage
- Minimum RAM: 2GB (4GB recommended)
- Heavy IntelliSense: Can use 1GB+ for large codebases
- Debug builds: Require more memory than release

## Support

For issues specific to the devcontainer setup:
1. Check the troubleshooting section above
2. Ensure Docker/Podman is properly installed
3. Verify VS Code Remote-Containers extension is updated
4. Check GitHub Codespaces documentation for cloud-specific issues

For slwoggy library issues, see the main project README and documentation.