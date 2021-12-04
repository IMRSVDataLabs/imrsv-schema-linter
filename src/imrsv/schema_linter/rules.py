#! /usr/bin/env python3

from typing import Iterable, List, Tuple, NamedTuple, Optional, Union
from pathlib import Path
from enum import Enum
import importlib.resources
import logging

import psycopg2.extensions
import psycopg2
import yaml

from . import logger


# TODO: Merge. Just use adobe/himl?
builtin_rules = yaml.safe_load(importlib.resources.read_text(
    'imrsv.schema_linter', 'builtin_rules.yaml'
))


# TODO: pyproject.toml:[tools.imrsv.schema_linter]
def your_rules(p: Path) -> Iterable[Path]:
    p_y = p.joinpath('.schema_linter.yaml')
    if p.parent == p:
        return
    if p_y.exists():
        yield p_y
    yield from your_rules(p.parent)


class Severity(Enum):
    trace = logging.DEBUG  # FIXME
    debug = logging.DEBUG
    info = logging.INFO
    notice = logging.WARNING  # FIXME
    warning = logging.WARNING
    error = logging.ERROR


class RuleResult(NamedTuple):
    rule: str
    severity: Severity
    title: str
    comment: str
    results: List[Tuple[str, ...]]

    def log(self) -> None:
        if logger.isEnabledFor(logging.INFO):
            # FIXME: Not printing
            if self.comment is not None:
                logger.info('rule=%s title=%r comment=%r',
                            self.rule, self.title, self.comment)
            else:
                logger.info('rule=%s title=%r',
                            self.rule, self.title)
        for result in self.results:
            # TODO: Proper logfmt.
            # TODO: DictCursor instead and sub in
            logger.log(self.severity.value, 'level=%s rule=%s offender="%r"',
                       self.severity.name, self.rule, result)

    # TODO: Pretty
    def print(self) -> None:
        if logger.isEnabledFor(logging.DEBUG):
            print('##', self.title)
            if self.comment is not None:
                # TODO: textwrap
                for line in (self.comment or '').splitlines():
                    print('#', line.strip())
        for result in self.results:
            print(self.severity.name[0].upper(), self.rule, *result)


def convert_params(params: Union[list, dict]) -> Union[list, dict]:
    if isinstance(params, list):
        return tuple(map(convert_params, params))
    elif isinstance(params, dict):
        return {k: convert_params(v) for k, v in params.items()}


def apply_rule(cursor: psycopg2.extensions.cursor,
               rule_id: str,
               rule: dict) -> Optional[RuleResult]:
    cursor.execute(rule['query'], rule.get('params'))
    if cursor.rowcount > 0:
        return RuleResult(
            rule=rule_id,
            severity=Severity[rule['severity']],
            title=rule['title'],
            comment=rule.get('comment'),
            results=cursor.fetchall(),
        )


# Extract
def apply_rules(cursor: psycopg2.extensions.cursor) -> List[RuleResult]:
    return [results
            for rule_id, rule
            in builtin_rules['rules'].items()
            for results
            in [apply_rule(cursor, rule_id, rule)]
            if results is not None]


__all__ = (
    'Severity', 'RuleResult', 'apply_rules',
)
