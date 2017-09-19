## Links to Development Resources

{% if cookiecutter.use_image == "y" %}
  * [image](https://{{cookiecutter.image_org}}/{{cookiecutter.prj_name}}){% endif %}


### {% if cookiecutter.use_image == "y" %}Dockerfile vs. {% endif %}Dockerfile.dev

The `Dockerfile.dev` creates an image to provide a consistent environment to build, test, etc. This should help new developers get started faster.{% if cookiecutter.use_image == "y" %}

The `Dockerfile` creates an image with a executable jar that is used for deployment.{% endif %}{% if cookiecutter.use_codegen == "y" %}


### Swagger / OpenAPI

The project uses Swagger for a "design first" approach to REST API development. To add/modify API endpoints, developers are expected to edit **api.yml** file. This structured file includes the functional details for all API endpoints.

The build system (Makefile + Dockerfile.dev) uses the Swagger codegen command line tool to parse this YAML file. Running the Swagger codegen tool produces Spring Boot Java files. Additional details are included below:

    src/main/java/com/{{cookiecutter.org_name}}/{{cookiecutter.prj_name}}/api:    All Spring Boot @Controller classes and supporting interfaces
    src/main/java/com/{{cookiecutter.org_name}}/{{cookiecutter.prj_name}}/model:  API request/response payload models

After each modification to the **api.yml** file, you should re-build the Swagger classes. This is done with the following command:

```sh
$ make generate format
```

This command runs the Swagger codegen tool, and modifies the controller and model classes. When inspecting the **src/main/java/com/{{cookiecutter.org_name}}/{{cookiecutter.prj_name}}/api** files you'll notice that each controller class is paired with an annotated interface. It is expected that the method bodies of generated ***Controller.java** classes will be modified by developers. These methods contain service calls and may also include non-trivial validation logic.

Similar to Git, Swagger codegen offers the ability to "ignore" Swagger generated files. This project includes a `.swagger-codegen-ignore` for this purpose. This file instructs the code generator to refrain from overwriting a Swagger generated Java file. This is important, as ***Controller.java** files (for example) are modified by API developers and should therefore not be overwritten by the code generator. This may mean that you'll have to manually visit a ***Controller.java** file if inconsistencies exist between it and its paired ***Api.java** file.

> **Tip:**  The following strategy can be applied when a new controller needs to be generated.
>- Add new path with new prefix like **/users/me**.  Based on pattern used by generator this will result in the API and Controller file UsersApi.java and UsersApiController.java.
>- Add to .swagger-codegen-ignore:
**!src/main/java/com/{{cookiecutter.org_name}}/{{cookiecutter.prj_name}}/api/UsersApiController.java**
>- Generate and Format code
```make generate format```
>- Remove entry from .swagger-codegen-ignore{% endif %}
