# Supercharge Your Dart & Flutter Development Experience with the Dart MCP Server

> **A comprehensive Flutter example demonstrating the power of the Dart MCP Server for AI-enhanced development workflows**

This project recreates and expands upon the examples from the [official Medium article](https://medium.com/flutter/supercharge-your-dart-flutter-development-experience-with-the-dart-mcp-server-2edcc8107b49) by the Flutter team, showcasing how the Dart MCP (Model Context Protocol) Server transforms the way AI assistants interact with your Flutter development environment.

## 🚀 What is the Dart MCP Server?

The [Dart MCP Server](https://github.com/dart-lang/ai/tree/main/pkgs/dart_mcp_server) is a powerful bridge between AI coding assistants and the Dart/Flutter ecosystem. It provides a standardized way for AI models to:

- 🔍 **Analyze and fix errors** in your project's code
- 🔧 **Introspect and interact** with your running application
- 📦 **Search pub.dev** for the best packages for your use case
- 📝 **Manage package dependencies** in your pubspec.yaml
- 🧪 **Run tests** and analyze the results
- 🔥 **Trigger hot reloads** programmatically
- 🌳 **Inspect widget trees** for debugging

## 🎯 Interactive Demo Features

This Flutter app provides hands-on demonstrations of MCP capabilities:

### 1. 📊 Real-time Chart Visualization
**Demonstrates: Package Search & Dependency Management**

```dart
// Example: AI assistant finds and adds charting package
// Prompt: "Find a suitable package to add a line chart that maps button presses over time"

// MCP Server Response:
// 1. Uses pub_dev_search tool to find popular charting libraries
// 2. Suggests syncfusion_flutter_charts (high rating, good documentation)
// 3. Uses pubspec_manager tool to add dependency
// 4. Generates implementation code
```

The app includes a live chart showing button press data over time, powered by the `syncfusion_flutter_charts` package that would be discovered and added via MCP.

### 2. ⚠️ Layout Error Detection & Fixing
**Demonstrates: Runtime Error Detection & Widget Inspection**

```dart
// Example: AI assistant detects and fixes RenderFlex overflow
// Prompt: "Check for and fix static and runtime analysis issues. Check for and fix any layout issues."

// MCP Server Tools Used:
// 1. error_inspector: Gets current runtime errors
// 2. widget_inspector: Analyzes widget tree structure
// 3. Applies fix (e.g., wrapping Row with Expanded or using Wrap)
```

Click the "Simulate Error" button to see how MCP would detect layout issues, then "Fix Layout" to see the resolution.

### 3. 🔥 Hot Reload Integration
**Demonstrates: Development Workflow Enhancement**

The app showcases programmatic hot reload capabilities that MCP enables for AI assistants.

### 4. 🛠️ MCP Tools Reference
**Visual guide to all available MCP server tools with descriptions**

## 📋 Requirements

- **Dart SDK**: 3.0.0+ (3.9.0+ recommended for full MCP functionality)
- **Flutter**: 3.0.0+ (3.35.0+ recommended for full MCP functionality)
- **MCP-compatible AI tool** (see supported tools below)

## 🚀 Quick Start

### 1. Clone and Setup
```bash
git clone <repository-url>
cd mcp-dart-example
flutter pub get
```

### 2. Run the Demo App
```bash
flutter run -d chrome --web-port=8080
# Or for mobile:
flutter run
```

### 3. Install Dart MCP Server
```bash
# Install the Dart MCP Server globally
dart pub global activate dart_mcp_server

# Verify installation
dart_mcp_server --help
```

## 🤖 Supported AI Development Tools

This example works seamlessly with MCP-enabled AI assistants:

### GitHub Copilot in VS Code
1. Install the [MCP extension for VS Code](https://marketplace.visualstudio.com/items?itemName=modelcontextprotocol.mcp)
2. Configure the Dart MCP Server in your settings
3. Use natural language prompts to interact with your Flutter project

### Cursor
1. Enable MCP support in Cursor settings
2. Add Dart MCP Server configuration
3. Start using AI-powered Flutter development

### Gemini CLI
```bash
# Install Gemini CLI with MCP support
npm install -g @google/gemini-cli

# Configure with Dart MCP Server
gemini config set mcp.servers.dart ./dart_mcp_server
```

### Gemini Code Assist in VS Code
Follow the [official setup guide](https://cloud.google.com/code/docs/vscode/gemini-code-assist) and add MCP configuration.

### Firebase Studio
The Firebase team's experimental [Firebase MCP Server](https://firebase.blog/posts/2025/05/firebase-mcp-server/) works alongside the Dart MCP Server for full-stack development.

## 💬 Example AI Assistant Prompts

Try these prompts with your MCP-enabled AI assistant:

### 🔍 Error Detection and Fixing
```
"Check for and fix static and runtime analysis issues. Check for and fix any layout issues."
```
**What happens:**
1. AI uses `error_inspector` to scan for runtime errors
2. Uses `widget_inspector` to analyze layout structure
3. Identifies RenderFlex overflow or other issues
4. Automatically applies fixes (e.g., adding Flexible widgets, using Wrap instead of Row)
5. Verifies the fix resolved the issue

### 📦 Package Discovery and Integration
```
"Find a suitable package to add a line chart that maps the number of button presses over time."
```
**What happens:**
1. AI uses `pub_dev_search` to find charting packages
2. Evaluates options based on popularity, maintenance, and features
3. Suggests best option (e.g., `syncfusion_flutter_charts`)
4. Uses `pubspec_manager` to add dependency
5. Runs `flutter pub get`
6. Generates implementation code with proper imports and usage

### 🎨 UI Enhancement
```
"Add a beautiful loading animation when searching for packages."
```
**What happens:**
1. AI analyzes current UI structure
2. Suggests appropriate loading widget
3. Implements state management for loading states
4. Adds smooth animations and transitions

### 🧪 Testing and Quality
```
"Add comprehensive tests for the counter functionality and chart updates."
```
**What happens:**
1. AI analyzes existing code structure
2. Creates widget tests for UI components
3. Adds unit tests for business logic
4. Uses `flutter test` to verify all tests pass

## 🛠️ MCP Server Tools Reference

| Tool | Purpose | Example Usage |
|------|---------|---------------|
| `pub_dev_search` | Find packages on pub.dev | Search for "chart", "animation", "http client" |
| `pubspec_manager` | Manage dependencies | Add/remove packages, update versions |
| `error_inspector` | Get runtime errors | Detect layout overflows, null pointer exceptions |
| `widget_inspector` | Analyze widget tree | Debug layout issues, performance problems |
| `hot_reload` | Trigger hot reload | Apply changes without full restart |
| `test_runner` | Execute tests | Run unit tests, widget tests, integration tests |
| `analyzer` | Static code analysis | Find linting issues, unused imports |

## 🎬 The Dart MCP Server in Action

### Scenario 1: Fixing a Runtime Layout Error

**The Problem:** You build a beautiful UI, run the app, and see the infamous yellow-and-black stripes of a RenderFlex overflow error.

**Traditional Approach:**
1. Manually debug the widget tree
2. Identify the problematic Row/Column
3. Try different solutions (Flexible, Expanded, Wrap)
4. Test and iterate

**With MCP Server:**
```
Prompt: "Check for and fix static and runtime analysis issues. Check for and fix any layout issues."
```

**What the AI does:**
1. 🔍 Uses `error_inspector` to see the current runtime errors
2. 🌳 Uses `widget_inspector` to understand the layout causing overflow
3. 🔧 Applies appropriate fix (e.g., wrapping with Flexible or using Wrap)
4. ✅ Verifies the fix resolved the error

### Scenario 2: Adding New Functionality with Package Search

**The Problem:** You need to add a chart to your app but don't know which package to use.

**Traditional Approach:**
1. Search pub.dev manually
2. Compare different packages
3. Read documentation
4. Add to pubspec.yaml
5. Run pub get
6. Write implementation code

**With MCP Server:**
```
Prompt: "Find a suitable package to add a line chart that maps the number of button presses over time."
```

**What the AI does:**
1. 📦 Uses `pub_dev_search` to find popular charting libraries
2. 🤔 Evaluates options based on ratings, maintenance, and features
3. 💡 Suggests `syncfusion_flutter_charts` (or similar)
4. ➕ Uses `pubspec_manager` to add the package
5. 🔄 Runs `pub get`
6. 💻 Generates complete implementation code
7. 🐛 Self-corrects any syntax errors

## 🔧 Configuration Examples

### VS Code Settings (settings.json)
```json
{
  "mcp.servers": {
    "dart": {
      "command": "dart_mcp_server",
      "args": ["--project-root", "${workspaceFolder}"]
    }
  }
}
```

### Cursor Configuration
```json
{
  "mcp": {
    "servers": {
      "dart-mcp": {
        "command": "dart_mcp_server",
        "args": ["--project-root", "."]
      }
    }
  }
}
```

## 🚧 What's Coming Next?

The Dart MCP Server is rapidly evolving. Upcoming features include:

- 🔍 **Enhanced widget inspection** with performance metrics
- 🧪 **Advanced testing capabilities** with automatic test generation
- 📊 **Code quality metrics** and suggestions
- 🔗 **Integration with Firebase services** via Firebase MCP Server
- 🎨 **UI/UX analysis** and improvement suggestions

## 📚 Learn More

- 📖 [Official Dart MCP Server Documentation](https://dart.dev/tools/mcp-server)
- 🌐 [Model Context Protocol Specification](https://modelcontextprotocol.io/introduction)
- 🔥 [Firebase MCP Server](https://firebase.blog/posts/2025/05/firebase-mcp-server/)
- 📝 [Original Medium Article](https://medium.com/flutter/supercharge-your-dart-flutter-development-experience-with-the-dart-mcp-server-2edcc8107b49)
- 💻 [Dart MCP Server GitHub Repository](https://github.com/dart-lang/ai/tree/main/pkgs/dart_mcp_server)

## 🤝 Contributing

This example project welcomes contributions! Whether you want to:
- 🐛 Fix bugs or improve existing demos
- ✨ Add new MCP capability demonstrations
- 📚 Improve documentation
- 🧪 Add more comprehensive tests

Please feel free to open issues and pull requests.

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

---

**Ready to supercharge your Flutter development with AI?** 🚀

Start by running this demo app, then set up the Dart MCP Server with your favorite AI development tool. Experience firsthand how AI assistants can transform your development workflow from reactive debugging to proactive, intelligent development assistance.
