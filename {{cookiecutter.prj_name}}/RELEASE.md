# Versioning / Releasing

## Installing git-flow

```bash
wget --no-check-certificate -q https://raw.github.com/petervanderdoes/gitflow/develop/contrib/gitflow-installer.sh
bash gitflow-installer.sh install develop
rm gitflow-installer.sh
rm -rf gitflow/
```

## Prepare develop branch for next release

Release Types:
- patch
- minor
- major

Default Release Type: **minor**

```bash
make next-dev
```

Specify the `RELEASE_TYPE` to indicate next version will be major, minor, or patch.

### Examples

#### Patch Release

Current Version: 1.2.0
New Version: 1.2.1

```bash
RELEASE_TYPE=patch make next-dev
```

#### Minor Release

Current Version: 2.5.3
New Version: 2.6.0

```bash
make next-dev
```

#### Major Release

Current Version: 3.7.25
New Version: 4.0.0

```bash
RELEASE_TYPE=major make next-dev
```


## Release New Version

The new version is based on the current value of `version` in `project.yml`. The version would have been set as part of the **Prepare develop branch for next release**.

After pushing the release branch to the source control system, create a Pull Request. This should trigger all tests to run.
**DO NOT MERGE THE PULL REQUEST.**

Once the build was successful, then run the `make finish-release` command.

```bash
make start-release
git push
make finish-release
```
