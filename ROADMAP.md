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
    * [ ] Inconsistent PK types across the whole schema or database
    * [ ] Other uncommented DB objects:
        + [ ] Tables and views
        + [ ] Schemas
        + [ ] The current database
        + [ ] Functions, procedures (yes, like a docstring)
        + [ ] The other types at the notice level.
    * [ ] Duplicate relationships
    * [ ] Disconnected table
    * [ ] Unused UDT
        + [ ] Also enums, which aren't under `user_defined_types`.
    * [ ] `column1`, `column2` or `spouse1_id`, `spouse2_id`
    * [ ] Too many large objects
    * [ ] Column names that require quoting
    * [X] All, all minus PK, or too many nullable
    * [ ] Table cycles
    * [ ] Self-referencing
    * [ ] Inherently redundant indexes, of the same index type
    * [ ] Unindexed tables
    * [ ] Null as explicit default
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
