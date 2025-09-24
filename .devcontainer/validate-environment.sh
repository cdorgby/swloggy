#!/bin/bash

# validate-environment.sh - Quick validation of devcontainer environment
# Run this inside a devcontainer to verify everything is working correctly

set -e

echo "🔍 Validating slwoggy devcontainer environment..."
echo "=================================================="

# Test 1: Basic tools
echo "📋 1. Checking development tools..."
REQUIRED_TOOLS=(gcc g++ clang clang++ cmake git python3)
OPTIONAL_TOOLS=(ninja gdb valgrind)

echo "  Required tools:"
for tool in "${REQUIRED_TOOLS[@]}"; do
    if command -v "$tool" &> /dev/null; then
        printf "    ✅ %-10s: %s\n" "$tool" "$(command -v "$tool")"
    else
        printf "    ❌ %-10s: Not found\n" "$tool"
        exit 1
    fi
done

echo "  Optional tools:"
for tool in "${OPTIONAL_TOOLS[@]}"; do
    if command -v "$tool" &> /dev/null; then
        printf "    ✅ %-10s: %s\n" "$tool" "$(command -v "$tool")"
    else
        printf "    ⚠️  %-10s: Not found (optional)\n" "$tool"
    fi
done

# Test 2: Compiler versions
echo ""
echo "🔧 2. Checking compiler versions..."
GCC_VERSION=$(gcc --version | head -n1 | grep -oE '[0-9]+\.[0-9]+' | head -n1)
CLANG_VERSION=$(clang --version | head -n1 | grep -oE '[0-9]+\.[0-9]+' | head -n1)
CMAKE_VERSION=$(cmake --version | head -n1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')

printf "  ✅ GCC:   %s (required: >= 13.0)\n" "$GCC_VERSION"
printf "  ✅ Clang: %s (required: >= 18.0)\n" "$CLANG_VERSION" 
printf "  ✅ CMake: %s (required: >= 3.11)\n" "$CMAKE_VERSION"

# Test 3: C++20 support
echo ""
echo "🧪 3. Testing C++20 support..."
cat > /tmp/cpp20_quick_test.cpp << 'EOF'
#include <concepts>
#include <iostream>
template<std::integral T> void test(T) { std::cout << "OK"; }
int main() { test(42); return 0; }
EOF

if g++ -std=c++20 -o /tmp/cpp20_test /tmp/cpp20_quick_test.cpp 2>/dev/null; then
    if /tmp/cpp20_test 2>/dev/null | grep -q "OK"; then
        echo "  ✅ C++20 compilation and execution works"
    else
        echo "  ❌ C++20 execution failed"  
        exit 1
    fi
else
    echo "  ❌ C++20 compilation failed"
    exit 1
fi

# Test 4: Workspace permissions
echo ""
echo "🔐 4. Checking workspace permissions..."

# Determine the workspace directory (either /workspace or current directory)
if [ -d "/workspace" ] && [ "$(pwd)" = "/workspace" ]; then
    WORKSPACE_DIR="/workspace"
else
    WORKSPACE_DIR="$(pwd)"
fi

echo "  ℹ️  Working directory: $WORKSPACE_DIR"

if [ -w "$WORKSPACE_DIR" ]; then
    echo "  ✅ Workspace is writable"
else
    echo "  ❌ Workspace is not writable"
    exit 1
fi

if touch "$WORKSPACE_DIR/.test_permissions" 2>/dev/null; then
    rm -f "$WORKSPACE_DIR/.test_permissions"
    echo "  ✅ Can create/delete files in workspace"
else
    echo "  ❌ Cannot create files in workspace"
    exit 1
fi

# Test 5: User environment
echo ""
echo "👤 5. Checking user environment..."
if [ "$(whoami)" = "vscode" ]; then
    echo "  ✅ Running as 'vscode' user"
else
    echo "  ⚠️  Running as '$(whoami)' (expected: vscode)"
fi

echo "  ℹ️  UID: $(id -u), GID: $(id -g)"
echo "  ℹ️  Home: $HOME"

# Test 6: Quick build test
echo ""
echo "🏗️  6. Testing slwoggy build system..."

# Use current directory instead of hardcoded /workspace
CURRENT_DIR="$(pwd)"
cd "$CURRENT_DIR"

if [ -f "CMakeLists.txt" ]; then
    echo "  ✅ Found CMakeLists.txt"
    
    # Test quick cmake configure (don't build, just configure)
    rm -rf /tmp/quick_build_test
    mkdir -p /tmp/quick_build_test
    cd /tmp/quick_build_test
    
    if cmake "$CURRENT_DIR" -DCMAKE_BUILD_TYPE=Debug -DSLWOGGY_BUILD_TESTS=OFF -DSLWOGGY_BUILD_EXAMPLES=OFF &>/dev/null; then
        echo "  ✅ CMake configuration successful"
    else
        echo "  ❌ CMake configuration failed"
        exit 1
    fi
    
    cd "$CURRENT_DIR"
    rm -rf /tmp/quick_build_test
else
    echo "  ❌ CMakeLists.txt not found"
    exit 1
fi

if [ -f "build.sh" ] && [ -x "build.sh" ]; then
    echo "  ✅ build.sh is present and executable"
else
    echo "  ❌ build.sh not found or not executable"
    exit 1
fi

# Cleanup
rm -f /tmp/cpp20_quick_test.cpp /tmp/cpp20_test

echo ""
echo "🎉 Environment validation completed successfully!"
echo ""
echo "✨ Your devcontainer is ready for slwoggy development!"
echo ""
echo "📚 Next steps:"
echo "   • Run './build.sh Debug' to build with tests and examples"
echo "   • Run 'cd build && ctest' to run the test suite"
echo "   • See DEV_QUICKSTART.md for more development commands"
echo ""
echo "🚀 Happy coding!"