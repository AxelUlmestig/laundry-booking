#!/bin/sh

psql postgres://postgres@localhost:5433/postgres -f structure.sql
