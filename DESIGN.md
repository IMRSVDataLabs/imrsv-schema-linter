## Requirements ##

- End-user extensible. Not on the CLI though. Use `psql` for that.
    * Config files sufficient. No need for rules in other datastores.
        + End-user friendly config files.
        + Easy to write rules from examples within a minute or two.

- Interactive use, modern log system, and CI/CD friendly.
    * Auto-paging for interactive use, and a format that is easy to scan
      but not too ‘decorated’.
    * Modern log system means logfmt or JSON.
    * CI/CD-friendly means some yet undefined format like JUnit2 XML,
      custom JSON, CSV.
    * CI/CD must be able to specify some threshold of severity, rule
      types, ruleset name, or other attributes, to accomodate local
      taste and tolerance.
        + Doing differences over time in output, to catch new errors is
          the responsibility of said CI/CD system, but it must enable
          that with some output format that they already check for
          regressions or new failures.

- Adding rulesets, whether updates instead of `pip install -U`ing or
  similar, or just org-wide complementary rulesets.
    * Complementary to rules in an end-user config, which would be
      project/repo-specific, or the like.

- Both the CLI, the output, and config files must be self-documenting.
    * The rationale for a rule is especially important to end-users and
      other developers.
    * The output format at least should produce actionable feedback
      where possible.

## Decisions ##

- Yes, the code is tightly coupled to the DB. It relies entirely on
  SQL for writing linting rules, rather than using an abstraction like
  SQLAlchemy and Python expressions (preferrably list comprehensions).
    * It keeps the dependency list small at the expense of coupling.
        + Using SQLAlchemy for inspecting some details is on the way to
          esoteric, obviously entirely SQLAlchemy-specific, and also
          less known than `pg_catalog` and `information_schema` to say
          the least.
            - We'd be best served then to make some generic Python
              abstraction for all relevant info in `information_schema`
              and `pg_catalog`.
                * Then end-users could make rules with simple Python
                  comprehensions.
                * However, we would want to make everything a
                  `typing.SimpleNamespace` to avoid annoying bracket
                  notation all over the place.
                * It still also wouldn't solve basic annoyances in
                  grouping by things or doing counts over that without
                  projecting some useful functions into the namespace
                  that list comprehensions in a user config file would
                  have, such as `itertools.groupby`, `.pairwise`, and
                  `functools.reduce`.
        + It's six of one, half a dozen to express rules in SQL because
          some joins are just easier to express in SQL and `GROUP BY`
          or `HAVING` moreso, whereas most of the things would be easier
          as Python object attribute access in a list comprehension.
    * Python expressions in user-supplied config files would be odd.
    * But then again, it's debatable whether one should allow arbitrary
      code execution in config files.
        + Obviously adding a simple `[eval("my; payload")]` or
          `[__import__("evil")]`.
        + `ast.parse_literal` is far too limited because it rejects
          `itertools.groupby` which is obviously necessary for some rules.
        + The only remaining option is to do involved shenanigans with
          recursively walking `ast.parse()` for forbidden code, unless
          you have some favourite minilanguage in which to write rules,
          and I don't mean xpath2 or xquery.

    * Prefer putting much of the logic in YAML or other config so that
      it is easy to take user-supplied rules, even if just using one
      file that has no dependencies.

- Config files should be a **controlled code injection vector** at
  worst.
    * That means either:
        + All config files must opt-in to getting extra config files
          from parent dirs.
        + We don't do config file inheritance.
        + We opt out of config file inheritance, but we require people
          to be explicit about their choice.
    * We don't want to be the next trojan victim like `PATH=.:"$PATH"`
      and other shenanigans.
