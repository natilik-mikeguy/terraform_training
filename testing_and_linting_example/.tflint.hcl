// This file defines the tests that tflint will use.
// Try navigating to /testing_and_linting_examples/ and run tflint

plugin "azurerm" {
    enabled = true
    version = "0.17.0"
    source  = "github.com/terraform-linters/tflint-ruleset-azurerm"
}