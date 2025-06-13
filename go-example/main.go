package main

import (
	"fmt"
	"github.com/moby/patternmatcher"
	"io/fs"
	"os"
	"path/filepath"
)

func main() {
	patterns := []string{"package.json"}
	matches := glob(".", func(s string) bool {
		m, err := patternmatcher.Matches(s, patterns)
		if err != nil {
			fmt.Fprintf(os.Stderr, "error trying to match files with '%v': %s", patterns, err)
			return false
		}
		return m
	})

	fmt.Println("matches ", matches)
}

func glob(root string, fn func(string) bool) []string {
	var files []string
	if err := filepath.WalkDir(root, func(s string, _ fs.DirEntry, _ error) error {
		fmt.Println("File : ", filepath.Base(s))
		if fn(s) {
			files = append(files, s)

		}
		return nil
	}); err != nil {
		fmt.Fprintf(os.Stderr, "error walking the path %q: %v\n", root, err)
	}
	return files
}
