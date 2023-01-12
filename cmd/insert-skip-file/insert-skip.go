package main

import (
	"fmt"
	"log"
	"os"
	"path/filepath"
	"strings"

	"k8s.io/kubectl/pkg/scheme"
)

const envRepoPath = "/Users/poornima.krishnasamy/go/src/ministryofjustice/cloud-platform-environments/namespaces/live.cloud-platform.service.justice.gov.uk/"

func main() {

	nsList, err := namespacesWithSAYaml(envRepoPath)
	if err != nil {
		log.Fatalf("unable to get list of namespaces %v\n", err)
	}

	fmt.Println("number of ns which has SA", len(nsList))
	// for _, ns := range nsList {
	// 	fmt.Println(ns)
	// }
	// cd into namespace and insert skip

}

func namespacesWithSAYaml(path string) ([]string, error) {
	var folders []string
	//fmt.Println(path)
	err := filepath.Walk(path, func(basepath string, info os.FileInfo, err error) error {
		//fmt.Println("inside wail", info.Name())
		if err != nil {
			log.Fatalf("prevent panic by handling failure accessing a path %q: %v\n", path, err)
			return err
		}

		if info.Name() == ".terraform" || info.Name() == "resources" || info.Name() == ".checksum" {
			return filepath.SkipDir
		}

		if !info.IsDir() {

			content, err := os.ReadFile(basepath)
			if err != nil {
				log.Fatal("error reading file", err)
			}

			// Create a runtime.Decoder from the Codecs field within
			// k8s.io/client-go that's pre-loaded with the schemas for all
			// the standard Kubernetes resource types.
			decoder := scheme.Codecs.UniversalDeserializer()

			for _, resourceYAML := range strings.Split(string(content), "---") {

				// skip empty documents, `Decode` will fail on them
				if len(resourceYAML) == 0 {
					continue
				}

				// - obj is the API object (e.g., Deployment)
				// - groupVersionKind is a generic object that allows
				//   detecting the API type we are dealing with, for
				//   accurate type casting later.
				_, groupVersionKind, err := decoder.Decode(
					[]byte(resourceYAML),
					nil,
					nil)
				if err != nil {
					log.Print(err)
					continue
				}

				// Figure out from `Kind` the resource type, and attempt
				// to cast appropriately.
				if groupVersionKind.Kind == "ServiceAccount" {
					fmt.Println(filepath.Dir(basepath))
					file, err := os.Create(filepath.Dir(basepath) + "/" + "NAMESPACE_HAS_SERVICEACCOUNT")
					if err != nil {
						log.Fatal(err)
					}
					fmt.Println("File created successfully")
					defer file.Close()
					folders = append(folders, basepath)
				}
			}

		}
		return nil
	})
	if err != nil {
		log.Println(err)
	}

	return folders, nil
}
