# https://blog.ionelmc.ro/2014/05/25/python-packaging/#the-structure
# TODO instead:
# https://python-poetry.org/docs/pyproject/ and PEP 517 or
# https://www.python.org/dev/peps/pep-0621/ but still pip?

from setuptools import setup
from glob import glob

setup(
    version='0.1a',
    name='imrsv-schema-linter',
    packages=['imrsv.schema_linter'],
    package_dir={'': 'src'},
    include_package_data=True,
    zip_safe=False,
    url='https://github.com/IMRSVDataLabs/imrsv-schema-linter',
    python_requires='~=3.8',
    install_requires=[
        'psycopg2',
        'pyyaml',
    ],
    extras_require={
        # Debugging, testing, linting/checking
        'development': [
            'flake8',
            'mypy',
            'bandit',
            'safety',
            # 'types-PyYAML', or mypy --install-types?
            'pytest',
            'pytest-cov',
            'coverage',
        ],
    },
    # TODO: Properly tag releases in GH repo, and copy bare minimum for it to
    # tag the release, or solve problem externally.
    # setup_requires=[
    #     'setuptools_scm',  # for git-based versioning
    # ],
    # use_scm_version=True,
    license='License :: MIT License',
    author='Alex Pilon',
    author_email='alex@imrsv.ai',
    description='The IMRSV-tailored PostgreSQL schema linter',
    classifiers=[
        'Development Status :: 3 - Alpha',
        'Intended Audience :: Developers',
        'License :: MIT License',
        'Programming Language :: Python :: 3',
        'Tools :: Software Development :: Quality Assurance',
        'Topic :: Database',
    ],
    scripts=glob('bin/*'),
)
