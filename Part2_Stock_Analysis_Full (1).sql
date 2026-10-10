USE StockMarket;
GO

/* TASK 5: Moving averages for Bajaj Auto */
DROP TABLE IF EXISTS dbo.bajaj1;
GO
WITH StockData AS
(
    SELECT [Date], CAST(Close_Price AS FLOAT) AS Close_Price,
           ROW_NUMBER() OVER (ORDER BY [Date]) AS rn,
           AVG(CAST(Close_Price AS FLOAT)) OVER (ORDER BY [Date] ROWS BETWEEN 19 PRECEDING AND CURRENT ROW) AS avg20,
           AVG(CAST(Close_Price AS FLOAT)) OVER (ORDER BY [Date] ROWS BETWEEN 49 PRECEDING AND CURRENT ROW) AS avg50
    FROM dbo.Bajaj_auto
)
SELECT [Date], Close_Price,
       CASE WHEN rn >= 20 THEN ROUND(avg20, 2) END AS ma20,
       CASE WHEN rn >= 50 THEN ROUND(avg50, 2) END AS ma50
INTO dbo.bajaj1
FROM StockData;
GO
SELECT * FROM dbo.bajaj1 ORDER BY [Date];
GO

/* TASK 6: Master table */
DROP TABLE IF EXISTS dbo.master_table;
GO
SELECT b.[Date],
       CAST(b.Close_Price AS FLOAT) AS bajaj,
       CAST(t.Close_Price AS FLOAT) AS tcs,
       CAST(v.Close_Price AS FLOAT) AS tvs,
       CAST(i.Close_Price AS FLOAT) AS infosys,
       CAST(e.Close_Price AS FLOAT) AS eicher,
       CAST(h.Close_Price AS FLOAT) AS hero
INTO dbo.master_table
FROM dbo.Bajaj_auto AS b
JOIN dbo.tcs AS t ON t.[Date] = b.[Date]
JOIN dbo.tvs_motors AS v ON v.[Date] = b.[Date]
JOIN dbo.infosys AS i ON i.[Date] = b.[Date]
JOIN dbo.eicher_motors AS e ON e.[Date] = b.[Date]
JOIN dbo.hero_motocorp AS h ON h.[Date] = b.[Date];
GO
SELECT * FROM dbo.master_table ORDER BY [Date];
GO

/* TASK 7: Golden-cross signals for Bajaj Auto */
DROP TABLE IF EXISTS dbo.bajaj2;
GO
WITH Lagged AS
(
    SELECT [Date], Close_Price, ma20, ma50,
           LAG(ma20) OVER (ORDER BY [Date]) AS prev_ma20,
           LAG(ma50) OVER (ORDER BY [Date]) AS prev_ma50
    FROM dbo.bajaj1
)
SELECT [Date], Close_Price,
       CASE
           WHEN ma20 IS NULL OR ma50 IS NULL OR prev_ma20 IS NULL OR prev_ma50 IS NULL THEN 'Hold'
           WHEN prev_ma20 <= prev_ma50 AND ma20 > ma50 THEN 'Buy'
           WHEN prev_ma20 >= prev_ma50 AND ma20 < ma50 THEN 'Sell'
           ELSE 'Hold'
       END AS [signal]
INTO dbo.bajaj2
FROM Lagged;
GO
SELECT * FROM dbo.bajaj2 ORDER BY [Date];
GO

/* TASK 8: Count Bajaj Auto signals */
SELECT [signal], COUNT(*) AS total_days
FROM dbo.bajaj2
GROUP BY [signal]
ORDER BY [signal];
GO

/* TASK 9: Signal for the requested date and sanity checks */
SELECT [signal] FROM dbo.bajaj2 WHERE [Date] = '2018-06-21';
GO
SELECT [Date], [signal]
FROM dbo.bajaj2
WHERE [Date] IN ('2015-05-18', '2016-01-04')
ORDER BY [Date];
GO

/* TASK 10: Signals for all six stocks, using unrounded moving averages */
DROP TABLE IF EXISTS dbo.all_stock_signals;
GO
WITH Prices AS
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
MovingAverages AS
(
    SELECT stock, [Date], close_price,
           ROW_NUMBER() OVER (PARTITION BY stock ORDER BY [Date]) AS rn,
           AVG(close_price) OVER (PARTITION BY stock ORDER BY [Date] ROWS BETWEEN 19 PRECEDING AND CURRENT ROW) AS ma20,
           AVG(close_price) OVER (PARTITION BY stock ORDER BY [Date] ROWS BETWEEN 49 PRECEDING AND CURRENT ROW) AS ma50
    FROM Prices
),
Lagged AS
(
    SELECT stock, [Date], close_price, rn, ma20, ma50,
           LAG(ma20) OVER (PARTITION BY stock ORDER BY [Date]) AS prev_ma20,
           LAG(ma50) OVER (PARTITION BY stock ORDER BY [Date]) AS prev_ma50
    FROM MovingAverages
),
Signals AS
(
    SELECT stock, [Date],
           CASE
               WHEN ma20 IS NULL OR ma50 IS NULL OR prev_ma20 IS NULL OR prev_ma50 IS NULL THEN 'Hold'
               WHEN prev_ma20 <= prev_ma50 AND ma20 > ma50 THEN 'Buy'
               WHEN prev_ma20 >= prev_ma50 AND ma20 < ma50 THEN 'Sell'
               ELSE 'Hold'
           END AS [signal]
    FROM Lagged
),
SignalCounts AS
(
    SELECT stock,
           SUM(CASE WHEN [signal] = 'Buy' THEN 1 ELSE 0 END) AS buys,
           SUM(CASE WHEN [signal] = 'Sell' THEN 1 ELSE 0 END) AS sells
    FROM Signals
    GROUP BY stock
),
LatestSignal AS
(
    SELECT stock, [Date] AS last_signal_date, [signal] AS last_signal,
           ROW_NUMBER() OVER (PARTITION BY stock ORDER BY [Date] DESC) AS rn_latest
    FROM Signals
    WHERE [signal] IN ('Buy', 'Sell')
)
SELECT c.stock, c.buys, c.sells, l.last_signal_date, l.last_signal
INTO dbo.all_stock_signals
FROM SignalCounts AS c
LEFT JOIN LatestSignal AS l
    ON l.stock = c.stock AND l.rn_latest = 1;
GO
SELECT * FROM dbo.all_stock_signals ORDER BY stock;
GO
SELECT SUM(buys) AS total_buys, SUM(sells) AS total_sells
FROM dbo.all_stock_signals;
GO
