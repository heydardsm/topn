CREATE EXTENSION IF NOT EXISTS topn;
BEGIN;
SELECT '=== Starting TopN Extension Tests ===' as test_log;

SELECT 'Test 1: Version Function' as test_log;
SELECT topn_version();

SELECT 'Test 2: Create namespace with default types (varchar(256))' as test_log;
SELECT topn_create_namespace('test1');

SELECT 'Table created:' as info, tablename FROM pg_tables WHERE tablename = 'topn_test1';

SELECT 'Table structure:' as info, column_name, data_type, character_maximum_length FROM information_schema.columns WHERE table_name = 'topn_test1' ORDER BY ordinal_position;

SELECT 'Test 3: Create namespace with integer uid, varchar key' as test_log;
SELECT topn_create_namespace('test2', 'integer', 'varchar(100)');
SELECT 'Table created:' as info, tablename FROM pg_tables WHERE tablename = 'topn_test2';

SELECT 'Table structure:' as info, column_name, data_type, character_maximum_length FROM information_schema.columns WHERE table_name = 'topn_test2' ORDER BY ordinal_position;

SELECT 'Test 4: Create namespace with date uid, varchar key' as test_log;
SELECT topn_create_namespace('test3', 'date', 'varchar(100)');
SELECT 'Table created:' as info, tablename FROM pg_tables WHERE tablename = 'topn_test3';

SELECT 'Table structure:' as info, column_name, data_type, character_maximum_length FROM information_schema.columns WHERE table_name = 'topn_test3' ORDER BY ordinal_position;

SELECT 'Test 5: Create namespace with uuid uid, integer key' as test_log;
SELECT topn_create_namespace('test4', 'uuid', 'integer');
SELECT 'Table created:' as info, tablename FROM pg_tables WHERE tablename = 'topn_test4';

SELECT 'Table structure:' as info, column_name, data_type, character_maximum_length FROM information_schema.columns WHERE table_name = 'topn_test4' ORDER BY ordinal_position;

SELECT 'Test 6: Create namespace with timestamp uid, bigint key' as test_log;
SELECT topn_create_namespace('test5', 'timestamp', 'bigint');
SELECT 'Table created:' as info, tablename FROM pg_tables WHERE tablename = 'topn_test5';

SELECT 'Table structure:' as info, column_name, data_type, character_maximum_length FROM information_schema.columns WHERE table_name = 'topn_test5' ORDER BY ordinal_position;

ROLLBACK;

BEGIN;

SELECT 'Test 7: Error - Create duplicate namespace (should fail)' as test_log;
SELECT topn_create_namespace('test1');
ROLLBACK;
SELECT 'Duplicate creation properly blocked' as result;

BEGIN;

SELECT 'Test 8: Error - Invalid type (should fail)' as test_log;
SELECT topn_create_namespace('test6', 'invalid_type', 'varchar');
ROLLBACK;
SELECT 'Invalid type properly blocked' as result;

BEGIN;

SELECT 'Test 9: Add data with different types' as test_log;
SELECT topn_create_namespace('test1');
SELECT topn_add('test1', 'user1'::varchar, 'click'::varchar, 5);
SELECT topn_add('test1', 'user1'::varchar, 'view'::varchar, 3);
SELECT topn_add('test1', 'user2'::varchar, 'click'::varchar, 2);

SELECT 'Data in test1:' as info;
SELECT * FROM topn_test1 ORDER BY uid, frequently DESC;

SELECT topn_create_namespace('test2', 'integer', 'varchar(100)');
SELECT topn_add('test2', 12345, 'login'::varchar, 10);
SELECT topn_add('test2', 12345, 'page_view'::varchar, 7);
SELECT topn_add('test2', 67890, 'login'::varchar, 5);
SELECT topn_add('test2', 12345, 'logout'::varchar, 2);

SELECT 'Data in test2 (integer uid):' as info;
SELECT * FROM topn_test2 ORDER BY uid, frequently DESC;

SELECT topn_create_namespace('test3', 'date', 'varchar(100)');
SELECT topn_add('test3', '2026-03-17'::date, 'daily_active'::varchar, 100);
SELECT topn_add('test3', '2026-03-17'::date, 'daily_active'::varchar, 85);
SELECT topn_add('test3', '2026-03-17'::date, 'new_users'::varchar, 25);

SELECT 'Data in test3 (date uid):' as info;
SELECT * FROM topn_test3 ORDER BY uid, frequently DESC;

SELECT topn_create_namespace('test4', 'uuid', 'integer');
SELECT topn_add('test4', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'::uuid, 42, 15);
SELECT topn_add('test4', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'::uuid, 7, 8);
SELECT topn_add('test4', 'b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a22'::uuid, 42, 5);

SELECT 'Data in test4 (uuid uid, int key):' as info;
SELECT * FROM topn_test4 ORDER BY uid, frequently DESC;

SELECT topn_create_namespace('test5', 'timestamp', 'bigint');
SELECT topn_add('test5', '2024-01-01 10:00:00'::timestamp, 1000, 50);
SELECT topn_add('test5', '2024-01-01 10:00:00'::timestamp, 2000, 30);
SELECT topn_add('test5', '2024-01-01 11:00:00'::timestamp, 1000, 20);

SELECT 'Data in test5 (timestamp uid, bigint key):' as info;
SELECT * FROM topn_test5 ORDER BY uid, frequently DESC;

ROLLBACK;

