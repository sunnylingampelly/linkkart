# Fix: Sizes Not Showing on Storefront

## Problem
Size selection is not showing on the product page even though the code is there.

## Root Cause
The `products` table in your **production database** doesn't have the size columns yet. You need to run the SQL migration.

## Solution

### Step 1: Run SQL Migration on Production

Connect to your production MySQL:
```bash
mysql -u linkkart -p linkkart
```

Then run these commands **ONE BY ONE**:

```sql
-- Add sizes column (JSON to store size stock)
ALTER TABLE products 
ADD COLUMN sizes JSON DEFAULT NULL AFTER stock_quantity;

-- Add has_sizes flag
ALTER TABLE products 
ADD COLUMN has_sizes BOOLEAN DEFAULT FALSE AFTER sizes;

-- Add size chart image
ALTER TABLE products 
ADD COLUMN size_chart_image VARCHAR(255) DEFAULT NULL AFTER has_sizes;

-- Verify columns were added
DESCRIBE products;
```

### Step 2: Verify Columns Exist

After running the above, check:
```sql
DESCRIBE products;
```

You should see:
```
| sizes            | json         | YES  |     | NULL    |       |
| has_sizes        | tinyint(1)   | YES  |     | 0       |       |
| size_chart_image | varchar(255) | YES  |     | NULL    |       |
```

### Step 3: Check Existing Products

```sql
SELECT id, name, has_sizes, sizes FROM products LIMIT 5;
```

If `has_sizes` is 0 or NULL for all products, that's why sizes aren't showing!

### Step 4: Test with a Product

Update one product to have sizes:
```sql
UPDATE products 
SET has_sizes = 1,
    sizes = '{"S": 10, "M": 15, "L": 20, "XL": 5}'
WHERE id = 1;

-- Verify
SELECT id, name, has_sizes, sizes FROM products WHERE id = 1;
```

### Step 5: Refresh Storefront

1. Open the product page in browser
2. Hard refresh (Ctrl+Shift+R or Cmd+Shift+R)
3. You should now see size selection!

## Why This Happened

1. ✅ Backend code was updated (includes size columns in API)
2. ✅ Frontend code was updated (shows size selection UI)
3. ❌ Database migration was NOT run on production
4. ❌ Products don't have size data yet

## Quick Test

After running the SQL migration, test with this product:

```sql
-- Update a test product
UPDATE products 
SET 
    has_sizes = 1,
    sizes = '{"S": 5, "M": 10, "L": 15, "XL": 8, "XXL": 3}',
    size_chart_image = NULL
WHERE id = (SELECT id FROM products LIMIT 1);
```

Then open that product on the storefront - you should see size buttons!

## Mobile App

In the mobile app, when adding/editing products:
1. Enable "Has Sizes" toggle
2. Set stock for each size
3. Optionally upload size chart
4. Save product

The sizes will then show on the storefront.

## Files Already Updated
- ✅ `backend/public/api.php` - Returns size data
- ✅ `storefront/src/pages/ProductPage.js` - Shows size selection
- ✅ `storefront/src/components/CheckoutDrawer.js` - Includes size in order

## What You Need to Do
- ⏳ Run SQL migration on production database
- ⏳ Add sizes to products via mobile app
- ⏳ Test on storefront

## Complete SQL Script

If you want to run everything at once:

```sql
-- Add size columns
ALTER TABLE products ADD COLUMN sizes JSON DEFAULT NULL AFTER stock_quantity;
ALTER TABLE products ADD COLUMN has_sizes BOOLEAN DEFAULT FALSE AFTER sizes;
ALTER TABLE products ADD COLUMN size_chart_image VARCHAR(255) DEFAULT NULL AFTER has_sizes;

-- Verify
DESCRIBE products;

-- Test with one product
UPDATE products 
SET has_sizes = 1,
    sizes = '{"S": 10, "M": 15, "L": 20, "XL": 10, "XXL": 5}'
WHERE id = 1;

-- Check result
SELECT id, name, has_sizes, sizes FROM products WHERE id = 1;
```

After running this, refresh the storefront and you should see size selection! 🎉
