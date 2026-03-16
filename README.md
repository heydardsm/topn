# TopN - PostgreSQL Extension for Top Value

[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16-orange.svg)](https://www.postgresql.org/)

TopN is an open-source PostgreSQL extension that returns top values in database according to some criteria.

## How It Works

It creates a table for you with:
- **uid**: your unique identifier (e.g., tournament_id, user_id, date)
- **key**: the thing you want to measure (e.g., player_id, product_id, action)
- **frequently**: the score/count/value

For example, if you want to get top 10 users in a tournament:
- **uid** = tournament_id
- **key** = user_id
- **frequently** = score

### Table Structure

```sql
CREATE TABLE topn_<namespace> (
    uid <type> NOT NULL,
    key <type> NOT NULL,
    frequently bigint NOT NULL DEFAULT 0,
    UNIQUE(uid, key)
);
```

## Build

### Prerequisites

- GCC compiler
- PostgreSQL development headers

### Build Instructions

```bash
make
sudo make install
```

### Verify Installation

```sql
CREATE EXTENSION topn;

SELECT topn_version();
```

## Usage

### 1. Create a Namespace

```sql
-- Basic usage (default: varchar(256) for both uid and key)
SELECT topn_create_namespace('tournament_scores');

-- Specify custom types
SELECT topn_create_namespace('user_actions', 'integer', 'varchar(100)');
SELECT topn_create_namespace('daily_stats', 'date', 'varchar(50)');
SELECT topn_create_namespace('product_sales', 'uuid', 'integer');
SELECT topn_create_namespace('event_log', 'timestamp', 'bigint');
```

### 2. Add Data

```sql
-- Add with default increment (1)
SELECT topn_add('tournament_scores', 101, 'player123');
SELECT topn_add('tournament_scores', 101, 'player456');

-- Add with specific increment
SELECT topn_add('tournament_scores', 101, 'player123', 5);
```

### 3. Get Top N Values

```sql
-- Get top 10 players in tournament 101
SELECT * FROM topn('tournament_scores', 101, 10);
```

## Complete Example

```sql
-- 1. Create the extension
CREATE EXTENSION topn;

-- 2. Create a namespace for tournament scores
SELECT topn_create_namespace('world_cup', 'integer', 'uuid');

-- 3. Add scores
SELECT topn_add('world_cup', 2022, '550e8400-e29b-41d4-a716-446655440000'::uuid, 3);
SELECT topn_add('world_cup', 2022, '660e8400-e29b-41d4-a716-446655440001'::uuid, 1);
SELECT topn_add('world_cup', 2022, '770e8400-e29b-41d4-a716-446655440002'::uuid, 2);
SELECT topn_add('world_cup', 2022, '880e8400-e29b-41d4-a716-446655440003'::uuid, 0);

-- 4. Get the final leaderboard
SELECT * FROM topn('world_cup', 2022, 3);
```

## API Reference

| Function | Description |
|----------|-------------|
| `topn_version()` | Returns the extension version |
| `topn_create_namespace(base_name, uid_type, key_type)` | Creates a table named `topn_<base_name>` with specified column types |
| `topn_add(namespace, uid, key, frequently)` | Adds or increments a count. Returns the new count |
| `topn(namespace, uid, n)` | Returns top n (key, frequently) pairs for the specified uid |

## Performance

TopN is optimized for:
- Fast inserts/updates (O(log n) due to B-tree indexes)
- Efficient top-N queries (uses index on (uid, frequently))
- Large datasets (tested with millions of rows)

## Testing

Run the test suite to verify your installation:

```bash
make installcheck
```
