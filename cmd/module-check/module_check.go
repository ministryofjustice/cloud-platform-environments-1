package main

// check tf module names in pull requests
// is the module a valid module for auto-approval

import (
	"context"
	"flag"
	"fmt"
	"log"
	"os"
	"strings"

	"github.com/ministryofjustice/cloud-platform-environments/cmd/module-check/utils"

	clilib "github.com/ministryofjustice/cloud-platform-go-library/client"
	ulib "github.com/ministryofjustice/cloud-platform-go-library/utils"
)

var (
	token = flag.String("token", os.Getenv("GITHUB_OAUTH_TOKEN"), "GitHub Personal Access Token")
	ref   = flag.String("ref", os.Getenv("GITHUB_REF"), "Branch Name")
	repo  = flag.String("repo", os.Getenv("GITHUB_REPOSITORY"), "Repository Name")
	ctx   = context.Background()
	// ecr   structs.ECR
	// sa          structs.ServiceAccount
	// pullRequest structs.PullRequests
	// modules     []Modules
	// red         = "\033[31m"
	// clear       = "\033[0m"
)

// map of approved modules
var approvedModules = map[string]bool{
	"github.com/ministryofjustice/cloud-platform-terraform-rds-instance":     false,
	"github.com/ministryofjustice/cloud-platform-terraform-rds-aurora":       false,
	"github.com/ministryofjustice/cloud-platform-terraform-serviceaccount":   false,
	"github.com/ministryofjustice/cloud-platform-terraform-dynamodb-cluster": false,
	"github.com/ministryofjustice/cloud-platform-terraform-sqs":              false,
	"github.com/ministryofjustice/cloud-platform-terraform-s3-bucket":        false,
	"github.com/ministryofjustice/cloud-platform-terraform-sns-topic":        false,
	"github.com/ministryofjustice/cloud-platform-terraform-secrets-manager":  false,
	"github.com/ministryofjustice/cloud-platform-terraform-opensearch":       false,
	"github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials":  true,
	"ecr-credentials": true,
}

type Modules struct {
	Approved   []string
	Unapproved []string
}

func main() {
	owner, repoName, pull, err := ulib.GetOwnerRepoPull(*ref, *repo)
	if err != nil {
		log.Fatalf("Error getting owner, repo and pull request number: %v\n", err)
	}

	flag.Parse()
	client := clilib.GitHubClient(*token, ctx)

	fmt.Printf("Owner: %s\n Repo: %s\n Pull Request: %d\n", owner, repoName, pull)

	//get pull request directory
	files, err := utils.ListFiles(ctx, client, owner, repoName, pull)
	if err != nil {
		log.Fatalf("Error getting pull request files: %v\n", err)
	}

	for _, file := range files {
		if strings.Contains(file.GetFilename(), ".tf") {
			// get the file content
			fmt.Print("File: ", file.GetFilename(), "\n")
			blocks, err := utils.DecodeFile(*file.Filename)
			if err != nil {
				log.Fatalf("Error decoding file: %v\n", err)
			}

			for _, block := range blocks {
				var moduleArray map[string]interface{}
				switch {
				case block.Type() == "module":
					moduleArray = utils.ModuleType(*file.Filename, block)
					if moduleArray == nil {
						log.Fatalf("Error getting module type: %v\n", err)
					} else if approvedModules[moduleArray["source"].(string)] {
						fmt.Printf("\nModule %s is approved\n", moduleArray["source"])
					} else {
						fmt.Printf("\nModule %s is not approved\n", moduleArray["source"])
					}

					// print off m to see what is returned human readable
					for key, value := range moduleArray {
						fmt.Printf("Key: %s Value: %s\n", key, value)
					}

				case block.Type() == "resource":
					r := utils.ResourceType(*file.Filename, block)
					for key, value := range r {
						fmt.Printf("Key: %s Value: %s\n", key, value)
					}
				}
			}
		}
	}

}
