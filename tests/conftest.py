import psycopg2.extensions
import psycopg2

import pytest


@pytest.fixture
def reset_db() -> psycopg2.extensions.connection:
    connection = psycopg2.connect('postgresql://')
    try:
        pass  # TODO: clean the DB
        yield connection
    finally:
        connection.close()


@pytest.fixture
def cursor(reset_db) -> psycopg2.extensions.cursor:
    c = reset_db.cursor()
    try:
        c.execute(r'BEGIN')
        yield c
    finally:
        c.execute(r'ROLLBACK')


__all__ = (
    'cursor',
)
