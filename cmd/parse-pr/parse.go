package main

import (
	"context"
	"flag"
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"strings"
	"time"

	"github.com/google/go-github/github"
	"golang.org/x/oauth2"
	"gopkg.in/yaml.v1"
)

type pullRequest struct {
	Title      string
	Branch     string
	Number     int
	Owner      owner
	Teams      []string
	Labels     []label
	Namespaces []namespace
}

type owner struct {
	Name string
	Org  string
	Repo string
}

type label struct {
	Name string
}

type namespace struct {
	Name      string
	RbacTeam  string
	AdminTeam string
}

type githubOpt struct {
	Token  string
	Client *github.Client
}

func main() {
	var (
		branch string
		prNum  int
		gh     githubOpt
	)
	// Check flags
	flag.StringVar(&branch, "branch", "", "The branch to parse")
	flag.IntVar(&prNum, "pr", 0, "The PR to parse")
	flag.StringVar(&gh.Token, "token", "", "The PR to parse")
	flag.Parse()

	if err := checkFlags(branch, prNum, gh); err != nil {
		log.Fatalln(err)
	}

	// Parse the PR
	pr := pullRequest{
		Branch: branch,
		Number: prNum,
	}

	err := pr.Parse(gh)
	if err != nil {
		log.Fatalln(err)
	}

	err = pr.Label(gh)
	if err != nil {
		log.Fatalln(err)
	}
}

func (gh *githubOpt) CreateClient() {
	ctx := context.Background()
	ts := oauth2.StaticTokenSource(
		&oauth2.Token{AccessToken: gh.Token},
	)
	tc := oauth2.NewClient(ctx, ts)

	gh.Client = github.NewClient(tc)
}

func (pr *pullRequest) Parse(gh githubOpt) error {
	// create gh client
	gh.CreateClient()

	// get owner
	err := pr.GetOwner(gh)
	if err != nil {
		return err
	}

	// get namespaces
	err = pr.GetNamespaces(gh)
	if err != nil {
		return err
	}

	err = pr.GetTeams(gh)
	if err != nil {
		return err
	}

	// index what's in the namespace
	err = pr.IndexNamespaces(gh)
	if err != nil {
		return err
	}

	// create labels slice
	err = pr.CreateLabels(gh)
	if err != nil {
		return err
	}

	return nil
}

func (pr *pullRequest) GetTeams(gh githubOpt) error {
	b, err := pr.GetRbacFile(gh)
	if err != nil {
		return err
	}

	// parse the rbac RbacFile
	rbacFile := parseRbacFile(b)
	pr.Teams = rbacFile.Teams

	return nil
}

func parseRbacFile(b []byte) rbacFile {
	var rbacFile rbacFile
	err := yaml.Unmarshal(b, &rbacFile)
	if err != nil {
		log.Fatalln(err)
	}

	return rbacFile
}

func (pr *pullRequest) GetRbacFile(gh githubOpt) ([]byte, error) {
	httpClient := &http.Client{
		Timeout: time.Second * 10,
	}

	host := fmt.Sprintf("https://raw.githubusercontent.com/%s/%s/main/namespaces/live.cloud-platform.service.justice.gov.uk/%s/01-rbac.yaml", pr.Owner.Org, pr.Owner.Repo, pr.Namespaces[0].Name)

	req, err := http.NewRequest(http.MethodGet, host, nil)
	if err != nil {
		return nil, err
	}

	req.Header.Add("User-Agent", "Github-PR-Parser")
	req.Header.Set("Accept", "application/json")

	resp, err := httpClient.Do(req)
	if err != nil {
		return nil, err
	}

	if resp.Body != nil {
		defer resp.Body.Close()
	}

	body, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		return nil, err
	}

	return body, nil
}

func (pr *pullRequest) GetNamespaces(gh githubOpt) error {
	// get files in a pr
	ctx := context.Background()
	files, _, err := gh.Client.PullRequests.ListFiles(ctx, pr.Owner.Org, pr.Owner.Repo, pr.Number, nil)
	if err != nil {
		return err
	}

	var namespaces []namespace
	// create a map of namespaces (which are directories)
	for _, file := range files {
		s := strings.Split(file.GetFilename(), "/")
		if len(s) > 1 {
			namespaces = append(namespaces, namespace{
				Name: s[0],
			})
		}
	}
	pr.Namespaces = removeDuplicate(namespaces)

	return nil
}

func removeDuplicate[T namespace | string](sliceList []T) []T {
	allKeys := make(map[T]bool)
	list := []T{}
	for _, item := range sliceList {
		if _, value := allKeys[item]; !value {
			allKeys[item] = true
			list = append(list, item)
		}
	}
	return list
}

func (pr *pullRequest) GetOwner(gh githubOpt) error {
	ctx := context.Background()
	o := owner{
		Org:  "ministryofjustice",
		Repo: "cloud-platform-environments",
	}
	// Hit the API for the owner of the PR.
	req, _, err := gh.Client.PullRequests.Get(ctx, o.Org, o.Repo, pr.Number)
	if err != nil {
		return err
	}

	o.Name = req.GetUser().GetName()

	pr.Owner = o

	return nil
}

func (pr *pullRequest) Label(gh githubOpt) error {
	return nil
}

func checkFlags(branch string, pr int, gh githubOpt) error {
	if branch == "" || pr == 0 || gh.Token == "" {
		return fmt.Errorf("You need to specify a non-empty value for branch pr and token.")
	}
	return nil
}
