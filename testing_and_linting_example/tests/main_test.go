package main

import (
	"net/http"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

// Defining some locations of what we expect good to look like
// Try changing the region to something different and see what happens.
var expectedLocation string = "uksouth"
var expectedHttpResponseCode int = 200

func TestTerraformVirtualMachine(t *testing.T) {
	// You can specify all sort of options related to terraform.
	// In this instance, we are simply telling terratest where our
	// root config is. You could also pass var files, but we've hard coded
	// everything in our root for ease of use.
	options := &terraform.Options{
		TerraformDir: "../",
	}

	// Defer ensures that the terraform destroy gets run, regardless of whether
	// the function exits on a success or failure. It does not run until the
	// function exits however.
	defer terraform.Destroy(t, options)

	// Hopefully the name "InitAndApply" gives away what is happening here!
	// There are many more ways this could be approached with Terratest,
	// this is just a very simple example.
	terraform.InitAndApply(t, options)

	// Here we are retrieving terraform outputs once the infrastructure has been built
	location := terraform.Output(t, options, "location")
	url := terraform.Output(t, options, "url")

	// Here we are curling the URL we obtained from the output above.
	resp, _ := http.Get(url)

	// Here we are asserting that the values returned should be as we expect.
	assert.Equal(t, location, expectedLocation)
	assert.Equal(t, resp.StatusCode, expectedHttpResponseCode)
}
