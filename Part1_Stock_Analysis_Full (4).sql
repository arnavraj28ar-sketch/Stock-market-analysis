USE StockMarket;
GO

/* TASK 1: Trading history of Bajaj Auto */
SELECT
    COUNT(*) AS trading_days,
    MIN([Date]) AS first_day,
    MAX([Date]) AS last_day
FROM dbo.Bajaj_auto;
GO

/* TASK 2: Eicher Motors' five highest closing prices */
SELECT TOP (5)
    [Date],
    Close_Price
FROM dbo.eicher_motors
ORDER BY Close_Price DESC;
GO

/* TASK 3: TCS average closing price by year */
SELECT
    YEAR(TRY_CONVERT(date, [Date])) AS [year],
    ROUND(AVG(CAST(Close_Price AS FLOAT)), 2) AS avg_close
FROM dbo.tcs
GROUP BY YEAR(TRY_CONVERT(date, [Date]))
ORDER BY [year];
GO

/* TASK 4: Rows with missing deliverable quantity across all six stocks */
SELECT 'bajaj_auto' AS stock, [Date]
FROM dbo.Bajaj_auto
WHERE Deliverable_Quantity IS NULL

UNION ALL

SELECT 'eicher_motors' AS stock, [Date]
FROM dbo.eicher_motors
WHERE Deliverable_Quantity IS NULL

UNION ALL

SELECT 'hero_motocorp' AS stock, [Date]
FROM dbo.hero_motocorp
WHERE Deliverable_Quantity IS NULL

UNION ALL

SELECT 'infosys' AS stock, [Date]
FROM dbo.infosys
WHERE Deliverable_Quantity IS NULL

UNION ALL

SELECT 'tcs' AS stock, [Date]
FROM dbo.tcs
WHERE Deliverable_Quantity IS NULL

UNION ALL

SELECT 'tvs_motors' AS stock, [Date]
FROM dbo.tvs_motors
WHERE Deliverable_Quantity IS NULL
ORDER BY stock, [Date];
GO
