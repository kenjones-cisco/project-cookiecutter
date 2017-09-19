package version

import (
	"fmt"
	"strings"
)

// The git commit that was compiled. This will be filled in by the compiler.
var (
	GitCommit   string
	GitDescribe string

	// Version is main version number that is being run at the moment.
	Version = "{{cookiecutter.version}}"
)

// ProductName is the name of the product
const ProductName = "{{cookiecutter.product_name}}"

// GetVersionDisplay composes the parts of the version in a way that's suitable
// for displaying to humans.
func GetVersionDisplay() string {
	return fmt.Sprintf("%s version %s\n", ProductName, getHumanVersion())
}

func getHumanVersion() string {
	version := Version
	if GitDescribe != "" {
		version = GitDescribe
	}

	// Strip off any single quotes added by the git information.
	return strings.Replace(version, "'", "", -1)
}
