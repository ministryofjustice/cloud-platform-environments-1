package namespace

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"strconv"
	"strings"
	"time"

	"github.com/ministryofjustice/cloud-platform-environments/pkg/authenticate"
	"github.com/ministryofjustice/cloud-platform-how-out-of-date-are-we/reports/pkg/hoodaw"
	"gopkg.in/yaml.v2"
)

// Namespace describes a Cloud Platform namespace object.
type Namespace struct {
	Application      string        `json:"application"`
	BusinessUnit     string        `json:"business_unit"`
	DeploymentType   string        `json:"deployment_type"`
	Cluster          string        `json:"cluster,omitempty"`
	DomainNames      []interface{} `json:"domain_names"`
	GithubURL        string        `json:"github_url"`
	Name             string        `json:"namespace"`
	RbacTeam         []string      `json:"rbac_team,omitempty"`
	TeamName         string        `json:"team_name"`
	TeamSlackChannel string        `json:"team_slack_channel"`
}

// AllNamespaces contains the json to go struct of the hosted_services endpoint.
type AllNamespaces struct {
	Namespaces []Namespace `json:"namespace_details"`
}

// RbacFile describes the rbac file in a users namespace
type RbacFile struct {
	Metadata struct {
		Name      string `yaml:"name"`
		Namespace string `yaml:"namespace"`
	} `yaml:"metadata"`
	Subjects []struct {
		Kind     string `yaml:"kind"`
		Name     string `yaml:"name"`
		APIGroup string `yaml:"apiGroup"`
	} `yaml:"subjects"`
}

// org and envRepo contain the GitHub user and repository respectively. They shouldn't ever change.
const (
	org     = "ministryofjustice"
	envRepo = "cloud-platform-environments"
)

// GetNamespace takes the name of a namespace as a string and returns
// a Namespace data type.
func GetNamespace(s string, h string) (Namespace, error) {
	var namespace Namespace

	allNamespaces, err := GetAllNamespaces(h)
	if err != nil {
		return namespace, err
	}

	for _, ns := range allNamespaces.Namespaces {
		if s == ns.Name {
			return ns, nil
		}
	}

	return namespace, fmt.Errorf("Namespace %s is not found in the cluster.", s)
}

// GetProductionNamespaces takes a type of AllNamespaces and
// returns a slice of all production namespaces in all clusters.
// AllNamespaces is generated by the GetAllNamespaces function.
func GetProductionNamespaces(ns AllNamespaces) (namespaces []string, err error) {
	if len(ns.Namespaces) == 0 {
		return nil, errors.New("no namespaces found")
	}

	for _, ns := range ns.Namespaces {
		// Before cli validation existed users could add whatever they wanted. This means we have some strange values for this identifier.
		env := strings.ToLower(ns.DeploymentType)
		if strings.Contains(env, "live") || strings.Contains(env, "production") || env == "prod" {
			namespaces = append(namespaces, ns.Name)
		}
	}

	return
}

// GetNonProductionNamespaces takes a type of AllNamespaces and
// returns a slice of all production namespaces in all clusters.
// AllNamespaces is generated by the GetAllNamespaces function.
func GetNonProductionNamespaces(ns AllNamespaces) (namespaces []string, err error) {
	if len(ns.Namespaces) == 0 {
		return nil, errors.New("no namespaces found")
	}

	for _, ns := range ns.Namespaces {
		env := strings.ToLower(ns.DeploymentType)
		if env != "prod" && !strings.Contains(env, "live") && env != "production" {
			namespaces = append(namespaces, ns.Name)
		}
	}

	return
}

// GetAllNamespaces takes the host endpoint for the how-out-of-date-are-we and
// returns a report of namespace details in the cluster.
func GetAllNamespaces(endPoint string) (namespaces AllNamespaces, err error) {
	body, err := hoodaw.QueryApi(endPoint)
	if err != nil {
		return
	}

	err = json.Unmarshal(body, &namespaces)
	if err != nil {
		return
	}

	return
}

// SetRbacTeam takes a cluster name as a string in the format of `live-1` (for example) and sets the
// method value `RbacTeam`.
// The function performs a HTTP GET request to GitHub, grabs the contents of the rbac yaml file and
// interpolates the GitHub teams allowed to access a namespace.
func (ns *Namespace) SetRbacTeam(cluster string) error {
	client := &http.Client{
		Timeout: time.Second * 2,
	}

	// It is assumed the rbac file will remain constant.
	host := fmt.Sprintf("https://raw.githubusercontent.com/%s/%s/main/namespaces/%s.cloud-platform.service.justice.gov.uk/%s/01-rbac.yaml", org, envRepo, cluster, ns.Name)

	req, err := http.NewRequest(http.MethodGet, host, nil)
	if err != nil {
		return err
	}

	req.Header.Add("User-Agent", "moj-env-namespace-pkg")
	req.Header.Set("Accept", "application/json")

	resp, err := client.Do(req)
	if err != nil {
		return err
	}

	if resp.Body != nil {
		defer resp.Body.Close()
	}

	body, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		return err
	}

	rbac := RbacFile{}

	err = yaml.Unmarshal(body, &rbac)
	if err != nil {
		return err
	}

	for _, team := range rbac.Subjects {
		if strings.Contains(team.Name, "github:") {
			name := strings.Split(team.Name, ":")
			ns.RbacTeam = append(ns.RbacTeam, name[1])
		}
	}

	if ns.RbacTeam == nil {
		return fmt.Errorf("Unable to find team names for %s.", ns.Name)
	}

	return nil
}

// ChangedInPR takes a GitHub branch reference (usually provided by a GitHub Action), a
// personal access token with Read org permissions, the name of a repository and the owner.
// It queries the GitHub API for all changes made in a PR. If the PR contains changes to a namespace
// it returns a deduplicated slice of namespace names.
func ChangedInPR(branchRef, token, repo, owner string) ([]string, error) {
	if token == "" {
		return nil, errors.New("You must have a valid GitHub token.")
	}

	client, err := authenticate.GitHubClient(token)
	if err != nil {
		return nil, err
	}

	// branchRef is expected in the format:
	// "refs/pull/<pull request number>/merge"
	// This is usually populated by a GitHub action.
	str := strings.Split(branchRef, "/")
	prId, err := strconv.Atoi(str[2])
	if err != nil {
		log.Fatalln(err)
	}

	repos, _, _ := client.PullRequests.ListFiles(context.Background(), owner, repo, prId, nil)

	var namespaceNames []string
	for _, repo := range repos {
		if strings.Contains(*repo.Filename, "live") {
			// namespaces filepaths are assumed to come in
			// the format: namespaces/live-1.cloud-platform.service.justice.gov.uk/<namespaceName>
			s := strings.Split(*repo.Filename, "/")
			namespaceNames = append(namespaceNames, s[2])
		}
	}

	return deduplicateList(namespaceNames), nil
}

// deduplicateList will simply take a slice of strings and
// return a deduplicated version.
func deduplicateList(s []string) (list []string) {
	keys := make(map[string]bool)

	for _, entry := range s {
		if _, value := keys[entry]; !value {
			keys[entry] = true
			list = append(list, entry)
		}
	}

	return
}
