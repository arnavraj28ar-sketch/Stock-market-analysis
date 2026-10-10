# Stock Market Analysis Using SQL

## Project Overview
This project analyses historical stock market data for six companies:
- Bajaj Auto
- TCS
- TVS Motors
- Hero MotoCorp
- Infosys
- Eicher Motors

The project uses SQL Server to explore stock data, calculate moving
averages, generate trading signals, compare stock performance, and
investigate unusual price movements.

## Objectives
- Explore historical stock market data.
- Calculate 20-day and 50-day moving averages.
- Generate Buy, Sell, and Hold signals.
- Compare the price performance of six stocks.
- Identify unusually large daily price movements.
- Adjust historical prices to account for bonus issues.

## Tools and Technologies
- Microsoft SQL Server
- SQL Server Management Studio (SSMS)
- SQL

## SQL Concepts Used
- Aggregate Functions
- GROUP BY and ORDER BY
- Joins
- Common Table Expressions (CTEs)
- CASE Expressions
- Window Functions
- Moving Averages
- Conditional Aggregation

## Key Findings
- TVS Motors and Eicher Motors showed strong raw price growth.
- TCS and Infosys had unusually large price drops associated with
  bonus-related price adjustments.
- Moving-average crossovers were used to generate trading signals.
- Corporate actions need to be considered when comparing historical prices.

## Project Files
- Part 1: Data exploration
- Part 2: Moving averages and trading signals
- Part 3: Stock performance, unusual price movements, and bonus adjustments
- Insights Report: Summary of findings and limitations

## Limitations
This analysis does not include dividends, brokerage charges, taxes,
slippage, company news, or broader market conditions. Moving-average
signals are historical indicators and do not guarantee future performance.

## Disclaimer
This project is for educational purposes only and is not investment advice.
