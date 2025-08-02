# Flowise Setup Guide for Aura AI Code Generation Factory

## FLOWISE SETUP GUIDE FOR PROMPT ORCHESTRATION - AURA PROJECT

### INTRODUCTION

This guide provides detailed instructions for setting up Flowise as the orchestration layer for the Aura project's AI Code Generation Factory. Flowise is an open-source visual tool built on LangChain.js that enables visual creation and management of AI workflows.

### SECTION 1: INSTALLATION & SETUP

#### Prerequisites

* Node.js version 18.15.0 or higher (LTS recommended)
* npm version 9.5.0 or higher (comes with Node.js)
* At least 4GB of RAM available
* Stable internet connection for downloading dependencies

#### Step-by-Step Installation

* Check Node.js version by opening PowerShell and running: node --version
* If Node.js is not installed or version is below 18.15.0, download from https://nodejs.org/
* Install Flowise globally using npm: npm install -g flowise
* Verify installation by running: flowise --version
* Create a dedicated directory for your Flowise workspace: mkdir C:\Users\fower\Desktop\Aura\ai_factory\flowise
* Navigate to the directory: cd C:\Users\fower\Desktop\Aura\ai_factory\flowise
* Initialize Flowise in the current directory: npx flowise start
* The system will automatically create necessary configuration files and start the server
* Default server will start on http://localhost:3000
* Open your web browser and navigate to http://localhost:3000 to access the Flowise UI
* You should see the Flowise dashboard with options to create new chatflows

#### Initial Configuration

* On first launch, Flowise will create a local SQLite database for storing your flows
* The default admin interface requires no authentication for local development
* For production use, consider setting up authentication via environment variables

### SECTION 2: CLAUDE SONNET 4 INTEGRATION

#### API Key Preparation

* Obtain your Anthropic API key from the Anthropic Console (https://console.anthropic.com/)
* Never hardcode API keys directly in your flows or configuration files
* Use environment variables for secure key management

#### Environment Variable Setup for Windows

* Create a .env file in your Flowise workspace directory: C:\Users\fower\Desktop\Aura\ai_factory\flowise\.env
* Add the following content to the .env file:
  ANTHROPIC_API_KEY=your_actual_api_key_here
  DATABASE_PATH=./database.sqlite
  OVERRIDE_DATABASE=false
  PORT=3000
* Save the file and restart Flowise by stopping the current process (Ctrl+C) and running: npx flowise start
* Alternatively, set system environment variables in Windows:
  * Open System Properties > Advanced > Environment Variables
  * Add new system variable: ANTHROPIC_API_KEY with your API key value
  * Restart PowerShell and run Flowise again

#### Adding Anthropic Provider in Flowise

* In the Flowise UI, navigate to the "Credentials" section (usually found in settings or sidebar)
* Click "Add New Credential"
* Select "Anthropic API" from the provider list
* Enter your credential name (e.g., "anthropic-main")
* Paste your API key in the designated field
* Test the connection by clicking "Test Connection" if available
* Save the credential for use in your flows

#### Verifying Claude Sonnet 4 Access

* Create a new chatflow by clicking "Add New Chatflow"
* In the nodes panel, look for "Chat Models" section
* You should see "Anthropic Chat Model" or "Claude" option available
* Drag the Anthropic Chat Model node to your canvas
* Click on the node to configure it
* In the model selection dropdown, verify that "claude-3-5-sonnet-20241022" or latest Sonnet 4 version appears
* Select your saved Anthropic credential from the dropdown
* The green checkmark should appear indicating successful configuration

### SECTION 3: CREATING A BASIC CODE GENERATION FLOW

#### Flow Architecture Planning

* Your basic flow will consist of: Input Node > Prompt Template > Claude Model > Output Parser > File Output
* This creates a simple pipeline for generating code based on user requirements

#### Step-by-Step Flow Creation

* Click "Add New Chatflow" in the Flowise dashboard
* Name your flow "Aura Code Generator - Basic Test"
* Set up the core nodes in the following order:

#### Node 1: Chat Prompt Template

* Drag "Chat Prompt Template" from the Prompts section to your canvas
* Configure the template with the following system prompt:
  "You are an expert software engineer working on the Aura project, a personal style assistant app. Generate clean, well-documented code following Flutter and Dart best practices. Always include detailed comments and follow the project's architectural patterns."
* Add a human message template:
  "Generate a {language} {component_type} for {description}. Include proper error handling and follow clean code principles."
* Save the template configuration

#### Node 2: Anthropic Chat Model

* Drag "Anthropic Chat Model" from Chat Models section to canvas
* Configure the model settings:
  * Model: claude-3-5-sonnet-20241022 (or latest Sonnet 4)
  * Temperature: 0.3 (for more consistent code generation)
  * Max Tokens: 4000 (sufficient for code generation)
  * Credential: Select your saved Anthropic credential
* Connect the Chat Prompt Template output to the Chat Model input

#### Node 3: Output Parser

* Add "String Output Parser" from Output Parsers section
* This ensures the model response is properly formatted as plain text
* Connect the Chat Model output to the String Output Parser input

#### Node 4: Custom Tool for File Writing (Advanced Configuration)

* Add "Custom Tool" node from Tools section
* Configure the tool to write output to files:
  * Tool Name: "FileWriter"
  * Tool Description: "Writes generated code to specified file path"
  * Function: Create a simple JavaScript function to write to files
  * Note: This requires additional configuration and may need custom implementation

#### Alternative: Manual Output Capture

* For initial testing, use the built-in "Final Answer" node
* Connect String Output Parser to Final Answer node
* This will display the generated code in the chat interface for manual copying

#### Testing Your Flow

* Click the "Test Flow" button or use the chat interface
* Enter test input variables:
  * language: "Dart"
  * component_type: "Widget"
  * description: "a reusable button component with custom styling for the Aura app"
* Execute the flow and verify Claude responds with appropriate Dart/Flutter code
* Check that the output includes proper documentation and follows Flutter conventions

### SECTION 4: TESTING FILE OUTPUT

#### Built-in File Output Limitations

* Standard Flowise nodes do not include direct file writing capabilities
* File operations require custom tool implementation or external integrations
* For production use, consider integrating with external APIs or services

#### Manual Output Capture Method

* Use the chat interface to execute your flow
* Copy the generated code from the Final Answer output
* Manually save to appropriate files in your Aura project structure
* Create test files in: C:\Users\fower\Desktop\Aura\apps\flutter_app\lib\widgets\generated\

#### Setting Up Custom File Writer (Advanced)

* Create a custom tool node with the following JavaScript function:
```
async function writeToFile(filename, content) {
  const fs = require('fs').promises;
  const path = require('path');
  const fullPath = path.join('C:/Users/fower/Desktop/Aura/generated_code/', filename);
  await fs.writeFile(fullPath, content, 'utf8');
  return `Code written to ${fullPath}`;
}
```
* Configure the tool to accept filename and content parameters
* Connect this tool after your output parser
* Test by generating a simple function and verifying file creation

#### Verification Steps

* Run your complete flow with a simple code generation request
* Verify that Claude Sonnet 4 responds with appropriate code
* Check that the output follows your prompt template instructions
* Confirm that any file writing (manual or automated) works correctly
* Test with different types of code generation requests (widgets, services, models)

### SECTION 5: BEST PRACTICES AND SECURITY

#### Security Considerations

* Never commit .env files with API keys to version control
* Add .env to your .gitignore file immediately
* Use different API keys for development and production environments
* Regularly rotate your API keys for security
* Monitor API usage in the Anthropic console

#### Performance Optimization

* Set appropriate temperature values (0.1-0.3) for code generation consistency
* Use reasonable max token limits to avoid unnecessary costs
* Implement caching for frequently used prompts
* Monitor token usage and optimize prompt length

#### Flow Management

* Use descriptive names for all flows and nodes
* Document your flows with clear descriptions
* Version control your flow exports
* Create separate flows for different code generation tasks
* Regularly backup your Flowise database

### SECTION 6: NEXT STEPS FOR AURA INTEGRATION

#### Expanding Your Code Generation Factory

* Create specialized flows for different Aura components:
  * Flutter widget generation
  * Dart model class creation
  * API service generation
  * State management code
* Develop prompt templates specific to Aura's architecture
* Integrate with your existing development workflow
* Set up automated testing for generated code

#### Integration with Aura Development Process

* Connect Flowise outputs to your Git workflow
* Create flows that generate code following Aura's style guide
* Implement validation steps for generated code quality
* Set up monitoring for code generation metrics

This completes the comprehensive setup guide for Flowise in your Aura AI Code Generation Factory. Follow these steps sequentially, and you'll have a functional prompt orchestration system ready for advanced AI-powered development workflows.

## APPENDIX: INITIAL PROMPT TEMPLATES FOR AURA CODE GENERATION

### Template 1: Generate Flutter Screen Widget

**Template Name:** Generate Flutter Screen Widget

**Template Description:** Creates a complete Flutter screen widget following Aura's Clean Architecture principles, Material 3 design system, and Riverpod v2 state management. This template generates the presentation layer component with proper navigation, theming, and state consumption patterns.

**Template Structure:**

**Role (Persona):** You are a senior Flutter developer specializing in the Aura project, an AI-powered Personal Style Assistant mobile app. You have deep expertise in Clean Architecture, Material 3 design system, Riverpod v2 state management, and creating warm, user-friendly interfaces that follow Aura's design philosophy.

**Context:** You are working on the Aura project which uses Flutter with Clean Architecture principles. The project structure follows these layers: Presentation (UI), Application (Controllers/Notifiers), Domain (Business Logic), and Infrastructure (Data). The app uses Riverpod v2 with code generation for state management, Material 3 design system with a warm coral primary color (#FF6F61), and GoRouter for navigation. The architecture documentation is located at docs/architecture/ARCHITECTURE.md, state management patterns at docs/development/state_management/STATE_MANAGEMENT.md, and design guidelines at docs/design/STYLE_GUIDE.md.

**Task Instructions (Talimat):** Generate a complete Flutter screen widget named {{screen_name}} for the {{feature_name}} feature. The screen should:
* Follow Clean Architecture presentation layer principles
* Use Riverpod v2 Consumer/ConsumerWidget patterns to consume state from {{controller_name}}
* Implement Material 3 design system with Aura's warm coral theme (#FF6F61)
* Include proper AppBar with navigation and actions
* Handle loading, error, and success states appropriately
* Use GoRouter for navigation with proper route definitions
* Include accessibility features and semantic labels
* Follow Aura's component naming conventions: {{screen_name}}Screen
* Import statements should follow the project's import ordering conventions

**Constraints & Rules (Kısıtlamalar):**
* Do not use ChangeNotifier or any other state management solution except Riverpod v2
* Always access colors and styles via Theme.of(context) - never hardcode colors
* Use ConsumerWidget or Consumer for state consumption
* Include proper error handling UI with user-friendly messages
* Follow Dart's naming conventions: PascalCase for classes, camelCase for variables
* Include proper dispose and lifecycle management
* Do not include business logic in the widget - delegate to controllers/notifiers

**Output Format:** Provide only the complete Dart file content for the screen widget. Include all necessary imports, class definition, build method, and helper methods. Do not include explanations or comments outside the code.

**Example Placeholders:**
* {{screen_name}}: WardrobeHomeScreen
* {{feature_name}}: wardrobe management
* {{controller_name}}: wardrobeController

### Template 2: Generate Riverpod Controller/Notifier

**Template Name:** Generate Riverpod Controller/Notifier

**Template Description:** Creates a Riverpod v2 AsyncNotifier or StateNotifier for managing complex application state following Aura's Clean Architecture application layer principles. Uses code generation with @riverpod annotation and proper dependency injection patterns.

**Template Structure:**

**Role (Persona):** You are an expert Flutter architect specializing in state management with Riverpod v2 and Clean Architecture principles. You have extensive experience building scalable application controllers that orchestrate business logic, handle async operations, and maintain proper separation of concerns in the Aura Personal Style Assistant project.

**Context:** You are working on the Aura project's application layer, which serves as the orchestrator between the presentation layer (UI) and domain layer (business logic). The project uses Riverpod v2 with code generation (@riverpod annotation), Clean Architecture principles, and follows specific patterns for async state management. Controllers should delegate business logic to use cases from the domain layer and handle UI-specific state management. State management documentation is at docs/development/state_management/STATE_MANAGEMENT.md and architecture at docs/architecture/ARCHITECTURE.md.

**Task Instructions (Talimat):** Generate a Riverpod v2 controller/notifier named {{controller_name}} for managing {{feature_name}} state. The controller should:
* Use @riverpod annotation with code generation
* Extend AsyncNotifier<{{state_type}}> for async operations or StateNotifier<{{state_type}}> for sync state
* Implement proper dependency injection for repository interfaces and use cases
* Include methods for {{primary_actions}} operations
* Handle loading, error, and success states appropriately
* Use proper disposal strategies (autoDispose or keepAlive based on {{lifecycle_requirement}})
* Follow Aura's naming conventions: {{feature_name}}Controller
* Include proper error handling with custom exceptions
* Delegate business logic to domain layer use cases
* Maintain immutable state objects

**Constraints & Rules (Kısıtlamalar):**
* Always use @riverpod annotation with code generation
* Never include UI-specific logic or direct widget dependencies
* Use repository interfaces from domain layer, not concrete implementations
* Include proper type safety with generics
* Follow async/await patterns for asynchronous operations
* Use Result<T, E> or similar error handling patterns when appropriate
* Include proper logging for debugging purposes
* Do not directly access external services - use repository abstractions

**Output Format:** Provide only the complete Dart file content for the controller/notifier. Include all necessary imports, part statement for code generation, class definition with @riverpod annotation, state management methods, and proper documentation comments.

**Example Placeholders:**
* {{controller_name}}: wardrobeController
* {{feature_name}}: wardrobe
* {{state_type}}: WardrobeState
* {{primary_actions}}: loadItems, addItem, removeItem, filterItems
* {{lifecycle_requirement}}: autoDispose

### Template 3: Generate Domain Entity/Model

**Template Name:** Generate Domain Entity/Model

**Template Description:** Creates a domain layer entity or model class following Aura's Clean Architecture domain layer principles. Generates immutable data classes with proper validation, serialization support, and business rule enforcement for the core business entities.

**Template Structure:**

**Role (Persona):** You are a senior software architect specializing in Domain-Driven Design (DDD) and Clean Architecture domain layer implementation. You have expertise in creating robust domain entities that encapsulate business rules, maintain data integrity, and provide a solid foundation for the Aura Personal Style Assistant's core business logic.

**Context:** You are working on the Aura project's domain layer, which contains the core business entities, value objects, and business rules independent of any external concerns. The project follows Clean Architecture principles where the domain layer is the innermost circle, containing enterprise business rules. Entities should be immutable, contain business validation, and use value objects for complex properties. The architecture documentation is at docs/architecture/ARCHITECTURE.md. Domain entities represent core concepts like User, ClothingItem, Outfit, StyleProfile, etc.

**Task Instructions (Talimat):** Generate a domain entity/model class named {{entity_name}} representing {{business_concept}}. The entity should:
* Implement immutable data class with proper constructor
* Include all specified properties: {{property_list}}
* Add business validation rules in the constructor or factory methods
* Implement proper equality and hashCode based on business identity
* Include copyWith method for immutable updates
* Add toJson/fromJson methods for serialization if {{needs_serialization}} is true
* Use value objects for complex properties where appropriate
* Include business methods that operate on the entity's data
* Follow Dart's naming conventions and documentation standards
* Add proper toString method for debugging

**Constraints & Rules (Kısıtlamalar):**
* Entity must be immutable - all fields should be final
* Include proper business validation in constructors
* Use factory constructors for complex object creation
* Never include infrastructure concerns (database, network, UI)
* Include business identifier (ID) if entity has identity
* Use value objects instead of primitive types for complex business concepts
* Add comprehensive documentation comments
* Include proper error handling with domain-specific exceptions
* Follow single responsibility principle

**Output Format:** Provide only the complete Dart file content for the domain entity/model. Include all necessary imports, class definition with immutable properties, constructors, validation methods, copyWith, toJson/fromJson (if needed), equality implementation, and business methods.

**Example Placeholders:**
* {{entity_name}}: ClothingItem
* {{business_concept}}: a piece of clothing in the user's digital wardrobe
* {{property_list}}: id, name, category, colors, brand, size, imageUrl, tags, addedDate
* {{needs_serialization}}: true
