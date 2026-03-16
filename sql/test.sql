BEGIN;
SELECT '=== Starting TopN Extension Tests ===' as test_log;
SELECT 'Test 1: Version Function' as test_log;
SELECT topn_version();
ROLLBACK;

