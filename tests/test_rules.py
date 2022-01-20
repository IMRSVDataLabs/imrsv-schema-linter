from imrsv.schema_linter.rules import Ruleset

import pytest


_default = Ruleset.DEFAULT()


@pytest.mark.parametrize('rule', _default.rules)
def test_all_rules_basic_columns(cursor, rule):
    '''
    Test that all rules have at least schema_name and table_name

    so that we can filter on those generically.
    '''
    _default.rules[rule].apply(cursor)
    assert {name for name, *_ in cursor.description} & {
        'schema_name', 'table_name'
    } == {
        'schema_name', 'table_name'
    }
