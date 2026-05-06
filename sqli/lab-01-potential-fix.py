# fix_lab01.py

# NOTE: this is not a standalone script you run or drop into a project.
# It represents the fix concept — in a real app this function would sit inside
# a route handler, for example @app.route("/products") in Flask.
# It gets called when someone hits /products?category=Gifts, and returns the
# rows that the route then sends back as a response.

# ROOT CAUSE
# The category parameter is taken directly from the URL and concatenated into the SQL query.
# This lets an attacker modify the query structure itself, not just the data.
# Payload: ' OR 1=1-- makes the query return ALL products, including unreleased ones.
# Resulting query: SELECT * FROM products WHERE category = '' OR 1=1--' AND released = 1

# FIX: parameterised queries
# Instead of building the SQL string with the user input directly inside it,
# the value is passed separately as a tuple to cursor.execute().
# The database driver treats category purely as data, never as SQL.
# So ' OR 1=1-- becomes a search for a product literally named ' OR 1=1--,
# finds nothing, and returns an empty result.
# The query structure is fixed at parse time — user input cannot alter it.

import sqlite3

def get_products(category: str):
    # category comes from the URL, e.g. /products?category=Gifts
    conn = sqlite3.connect("shop.db")
    cursor = conn.cursor()

    # ? is the placeholder — the driver safely binds category here as a literal value
    query = "SELECT * FROM products WHERE category = ? AND released = 1"
    cursor.execute(query, (category,))

    # returns the matching rows, which the route handler sends back as a response
    return cursor.fetchall()
