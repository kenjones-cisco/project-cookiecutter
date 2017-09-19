# Contributing to {{cookiecutter.prj_name}}

This is a short guide on how to contribute to the project.

## Submitting a pull request

If you find a bug that you'd like to fix, or a new feature that you'd like to implement then please submit a pull request via Github.{% if cookiecutter.language == "golang" %}

You'll need a Go environment set up with GOPATH set. See [the Go getting started docs](https://golang.org/doc/install) for more info.{% endif %}

Now in your terminal

    git clone ssh://git@github.com/{{cookiecutter.org_name}}/{{cookiecutter.prj_name}}.git
    cd {{cookiecutter.prj_name}}

Make a branch to add your new feature

    git checkout -b my-new-feature develop

And get hacking.

When ready - run the unit tests for the code you changed

    make test

Make sure you

  * Add documentation for a new feature
  * Add unit tests for a new feature
  * squash commits down to one per feature
  * rebase to develop `git rebase develop`

When you are done with that

    git push origin my-new-feature

Go to the Github website and click [Create pull request](https://help.github.com/articles/about-pull-requests/).

You patch will get reviewed and you might get asked to fix some stuff.

If so, then make the changes in the same branch, squash the commits, rebase it to develop then push it to Github with `--force`.

## Test{% if cookiecutter.language == "golang" and cookiecutter.use_builder == "y" %} / Build{% endif %}

Tests are run using a testing framework, so at the top level you can run this to run all the tests.

**Assumes that you have Minishift / Docker Toolbox / Docker for Mac / Docker for Windows installed.**

```bash
# runs all tests (includes formatting and linting)
make test
# run all tests and generates code coverage (includes formatting and linting)
make cover{% if cookiecutter.language == "golang" and cookiecutter.use_builder == "y" %}
# builds the default binary (linux amd64); (includes formatting and linting)
make build{% elif cookiecutter.language == "java" %}
# builds the runnable jar (includes formatting and linting)
make build{% endif %}
```

### Setting up Minishift/Docker Toolbox

```bash
make setup
# make docker available locally
eval "$(minishift docker-env)"
# or depending on which is installed
eval "$(docker-machine env)"
```{% if cookiecutter.language == "golang" %}

## Adding New Dependency

**If prompted to use specific versions, always select "Yes"**

```bash
DEP=<package> make dep-add
```

#### Example

```bash
DEP=github.com/sirupsen/logrus make dep-add
```{% endif %}

## Making a release

[Release](RELEASE.md)
