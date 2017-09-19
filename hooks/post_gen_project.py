import os
import shutil

# all supported languages
LANGUAGES = ["golang", "java", "bash", "none", ]

# configured options
USE_IMAGE = '{{ cookiecutter.use_image }}'.lower() == 'y'
USE_CODEGEN = '{{ cookiecutter.use_codegen }}'.lower() == 'y'
USE_DOCGEN = '{{ cookiecutter.use_docgen }}'.lower() == 'y'
USE_BUILDER = '{{ cookiecutter.use_builder }}'.lower() == 'y'

# Get the root project directory
PROJECT_DIRECTORY = os.path.realpath(os.path.curdir)
LANGUAGE = '{{ cookiecutter.language }}'.lower()

COMMON_FILES = [
    '.dockerignore', '.editorconfig',
    '.gitattributes', '.gitignore',
    'DEVELOPMENT.md',
    'Dockerfile', 'Dockerfile.dev',
    'Makefile', 'Makefile.variables',
    'project.yml', 'scripts',
]
# prepend language pack path to the common files
COMMON_FILES = [os.path.join(PROJECT_DIRECTORY, LANGUAGE, s) for s in COMMON_FILES]

CUSTOM_FILES = []
if LANGUAGE == 'golang':
    CUSTOM_FILES.extend(['glide.yaml', 'version', ])
elif LANGUAGE == 'java':
    CUSTOM_FILES.extend(['pom.xml', 'config', ])

# prepend language pack path to the custom files
CUSTOM_FILES = [os.path.join(PROJECT_DIRECTORY, LANGUAGE, s) for s in CUSTOM_FILES]


def rm_project_files(files):
    """Remove files from base project directory."""
    for filename in files:
        os.remove(os.path.join(PROJECT_DIRECTORY, filename))


def rm_scripts(scripts):
    """Remove files from scripts directory."""
    for filename in scripts:
        os.remove(os.path.join(PROJECT_DIRECTORY, 'scripts', filename))


def remove_codgen_files():
    """Remove unused codgen related files and scripts."""
    files = ['api.yml', ]
    rm_project_files(files)

    scripts = []
    if LANGUAGE == 'golang':
        scripts = ['generate.sh', ]
    elif LANGUAGE == 'java':
        scripts = ['docs.sh', 'generate.sh', ]

    rm_scripts(scripts)

    if LANGUAGE == 'java':
        for filename in ['swagger_config.json', ]:
            os.remove(os.path.join(PROJECT_DIRECTORY, 'config', filename))


def remove_image_files():
    """Remove image dist files and Dockerfile."""
    files = ['Dockerfile', '.dockerignore', ]
    rm_project_files(files)

    scripts = ['dist.sh']
    rm_scripts(scripts)


def copy_pack_files(files):
    """Perform copy of pack files."""
    for f in files:
        if os.path.isfile(f):
            shutil.copy(f, PROJECT_DIRECTORY)
        else:
            name = os.path.basename(os.path.basename(f) or os.path.dirname(f))
            dirname = os.path.join(PROJECT_DIRECTORY, name)
            try:
                os.makedirs(dirname)
            except:
                # just ignore it, there is nothing that can be done
                pass
            subdir_files = os.listdir(f)
            for s in subdir_files:
                shutil.copy(os.path.join(f, s), os.path.join(dirname, s))


def install_language_packs():
    """Copy language specific files into the project."""
    copy_pack_files(COMMON_FILES)
    copy_pack_files(CUSTOM_FILES)


def remove_language_packs():
    """Remove language specific directories from project."""
    for l in LANGUAGES:
        try:
            shutil.rmtree(os.path.join(
                PROJECT_DIRECTORY, l
            ))
        except:
            pass

# 0. Install language specific files
install_language_packs()
remove_language_packs()

# 1. Remove image files if not needed
if not USE_IMAGE:
    remove_image_files()

# 2. Remove codgen related files and scripts if not needed
if not USE_CODEGEN:
    remove_codgen_files()

if LANGUAGE == 'golang':
    # 3. Remove build scripts if not needed
    if not USE_BUILDER:
        scripts = ['build.sh', 'xcompile.sh', ]
        rm_scripts(scripts)
        shutil.rmtree(os.path.join(
            PROJECT_DIRECTORY, 'version'
        ))

    # 4. Remove doc gen scripts if not needed
    if not USE_DOCGEN:
        scripts = ['docs.sh', ]
        rm_scripts(scripts)
