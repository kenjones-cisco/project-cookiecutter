# Project Generator

## Basic Usage

### Interactive Response

```bash
docker pull kenjones/cookiecutter
docker run \
    --rm -it \
    -v $(pwd):/mnt \
    kenjones/cookiecutter \
    --output-dir /mnt https://github.com/kenjones-cisco/project-cookiecutter.git
```

### Using Configuration File

```bash
docker pull kenjones/cookiecutter
docker run \
    --rm -it \
    -v $(pwd):/mnt \
    kenjones/cookiecutter \
    --config-file /mnt/myapp.yaml \
    --no-input \
    --output-dir /mnt https://github.com/kenjones-cisco/project-cookiecutter.git
```


## Configuration Options

| Option Name  | Default Value  | Notes |
| -----------  | -------------  | ----- |
| language     | golang         | Supported languages: "golang", "java", "bash", "none" |
| prj_name     | cicdtest       | Name of the project within source control |
| org_name     | ccdev          | Name or org/group the project resides within source control |
| product_name | Task Tracker   | Display Name of component used in documentation |
| version      | 0.1.0          | Initial version |
| image_org    | quay.io/kenjones_cisco | Container Registry and Organization Name (use_image = "y") |
| binary_name  | task-tracker-server | Name of built/compiled artifact (language = "golang" and use_builder = "y") |
| binary_pkg   | cmd/task-tracker-server | Path in project where main entry point is located (language = "golang" and use_builder = "y") |
| use_image    | y | Flag to indicate if project is published as Docker image |
| use_builder  | y | Flag to indicate if compiled as binary or archived (ex. jar, war, gzip, etc.) |
| use_codegen  | y | Flag to indicate if project generates from spec (ex. API spec to code) |
| use_docgen   | y | Flag to indicate if project generates docs from code |


### Configuration File

A project can provide inputs using a `yaml` configuration file.

```yaml
default_context:
  language: golang
  prj_name: cnmte
  org_name: ccdev
  product_name: Cloud Native Manager TOSCA Engine
  version: 0.9.0
  image_org: quay.io/kenjones_cisco
  binary_name: cnmte-server
  binary_pkg: cmd/cnmte-server
  use_image: y
  use_builder: y
  use_codegen: y
  use_docgen: y
```


### Examples

| File Name  | Notes  |
| ---------  | -----  |
| [bash-app.yaml](examples/bash-app.yaml) | Generates a bash application project |
| [bash-lib.yaml](examples/bash-lib.yaml) | Generates a bash library project |
| [go-apiclient.yaml](examples/go-apiclient.yaml) | Generates a Go API Client project |
| [go-apiserver-client.yaml](examples/go-apiserver-client.yaml) | Generates a Go API Server and Client project |
| [go-apiserver.yaml](examples/go-apiserver.yaml) | Generates a Go API Server project |
| [go-cliapp.yaml](examples/go-cliapp.yaml) | Generates a Go cli project |
| [go-lib.yaml](examples/go-lib.yaml) | Generates a Go lib project |
| [java-apiserver.yaml](examples/java-apiserver.yaml) | Generates a Java API Server project |
| [none.yaml](examples/none.yaml) | Generates a generic project |


## Supported Languages

Currently supported:

- golang
- java
- bash
- none

The `none` lanaguage will provide a basic project structure that is language agnostic.

