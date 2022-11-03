package main

import (
	"flag"
	"fmt"
	"log"
)

func main() {
	// walk the file tree
	// for each file
	// if the file contains a string
	// replace the string
	// write the file

	var (
		original, replacement, dir string
	)

	flag.StringVar(&original, "original", "", "The string to replace")
	flag.StringVar(&replacement, "replacement", "", "The string to replace with")
	flag.StringVar(&dir, "dir", "./", "The directory to search")

	flag.Parse()

	if err := validateFlags(original, replacement, dir); err != nil {
		log.Fatalln(err)
	}

	// Collect all rbac yaml file locations in the repository.
	files, err := collectFiles(dir)
	if err != nil {
		log.Fatalln(err)
	}

}

func collectFiles(dir string) ([]string, error) {
	return nil, nil
}

func validateFlags(o, r, d string) error {
	if o == "" {
		return fmt.Errorf("original string cannot be empty")
	}

	if r == "" {
		return fmt.Errorf("replacement string cannot be empty")
	}

	if d == "" {
		return fmt.Errorf("directory cannot be empty")
	}
	return nil
}
