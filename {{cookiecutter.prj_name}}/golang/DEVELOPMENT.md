## Links to Development Resources

{% if cookiecutter.use_image == "y" %}
  * [image](https://{{cookiecutter.image_org}}/{{cookiecutter.prj_name}}){% endif %}


### {% if cookiecutter.use_image == "y" %}Dockerfile vs. {% endif %}Dockerfile.dev

The `Dockerfile.dev` creates an image to provide a consistent environment to build, test, etc. This should help new developers get started faster.{% if cookiecutter.use_image == "y" %}

The `Dockerfile` creates an image with a pre-compiled binary that is used for deployment.{% endif %}


**Additional background**

- [Docker + Golang = <3](https://blog.docker.com/2016/09/docker-golang/)
- [Dockerize Go Applications](http://thenewstack.io/dockerize-go-applications/){% if cookiecutter.use_codegen == "y" %}


### Swagger / OpenAPI

The project uses Swagger for a "design first" approach to REST API development. To add/modify API endpoints, developers are expected to edit **api.yml** file. This structured file includes the functional details for all API endpoints.

The build system (Makefile + Dockerfile.dev) uses the go-swagger command line tool to parse this YAML file. Running the go-swagger tool produces Golang HTTP Server. Additional details are included below:

    {{cookiecutter.prj_name}}/restapi: All handlers for each operation
    {{cookiecutter.prj_name}}/models:  API request/response payload models

After each modification to the **api.yml** file, you should re-generate the code. This is done with the following command:

```sh
$ make generate format
```

This command runs the go-swagger tool to validate the API specification, generates updated handlers and models, and formats the code.
{% endif %}
