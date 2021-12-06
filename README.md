## IMRSV PostgreSQL schema linter ##

Find schema design mistakes by inspecting `information_schema` and
`pg_catalog`.

Just read the `--help` and run it with libpq `PG*` env vars set or pass
it a DSN/URL.

```
$ PGHOST=staging.example.com PGDATABASE=api imrsv-schema-linter -f logfmt -l warning
…
level=error rule=forbidden-types table_name='some_system' column_name='that_system_created_at' data_type='timestamp without time zone' udt_name='timestamp'
…
```

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
  performance characteristics, such as it being copy-on-write or
  heap-only-tuple updates

The linter does not verify SQL code in any way, nor does it understand how, how
often, and how much of which data in particular you access.

[@pilona]: https://github.com/pilona "Alex Pilon"
