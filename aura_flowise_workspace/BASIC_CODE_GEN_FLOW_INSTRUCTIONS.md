BASIC CODE GENERATION FLOW INSTRUCTIONS

AURA FLOWISE AI CODE GENERATION FACTORY
Step-by-Step Instructions for Creating a Code Generation Flow

OVERVIEW
This document provides detailed instructions for manually creating a basic "Code Generation Flow" in the Flowise UI. This flow will demonstrate how to use Claude Sonnet 4 for generating code within the Aura AI Code Generation Factory.

PREREQUISITES
* Flowise server is running on http://localhost:3000
* You have access to the Flowise web interface
* You have an Anthropic API key for Claude Sonnet 4

STEP 1: ACCESS FLOWISE UI
* Open your web browser
* Navigate to http://localhost:3000
* You should see the Flowise dashboard interface
* The interface should load without requiring authentication for local development

STEP 2: ADD CLAUDE SONNET 4 CREDENTIAL
* Look for "Credentials" or "API Keys" section in the sidebar or settings menu
* Click "Add New Credential" or similar button
* Select "Anthropic" as the provider type
* Enter the following details:
  * Credential Name: "Claude Sonnet 4 Main"
  * API Key: [Replace with your actual Anthropic API key from claude_credential.json]
  * Base URL: https://api.anthropic.com (if required)
* Test the connection if option is available
* Save the credential

STEP 3: CREATE NEW CHATFLOW
* On the main dashboard, click "Add New Chatflow" or "Create Flow"
* Name the flow: "Simple Code Gen Flow"
* Add a description: "Basic code generation flow using Claude Sonnet 4 for Aura project"
* Click "Create" to initialize the flow canvas

STEP 4: ADD CHAT MODEL NODE
* In the nodes panel, locate "Chat Models" section
* Drag "Anthropic Chat Model" node to the canvas
* Click on the node to configure it
* Set the following parameters:
  * Model: "claude-3-5-sonnet-20241022"
  * Temperature: 0.3 (for consistent code generation)
  * Max Tokens: 4000
  * Credential: Select "Claude Sonnet 4 Main" (created in Step 2)
* Save the node configuration

STEP 5: ADD PROMPT TEMPLATE NODE
* From the nodes panel, find "Prompts" section
* Drag "Chat Prompt Template" node to the canvas
* Configure the prompt template with:
  * System Message: "You are an expert software engineer working on the Aura project, a personal style assistant app. Generate clean, well-documented code following best practices. Always include detailed comments and follow the project's architectural patterns."
  * Human Message Template: "Generate a {language} function to {task_description}. Only provide the function code with comments, no explanations."
* Add input variables:
  * language (default: "Python")
  * task_description (default: "calculate the area of a circle given its radius")
* Save the template configuration

STEP 6: ADD OUTPUT PARSER NODE
* Locate "Output Parsers" in the nodes panel
* Drag "String Output Parser" node to the canvas
* This node ensures the LLM response is properly formatted as plain text
* No additional configuration is typically required for this node

STEP 7: CONNECT THE NODES
* Connect the nodes in the following order:
  * Chat Prompt Template output → Anthropic Chat Model input
  * Anthropic Chat Model output → String Output Parser input
* Ensure all connections are properly established (indicated by solid lines)
* The flow should show: Prompt Template → Chat Model → Output Parser

STEP 8: ADD FINAL OUTPUT NODE
* Add a "Final Answer" node from the Output section
* Connect String Output Parser output to Final Answer input
* This will display the generated code in the chat interface

STEP 9: SAVE THE FLOW
* Click "Save" or "Save Flow" button
* Verify the flow is saved successfully
* The flow should appear in your chatflows list

STEP 10: TEST THE FLOW
* Use the test interface or chat panel on the right side
* Enter test input for the variables:
  * language: "Python"
  * task_description: "calculate the area of a circle given its radius"
* Click "Send" or "Execute" to run the flow
* Verify that Claude Sonnet 4 responds with appropriate Python code
* The output should include:
  * Proper function definition
  * Comments explaining the code
  * Error handling (if applicable)
  * Clean, readable code structure

STEP 11: VERIFY OUTPUT QUALITY
* Check that the generated code follows Python best practices
* Ensure the code includes proper documentation
* Verify the function actually calculates circle area correctly
* Test with different programming languages (e.g., "JavaScript", "Dart")

EXPECTED OUTPUT EXAMPLE
When testing with Python circle area calculation, you should receive output similar to:

```python
import math

def calculate_circle_area(radius):
    """
    Calculate the area of a circle given its radius.
    
    Args:
        radius (float): The radius of the circle
        
    Returns:
        float: The area of the circle
        
    Raises:
        ValueError: If radius is negative
    """
    if radius < 0:
        raise ValueError("Radius cannot be negative")
    
    area = math.pi * radius ** 2
    return area
```

TROUBLESHOOTING
* If the flow fails to execute, check API key configuration
* Ensure all nodes are properly connected
* Verify internet connection for API calls
* Check Flowise console for error messages
* Confirm Claude Sonnet 4 model name is correct

NEXT STEPS
* Experiment with different prompt templates
* Try generating code for different programming languages
* Create specialized flows for Aura project components
* Implement file output capabilities for generated code

This completes the basic code generation flow setup. The flow is now ready to generate code using Claude Sonnet 4 within the Flowise environment.
