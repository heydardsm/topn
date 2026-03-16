MODULE_big = topn
EXTENSION = topn
DATA = updates/topn--1.0.sql
OBJS = src/topn.o

PG_CONFIG = pg_config
PGXS := $(shell $(PG_CONFIG) --pgxs)

REGRESS = test

include $(PGXS)
