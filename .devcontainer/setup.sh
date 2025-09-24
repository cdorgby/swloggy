#!/bin/bash

# setup.sh - Post-create setup script for slwoggy devcontainer
# This script runs after the container is created to configure the development environment

set -e

echo "🚀 Setting up slwoggy development environment..."

# Ensure we're in the workspace directory
cd /workspace

# Verify C++20 compiler support
echo "📋 Checking compiler versions..."
echo "GCC: $(gcc --version | head -n1)"
echo "Clang: $(clang --version | head -n1)"
echo "CMake: $(cmake --version | head -n1)"

# Test C++20 support with a simple compilation test
echo "🧪 Testing C++20 support..."
cat > /tmp/cpp20_test.cpp << 'EOF'
#include <iostream>
#include <concepts>
#include <ranges>

template<std::integral T>
void test_concepts(T value) {
    std::cout << "C++20 concepts work: " << value << std::endl;
}

int main() {
    // Test C++20 features
    auto numbers = std::views::iota(1, 6) | std::views::transform([](int i) { return i * 2; });
    std::cout << "C++20 ranges work: ";
    for (auto n : numbers) {
        std::cout << n << " ";
    }
    std::cout << std::endl;
    
    test_concepts(42);
    std::cout << "✅ C++20 support confirmed!" << std::endl;
    return 0;
}
EOF

if g++ -std=c++20 -o /tmp/cpp20_test /tmp/cpp20_test.cpp 2>/dev/null && /tmp/cpp20_test; then
    echo "✅ C++20 compilation test passed!"
else
    echo "❌ C++20 compilation test failed - there may be issues with the compiler setup"
fi

# Clean up test files
rm -f /tmp/cpp20_test.cpp /tmp/cpp20_test

# Configure git if not already configured
if [ -z "$(git config --global user.name)" ]; then
    echo "⚙️  Setting up default git configuration..."
    git config --global user.name "Developer"
    git config --global user.email "dev@example.com"
    echo "ℹ️  You can update git config later with your real name and email"
fi

# Ensure proper permissions for the workspace
echo "🔧 Setting up workspace permissions..."
sudo chown -R vscode:vscode /workspace 2>/dev/null || true

# Create common build directory
echo "📁 Creating build directory..."
mkdir -p build

# Test the build system
echo "🏗️  Testing build system..."
if ./build.sh Debug; then
    echo "✅ Build system test passed!"
else
    echo "❌ Build system test failed - check dependencies"
    exit 1
fi

# Install additional development tools via pip if needed
echo "🐍 Installing additional Python tools..."
python3 -m pip install --user --upgrade pip
python3 -m pip install --user conan || echo "Conan installation skipped (optional)"

# Set up shell completion
echo "🐚 Setting up shell completions..."
echo 'source /etc/bash_completion' >> ~/.bashrc || true

# Create a quick reference file
echo "📝 Creating development quick reference..."
cat > DEV_QUICKSTART.md << 'EOF'
# slwoggy Development Quick Start

## Build Commands
```bash
# Debug build with tests and examples
./build.sh Debug

# Release build  
./build.sh Release

# MemCheck build with sanitizers
./build.sh MemCheck

# Profile build
./build.sh Profile
```

## CMake Direct Usage
```bash
mkdir build && cd build
cmake .. -DCMAKE_BUILD_TYPE=Debug -DSLWOGGY_BUILD_TESTS=ON -DSLWOGGY_BUILD_EXAMPLES=ON
make -j$(nproc)
```

## Testing
```bash
cd build
ctest --verbose
# Or run individual tests
./tests/test_log
./tests/test_rotation
```

## Debugging
```bash
# With GDB
gdb ./bin/slwoggy_demo
# With Valgrind  
valgrind --leak-check=full ./bin/slwoggy_demo
```

## Code Quality
```bash
# Format code
clang-format -i include/*.hpp src/*.cpp tests/*.cpp

# Static analysis
clang-tidy include/*.hpp src/*.cpp -- -std=c++20 -Iinclude
```

## Useful Directories
- `include/` - Header files
- `src/` - Source files and examples
- `tests/` - Test files  
- `build/` - Build output
- `docs/` - Documentation

## VS Code Integration
- C++ IntelliSense configured for C++20
- CMake tools available
- Debugging configured
- Catch2 test discovery enabled
EOF

echo ""
echo "🎉 Development environment setup complete!"
echo ""
echo "📚 Quick reference created: DEV_QUICKSTART.md"
echo "🏗️  To get started, try: ./build.sh Debug"
echo "🧪 To run tests: cd build && ctest"
echo ""
echo "Happy coding! 🚀"