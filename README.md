# IMRSV PostgreSQL schema linter #

Find schema design mistakes by inspecting `information_schema` and
`pg_catalog`.

## tl; dr, why this tool and not others? ##

- Is a schema linter, not a SQL SELECT/UPDATE/etc. linter.
- Has a larger and actionable default ruleset (we want to be the one
  linter to rule them all).
- Is trivially user extensible rather than having to provision 5 different
  linters or ask the original linter author to accept your PR.

## Usage ##

Just read the `--help` and run it with libpq `PG*` env vars set or pass
it a DSN/URL.

```
$ PGHOST=staging.example.com PGDATABASE=api imrsv-schema-linter -f logfmt -l warning
…
level=error rule=forbidden-types table_name='some_system' column_name='that_system_created_at' data_type='timestamp without time zone' udt_name='timestamp'
…
```

## Description ##

Mostly according to [@pilona]'s typical PR review feedback and some
particularly egregious third party schemas we've seen before. Mostly
intended to automate away boring bits of PR review by pushing it to CI
instead of repeatedly manually inspecting migrations and the results.

Does not relieve you of the burden of properly:

- understanding the problem domain
- modelling it
- drawing the ER diagram, with and without attributes, and seeing if it
  makes sense
- submitting it for peer review
- applying the less trivial normal forms 2 through DKNF, _as appropriate_
- understanding SQL and relational in the first place
- properly choosing data types
- understanding concurrency
- understanding PostgreSQL, knowing its featureset, and understanding its
  performance characteristics, such as it being copy-on-write (CoW),
  heap-only-tuple updates (HOT), out of line storage (TOAST), or
  statistics, estimates, and the query planner
- understanding security, all relevant background, and being able to thing
  recursively

The linter does not verify SQL code in any way, nor does it understand how, how
often, and how much of which data in particular you access, much less
its “volume, variety, and velocity”.

Please `imrsv-schema-linter -f rules` for current rules, and read the
[roadmap](./ROADMAP.md) for future rules.

- It's currently alpha.
- It'll be beta when I've sufficiently committed to CLI options and
  rules/config file schemas.
- It'll go 1.0 when it's polished and sufficiently unit tested.

## Other **notable** semantic, not stylistic or syntactical checkers ##

What are the other ones like us? What other tools should I use _too_?

Not daemonless, standalone CLI tools need not apply.

- [SchemaCrawler]
    * Probably best known tool. Older. Not Python.
    * Also has some interesting and useful distinct sets of rules.
    * User extensible!
    * Java. Not a dependency we want in our stack, even if easily
      manageable or we use official releases.

- [pgWikiDont]
    * Written by the man depesz himself.
    * Covers the PG Wiki article which we almost all cover.

- [tbls]
    * Written in Go but easily downloadable binaries or container images
      for our use in CI
    * Can also lint schemas, amongsts its many features
    * Half its rules nobody else but `imrsv-schema-linter` has.

- [Dbcritic]
    * The closest thing to this project, linting schemas only.
    * Smaller ruleset.
    * Ruleset in code, not user config files.
    * Written in Haskell, which we don't typically carry the toolchain
      around for, not on Hackage, and no binary builds. We don't have
      it on our asset server ATM.

- [Schemalint]
    * Written in Node.JS.
    * Smaller ruleset too, only a few type corrections (but not all),
      and name inflection and casing.

- [Squawk]
    * **Focuses on DB “migrations”**.
    * **You need this too**.

- [Squabble]
    * **_Nominally_ focuses on DB “migrations” too, in Python**
    * but of which significant ground (e.g., disallowing timestamp precision)
  should just be covered by schema-at-rest linting.

- [SQLCheck]
    * **Focuses on queries.**
    * Not sure it works for ORM-ladden codebases.
    * Don't think it can extract plain SQL queries from Python code either.
    * Have not tried.
    * Query review is still human expert at IMRSV, and we otherwise
      would focus on query runtime analysis than static linting.

- [SQLFluff, some of the later rules][SQLFluff]
    * Not all of it. E.g., L049 is definitely of interest if you write
      manual SQL, however basic is the rule, but we're not talking about
      L001, as valuable as is basic code style enforcement.

Never counting any of the syntax checkers. Semantic checkers above only,
and ignore pure style checkers (e.g., spaces, not error-prone keywords)
too. E.g., [sql-lint](https://github.com/joereynolds/sql-lint/tree/typescript/src/checker/checks)
seems to focus on things like invalid options to `ALTER TABLE`.

This list also does not include operational tools, e.g., checking I/O
performance, slow queries, or any random but great visualizer like
pgBadger or `pg_top`, etc.


[@pilona]: https://github.com/pilona "Alex Pilon"

[SchemaCrawler]: https://www.schemacrawler.com/lint.html
[pgWikiDont]: https://gitlab.com/depesz/pgWikiDont/-/tree/master/parts
[Tbls]: https://github.com/k1LoW/tbls#lint
[Dbcritic]: https://github.com/channable/dbcritic/blob/master/Dbcritic/Check/
[Schemalint]: https://github.com/kristiandupont/schemalint/tree/master/src/rules#built-in-rules
[Squawk]: https://squawkhq.com/docs/rules/
[Squabble]: https://github.com/erik/squabble/tree/master/squabble/rules
[SQLCheck]: https://github.com/jarulraj/sqlcheck#what-it-can-do
[SQLFluff]: https://docs.sqlfluff.com/en/stable/rules.html
