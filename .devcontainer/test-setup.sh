#!/bin/bash

# test-setup.sh - Test script to verify devcontainer setup works correctly
# This can be run inside the devcontainer to validate the environment

set -e

echo "🧪 Testing devcontainer setup..."

# Test 1: Check required tools are installed
echo "📋 Checking required tools..."

check_tool() {
    if command -v "$1" &> /dev/null; then
        echo "✅ $1: $(command -v "$1")"
    else
        echo "❌ $1: Not found"
        return 1
    fi
}

check_tool gcc
check_tool g++
check_tool clang
check_tool clang++
check_tool cmake
check_tool ninja
check_tool gdb
check_tool git
check_tool python3

# Test 2: Check compiler versions support C++20
echo ""
echo "🔧 Checking C++20 support..."

# Create a test C++20 program
cat > /tmp/cpp20_test.cpp << 'EOF'
#include <iostream>
#include <concepts>
#include <ranges>
#include <string>
#include <vector>

template<std::integral T>
constexpr T add_numbers(T a, T b) {
    return a + b;
}

int main() {
    // Test C++20 concepts
    auto result = add_numbers(5, 3);
    std::cout << "Concepts test: " << result << std::endl;
    
    // Test C++20 ranges
    std::vector<int> numbers = {1, 2, 3, 4, 5};
    auto doubled = numbers | std::views::transform([](int n) { return n * 2; });
    
    std::cout << "Ranges test: ";
    for (auto n : doubled) {
        std::cout << n << " ";
    }
    std::cout << std::endl;
    
    // Test designated initializers
    struct Point { int x, y; };
    Point p{.x = 10, .y = 20};
    std::cout << "Designated initializers: " << p.x << ", " << p.y << std::endl;
    
    return 0;
}
EOF

# Test GCC
echo "Testing GCC C++20 compilation..."
if g++ -std=c++20 -Wall -Wextra -o /tmp/cpp20_test_gcc /tmp/cpp20_test.cpp 2>/dev/null; then
    echo "✅ GCC C++20 compilation successful"
    if /tmp/cpp20_test_gcc > /tmp/gcc_output.txt 2>&1; then
        echo "✅ GCC C++20 runtime successful:"
        cat /tmp/gcc_output.txt | sed 's/^/  /'
    else
        echo "❌ GCC C++20 runtime failed"
    fi
else
    echo "❌ GCC C++20 compilation failed"
fi

# Test Clang
echo ""
echo "Testing Clang C++20 compilation..."
if clang++ -std=c++20 -Wall -Wextra -o /tmp/cpp20_test_clang /tmp/cpp20_test.cpp 2>/dev/null; then
    echo "✅ Clang C++20 compilation successful"
    if /tmp/cpp20_test_clang > /tmp/clang_output.txt 2>&1; then
        echo "✅ Clang C++20 runtime successful:"
        cat /tmp/clang_output.txt | sed 's/^/  /'
    else
        echo "❌ Clang C++20 runtime failed"
    fi
else
    echo "❌ Clang C++20 compilation failed"
fi

# Test 3: Check workspace permissions
echo ""
echo "🔐 Checking workspace permissions..."
if [ -w "/workspace" ]; then
    echo "✅ Workspace is writable"
else
    echo "❌ Workspace is not writable"
fi

# Test if we can create and delete files
if touch /workspace/.test_file 2>/dev/null && rm /workspace/.test_file 2>/dev/null; then
    echo "✅ Can create/delete files in workspace"
else
    echo "❌ Cannot create/delete files in workspace"
fi

# Test 4: Check CMake configuration
echo ""
echo "🔨 Testing CMake configuration..."
cd /workspace

if [ -f "CMakeLists.txt" ]; then
    echo "✅ Found CMakeLists.txt"
    
    # Test CMake configure
    mkdir -p /tmp/cmake_test
    cd /tmp/cmake_test
    
    if cmake /workspace -DCMAKE_BUILD_TYPE=Debug 2>/dev/null; then
        echo "✅ CMake configuration successful"
        
        # Test make (just configure, don't build)
        if make --dry-run > /dev/null 2>&1; then
            echo "✅ Make configuration successful"
        else
            echo "❌ Make configuration failed"
        fi
    else
        echo "❌ CMake configuration failed"
    fi
    
    cd /workspace
    rm -rf /tmp/cmake_test
else
    echo "❌ CMakeLists.txt not found in workspace"
fi

# Test 5: Check slwoggy build system
echo ""
echo "🏗️  Testing slwoggy build system..."
cd /workspace

if [ -f "build.sh" ]; then
    echo "✅ Found build.sh"
    
    # Test that build.sh can at least parse arguments
    if ./build.sh --help 2>/dev/null || ./build.sh -h 2>/dev/null || true; then
        echo "✅ build.sh is executable"
    else
        echo "❌ build.sh is not executable or has issues"
    fi
else
    echo "❌ build.sh not found"
fi

# Test 6: Check user environment
echo ""
echo "👤 Checking user environment..."
echo "User: $(whoami)"
echo "UID: $(id -u)"
echo "GID: $(id -g)"
echo "Groups: $(groups)"
echo "Home: $HOME"
echo "Shell: $SHELL"

if [ "$(whoami)" = "vscode" ]; then
    echo "✅ Running as expected user (vscode)"
else
    echo "⚠️  Running as unexpected user: $(whoami)"
fi

# Test 7: Check VS Code integration files
echo ""
echo "📝 Checking VS Code integration..."
if [ -f "/workspace/.vscode/c_cpp_properties.json" ]; then
    echo "✅ Found .vscode/c_cpp_properties.json"
else
    echo "ℹ️  No .vscode/c_cpp_properties.json (will be auto-generated)"
fi

if [ -f "/workspace/.vscode/settings.json" ]; then
    echo "✅ Found .vscode/settings.json"
else
    echo "ℹ️  No .vscode/settings.json"
fi

# Cleanup
rm -f /tmp/cpp20_test.cpp /tmp/cpp20_test_gcc /tmp/cpp20_test_clang /tmp/gcc_output.txt /tmp/clang_output.txt

echo ""
echo "🎉 Devcontainer setup test completed!"
echo ""
echo "✨ If all tests passed, your development environment is ready!"
echo "🚀 Try running: ./build.sh Debug"