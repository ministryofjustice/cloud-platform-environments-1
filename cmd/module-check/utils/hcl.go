package utils

import (
	"context"
	"fmt"
	"os"
	"strings"

	"github.com/google/go-github/v64/github"
	"github.com/hashicorp/hcl/v2"
	"github.com/hashicorp/hcl/v2/hclwrite"
)

type Mismatch struct {
	RepositoryNamespace,
	File string
	// Resource details
	ResourceTypeName,
	ResourceName,
	ResourceNamespace string
	// Module details
	ModuleTypeName,
	ModuleNamespace string
}

type Result struct {
	Result string
}

// listFiles() will gather a list of tf files to be checked for namespace comparisons using github ref for the pull request
func ListFiles(ctx context.Context, client *github.Client, owner, repo string, bid int) ([]*github.CommitFile, error) {
	prs, _, err := client.PullRequests.ListFiles(ctx, owner, repo, bid, nil)
	if err != nil {
		return nil, err
	}
	return prs, nil
}

// decodeFile() will read tf files and return the file to for the comparison
func DecodeFile(file string) ([]*hclwrite.Block, error) {
	var blocks []*hclwrite.Block

	data, err := os.ReadFile(file)

	if err != nil {
		return nil, fmt.Errorf("error reading file %s", err)
	}

	f, diags := hclwrite.ParseConfig(data, file, hcl.Pos{
		Line:   0,
		Column: 0,
	})

	if diags.HasErrors() {
		return nil, fmt.Errorf("error getting TF resource: %s", diags)
	}
	blocks = f.Body().Blocks()

	return blocks, nil
}

func ModuleType(file string, block *hclwrite.Block) map[string]interface{} {
	// gather all keys and attributes values from the block and append to a interface
	fmt.Printf("\nModule Function\n")
	m := make(map[string]interface{})
	for key, attr := range block.Body().Attributes() {
		expr := attr.Expr()
		exprTokens := expr.BuildTokens(nil)
		var moduleTokens hclwrite.Tokens
		moduleTokens = append(moduleTokens, exprTokens...)
		m[key] = strings.TrimSpace(string(moduleTokens.Bytes()))
		if strings.Contains(m[key].(string), "${var.") {
			k := strings.Split(m[key].(string), "var.")
			k2 := strings.Split(k[1], "}")
			v, err := VarFileSearch(file, k2[0])
			v = strings.Replace(v, "\"", "", -1)
			if err != nil {
				fmt.Println("Error getting variable from variables.tf file: ", err)
			}
			rep := strings.Replace(m[key].(string), "${var."+k2[0]+"}", v, 1)
			m[key] = rep
		} else if strings.Contains(m[key].(string), "var.") {
			k := strings.Split(m[key].(string), "var.")
			v, err := VarFileSearch(file, k[1])
			if err != nil {
				fmt.Println("Error getting variable from variables.tf file: ", err)
			}
			m[key] = v
		}
	}
	return m
}

func ResourceType(file string, block *hclwrite.Block) map[string]interface{} {
	fmt.Printf("\nResource Function\n")
	m := make(map[string]interface{})
	metadata := block.Body().Blocks()
	for _, meta := range metadata {
		for key, attr := range meta.Body().Attributes() {
			expr := attr.Expr()
			exprTokens := expr.BuildTokens(nil)
			var resourceTokens hclwrite.Tokens
			resourceTokens = append(resourceTokens, exprTokens...)
			m[key] = strings.TrimSpace(string(resourceTokens.Bytes()))
			if strings.Contains(m[key].(string), "${var.") {
				k := strings.Split(m[key].(string), "var.")
				k2 := strings.Split(k[1], "}")
				v, err := VarFileSearch(file, k2[0])
				v = strings.Replace(v, "\"", "", -1)
				if err != nil {
					fmt.Println("Error getting variable from variables.tf file: ", err)
				}
				rep := strings.Replace(m[key].(string), "${var."+k2[0]+"}", v, 1)
				m[key] = rep
			} else if strings.Contains(m[key].(string), "var.") {
				k := strings.Split(m[key].(string), "var.")
				v, err := VarFileSearch(file, k[1])
				if err != nil {
					fmt.Println("Error getting variable from variables.tf file: ", err)
				}
				m[key] = v
			}
		}
		for key, attr := range block.Body().Attributes() {
			expr := attr.Expr()
			exprTokens := expr.BuildTokens(nil)
			var resourceTokens hclwrite.Tokens
			resourceTokens = append(resourceTokens, exprTokens...)
			m[key] = strings.TrimSpace(string(resourceTokens.Bytes()))
			if strings.Contains(m[key].(string), "${var.") {
				k := strings.Split(m[key].(string), "var.")
				k2 := strings.Split(k[1], "}")
				v, err := VarFileSearch(file, k2[0])
				v = strings.Replace(v, "\"", "", -1)
				if err != nil {
					fmt.Println("Error getting variable from variables.tf file: ", err)
				}
				rep := strings.Replace(m[key].(string), "${var."+k2[0]+"}", v, 1)
				m[key] = rep
			} else if strings.Contains(m[key].(string), "var.") {
				k := strings.Split(m[key].(string), "var.")
				v, err := VarFileSearch(file, k[1])
				if err != nil {
					fmt.Println("Error getting variable from variables.tf file: ", err)
				}
				m[key] = v
			}
		}
	}
	return m
}

// varFileSearch() will search for the namespace in the variables.tf file if the search contians 'var.'
func VarFileSearch(file, ns string) (string, error) {
	path := strings.SplitAfter(file, "resources/")
	data, err := os.ReadFile(path[0] + "variables.tf")
	if err != nil {
		return "", fmt.Errorf("error reading file %s", err)
	}

	v, diags := hclwrite.ParseConfig(data, path[0]+"variables.tf", hcl.Pos{
		Line:   0,
		Column: 0,
	})

	if diags.HasErrors() {
		return "", fmt.Errorf("error getting TF resource: %s", diags)
	}

	var vn string

	blocks := v.Body().Blocks()
	for _, block := range blocks {
		if block.Type() == "variable" {
			for _, label := range block.Labels() {
				if label == ns {
					for key, attr := range block.Body().Attributes() {
						if key == "default" {
							expr := attr.Expr()
							exprTokens := expr.BuildTokens(nil)
							var varTokens hclwrite.Tokens
							varTokens = append(varTokens, exprTokens...)
							vn = strings.TrimSpace(string(varTokens.Bytes()))
						}
					}
				}
			}
		}
	}
	return vn, nil
}
