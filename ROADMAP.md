- [ ] More rules:
    * [X] No columns
    * [X] One column
    * [ ] No surrogate PK
    * [X] PK not first
    * [ ] Too many columns
    * [ ] Attribute-less join tables with a surrogate key
    * [X] All tables have a primary key
    * [X] No PG rules
    * [X] No PG inheritance
    * [X] `DEFAULT now()`
    * [X] `DEFAULT CURRENT_TIME`
    * [X] `SERIAL`
    * [X] Non-generated primary key, even if UUID
    * [X] `password_encryption` `scram-sha-256`
    * [X] Inconsistent PK types across the whole schema or database
    * [ ] Other uncommented DB objects:
        + [ ] Tables and views
        + [ ] Schemas
        + [ ] The current database
        + [ ] Functions, procedures (yes, like a docstring)
        + [ ] The other types at the notice level.
    * [ ] Duplicate relationships
    * [X] Disconnected table
    * [ ] Unused UDT
        + [ ] Also enums, which aren't under `user_defined_types`.
    * [ ] `column1`, `column2` or `spouse1_id`, `spouse2_id`
    * [ ] Too many large objects
    * [ ] Column names that require quoting
    * [X] All, all minus PK, or too many nullable
    * [ ] Table cycles
    * [ ] Table cycles, recursively
    * [X] Self-referencing
    * [ ] Inherently redundant indexes, of the same index type
    * [ ] Unindexed tables
    * [ ] All PK (NOTICE)
    * [X] Not `bigint` PK
    * [ ] Column Tetris
    * [ ] Unindexed foreign and primary keys
    * [ ] Redundant index when composite prefix will do
    * [ ] Run views, functions/procedures, defaults, and generated through a query linter.
    * [ ] Deprecated extensions
        + [ ] `uuid-ossp` (debatable), just use `gen_random_uuid()` unless you really need not completely random UUIDs at your own peril)
        + [ ] (lib)`xml2`, per v14 F.45. xml 2 § F.45.1 Deprecation Notice, use SQL standard instead
        + [ ] `dblink`, use postgres_fdw instead
        + [ ] `hstore`?
        + [ ] `intagg`, v14 F.17, “The intagg module provides an integer aggregator and an enumerator. intagg is now obsolete, because there are built-in functions that provide a superset of its capabilities. However, the module is still provided as a compatibility wrapper around the built-in functions.”
    * [ ] Forbidden extensions
        + [ ] `plpython2`
        + [ ] `pltcl`/`pltclu`
        + [ ] `file_fdw`, Don't access files, especially in a cloud where it's probably not available and you have yet another way of getting onto a box we wanted to lock down
        + [ ] `adminpack`, same reason as file_fdw
        + [ ] `test_decoding`, it's an examply only
    * [ ] warn on routine language
    * [ ] error on routine language
    * [ ] `plpythonu` instead of `plpython3u` explicitly
    * [ ] Non-IMRSV languages
    * false sense of security `pg_hba_file_rules`
        [ ] address ≠ all or 127.0.0.1 or ::1
        [ ] netmask not null or 255.255.255.255 or ffff:…:ffff
        [X] auth-method md5, password, ident
        [X] separately warn about pam, bsd, cert for cloud or k8s
        [X] sspi, why are you running on Windows, what a terrible idea
        [X] auth-method peer not used on UNIX domain socket
        [ ] a lot of rules, arbitrary number, may be easy to make mistakes
    * [ ] Unenforced constraints?
    * [ ] Disabled triggers?
    * [ ] `ON UPDATE` on surrogate key
- [ ] User config files.
- [ ] Generic schema/table/column filtering.
- [ ] Properly handle schemas instead of assuming `public`.
- [ ] Output format `sql` to pipe into `psql` or whatnot.
- [ ] JSON and CSV output formats.
- [ ] Reviewdog snippet.
- [ ] Replace mediocre `print` format with nicer, aligned tables.
- [ ] PEP 621 packaging, for your other favourite tools.
- [ ] Unit tests… oh wait, that's not a feature but expected!
- [ ] Rename rules.
- [ ] Docker image, unfortunately.
    * No, never Flatpak, AppImage, or Snap.
- [ ] Keep a changelog.
- [ ] Man page.
- [ ] Basic README. Just RTF-`--help` in try it in the meantime.
- [ ] Rule filtering and selection based on rule attributes or a glob.
- [ ] logfmt all logs, not just rule violations.
    * [ ] Also JSON format.
