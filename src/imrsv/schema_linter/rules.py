#! /usr/bin/env python3

from typing import (Iterable, List, Dict, NamedTuple, Union, Tuple,
                    Optional, Any, AbstractSet)
from pathlib import Path
from enum import Enum
import importlib.resources
import logging

import psycopg2.extensions
import psycopg2
import yaml


class Severity(Enum):
    trace = logging.DEBUG  # FIXME
    debug = logging.DEBUG
    info = logging.INFO
    notice = logging.WARNING  # FIXME
    warning = logging.WARNING
    error = logging.ERROR


class Rule(NamedTuple):
    id: str
    title: str
    labels: AbstractSet[str]
    severity: Severity
    query: str
    # TODO: Supported types to pass to psycopg2
    comment: Optional[str] = None
    params: Optional[Union[Dict[str, Any],
                           List[Any]]] = None
    group: Optional[str] = None

    def apply(self,
              cursor: psycopg2.extensions.cursor) -> Iterable['RuleResult']:
        cursor.execute(self.query, self.params)
        names = [name for name, *_ in cursor.description]
        return (
            RuleResult(
                rule=self.id,
                severity=self.severity,
                title=self.title,
                comment=self.comment,
                offender={name: cell for name, cell in zip(names, row)}
            )
            for row
            in cursor.fetchall()
        )


# TODO: How to put in class?
CONFIG_FILE = '.schema_linter.yaml'


class Ruleset(NamedTuple):
    rules: Dict[str, Rule]
    root: bool = False

    @classmethod
    @property
    def DEFAULT(cls) -> 'Ruleset':
        return cls.loads(
            importlib.resources.read_text('imrsv.schema_linter',
                                          'builtin_rules.yaml'),
        )

    @classmethod
    def loads(cls, s: str) -> 'Ruleset':
        o = cls(**yaml.safe_load(s))
        # Don't learn from this people! This is a quick hack.
        o = o._replace(
            rules={
                k: Rule(id=k, **v)._replace(
                    severity=Severity[v['severity']],
                    labels=frozenset(v['labels'] or []),
                )
                for k, v
                in o.rules.items()
            }
        )
        return o

    # TODO: pyproject.toml:[tools.imrsv.schema_linter]
    @classmethod
    def scoped_paths(cls, p: Path) -> Iterable[Path]:
        p_y = p.joinpath(CONFIG_FILE)
        if p.parent == p:
            return
        if p_y.exists():
            yield p_y
        yield from cls.scoped_paths(p.parent)

    # TODO: def merge. Just use adobe/himl?


# TODO: Use class Rule.
class RuleResult(NamedTuple):
    rule: str
    severity: Severity
    title: str
    offender: Dict[str, str]  # FIXME: Not actually str RHS
    comment: Optional[str] = None

    def logfmt(self) -> Tuple[int, str, tuple]:
        fmt = 'level=%s rule=%s ' + ' '.join(
            f'{k}=%r'
            for k
            in self.offender
        )
        return (self.severity.value, fmt,
                (self.severity.name, self.rule, *self.offender.values()))


def convert_params(params: Union[list, dict]) -> Union[list, dict]:
    if isinstance(params, list):
        return tuple(map(convert_params, params))
    elif isinstance(params, dict):
        return {k: convert_params(v) for k, v in params.items()}


def apply_rule(cursor: psycopg2.extensions.cursor,
               rule_id: str,
               rule: dict) -> List[RuleResult]:
    cursor.execute(rule.query, rule.params)
    names = [name for name, *_ in cursor.description]
    return [
        RuleResult(
            rule=rule_id,
            severity=rule.severity,
            title=rule.title,
            comment=rule.comment,
            offender={name: cell for name, cell in zip(names, row)}
        )
        for row
        in cursor.fetchall()
    ]


# Extract
def apply_rules(cursor: psycopg2.extensions.cursor,
                rules: Iterable[Rule]) -> Iterable[RuleResult]:
    return [result
            for rule in rules
            for result in rule.apply(cursor)]


__all__ = (
    'Severity', 'RuleResult', 'apply_rules',
)
