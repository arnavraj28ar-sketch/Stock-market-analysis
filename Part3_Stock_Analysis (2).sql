/*
Stock Market Analysis - Part 3
SQL Server Management Studio (SSMS)
Tasks 11, 12 and 13

Database expected: StockMarket
Tables expected:
dbo.Bajaj_auto, dbo.eicher_motors, dbo.hero_motocorp,
dbo.infosys, dbo.tcs, dbo.tvs_motors

Run each task section separately if you prefer. Each task is an independent query.
*/

USE StockMarket;
GO

/* =========================================================
   TASK 11 — WHO WENT UP?
   First close, last close and percentage change for each stock.
   Expected: 6 rows. TVS Motors should be around +86.9%.
   ========================================================= */

WITH prices AS
(
    SELECT 'Bajaj Auto' AS stock, [Date], CAST(Close_Price AS FLOAT) AS close_price FROM dbo.Bajaj_auto
    UNION ALL
    SELECT 'Eicher Motors', [Date], CAST(Close_Price AS FLOAT) FROM dbo.eicher_motors
    UNION ALL
    SELECT 'Hero Motocorp', [Date], CAST(Close_Price AS FLOAT) FROM dbo.hero_motocorp
    UNION ALL
    SELECT 'Infosys', [Date], CAST(Close_Price AS FLOAT) FROM dbo.infosys
    UNION ALL
    SELECT 'TCS', [Date], CAST(Close_Price AS FLOAT) FROM dbo.tcs
    UNION ALL
    SELECT 'TVS Motors', [Date], CAST(Close_Price AS FLOAT) FROM dbo.tvs_motors
),
ends AS
(
    SELECT stock, MIN([Date]) AS first_date, MAX([Date]) AS last_date
    FROM prices
    GROUP BY stock
)
SELECT
    e.stock,
    ROUND(first_price.close_price, 2) AS first_close,
    ROUND(last_price.close_price, 2) AS last_close,
    ROUND(
        100.0 * (last_price.close_price - first_price.close_price)
        / NULLIF(first_price.close_price, 0),
        1
    ) AS pct_change
FROM ends AS e
JOIN prices AS first_price
    ON first_price.stock = e.stock
   AND first_price.[Date] = e.first_date
JOIN prices AS last_price
    ON last_price.stock = e.stock
   AND last_price.[Date] = e.last_date
ORDER BY pct_change DESC;
GO


/* =========================================================
   TASK 12 — THE DATA TRAP
   Find each stock's worst day-to-day percentage move.
   Expected: 6 rows. Two unusually large negative moves point
   to corporate actions; investigate the stock/date pairs.
   ========================================================= */

WITH prices AS
(
    SELECT 'Bajaj Auto' AS stock, [Date], CAST(Close_Price AS FLOAT) AS close_price FROM dbo.Bajaj_auto
    UNION ALL
    SELECT 'Eicher Motors', [Date], CAST(Close_Price AS FLOAT) FROM dbo.eicher_motors
    UNION ALL
    SELECT 'Hero Motocorp', [Date], CAST(Close_Price AS FLOAT) FROM dbo.hero_motocorp
    UNION ALL
    SELECT 'Infosys', [Date], CAST(Close_Price AS FLOAT) FROM dbo.infosys
    UNION ALL
    SELECT 'TCS', [Date], CAST(Close_Price AS FLOAT) FROM dbo.tcs
    UNION ALL
    SELECT 'TVS Motors', [Date], CAST(Close_Price AS FLOAT) FROM dbo.tvs_motors
),
daily_moves AS
(
    SELECT
        stock,
        [Date],
        close_price,
        LAG(close_price) OVER
            (PARTITION BY stock ORDER BY [Date]) AS previous_close
    FROM prices
),
returns AS
(
    SELECT
        stock,
        [Date],
        close_price,
        100.0 * (close_price / NULLIF(previous_close, 0) - 1.0) AS pct_move
    FROM daily_moves
    WHERE previous_close IS NOT NULL
),
ranked AS
(
    SELECT
        stock,
        [Date],
        close_price,
        pct_move,
        ROW_NUMBER() OVER
            (PARTITION BY stock ORDER BY pct_move ASC) AS worst_rank
    FROM returns
)
SELECT
    stock,
    [Date],
    ROUND(close_price, 2) AS close_price,
    ROUND(pct_move, 1) AS pct_move
FROM ranked
WHERE worst_rank = 1
ORDER BY pct_move ASC;
GO


/* =========================================================
   TASK 13 — FIX IT
   Adjust prices before the 1:1 bonus dates by dividing by 2.
   The event date is the first day the stock trades at the
   new, lower price level.

   Event dates used in this dataset:
   TCS     : 2018-05-31
   Infosys : 2015-06-15

   Expected: 2 rows (Infosys and TCS).
   ========================================================= */

WITH adjusted AS
(
    SELECT
        'TCS' AS stock,
        [Date],
        CASE
            WHEN [Date] < '2018-05-31'
                THEN CAST(Close_Price AS FLOAT) / 2.0
            ELSE CAST(Close_Price AS FLOAT)
        END AS adj_close
    FROM dbo.tcs

    UNION ALL

    SELECT
        'Infosys' AS stock,
        [Date],
        CASE
            WHEN [Date] < '2015-06-15'
                THEN CAST(Close_Price AS FLOAT) / 2.0
            ELSE CAST(Close_Price AS FLOAT)
        END AS adj_close
    FROM dbo.infosys
),
period_ends AS
(
    SELECT
        stock,
        MAX(CASE WHEN [Date] = '2015-01-01' THEN adj_close END) AS first_close,
        MAX(CASE WHEN [Date] = '2018-07-31' THEN adj_close END) AS last_close
    FROM adjusted
    GROUP BY stock
)
SELECT
    stock,
    ROUND(
        100.0 * (last_close / NULLIF(first_close, 0) - 1.0),
        1
    ) AS adjusted_pct_change
FROM period_ends
ORDER BY stock;
GO

/*
IMPORTANT:
1. Run Task 11, Task 12 and Task 13 one section at a time if easier.
2. For Task 12, check the two extreme stock/date rows against reliable
   corporate-action news before writing your insights PDF.
3. If the date stored in your SQL Server table is a text column rather
   than DATE, the ISO format YYYY-MM-DD is still the expected format
   for these comparisons, provided the imported values use that format.
*/
