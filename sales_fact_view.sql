/*
    Anonymized Sales Fact View
    --------------------------
    Portfolio version of an internal ERP/BI sales transformation.

    Purpose:
    - Combine sales invoices and return invoices
    - Aggregate sales quantities and financial amounts
    - Calculate net sales after returns
    - Prepare a fact-like dataset for BI reporting

    Note:
    Original company, database, schema and object names have been anonymized.
*/

CREATE VIEW dbo.vw_FactSales AS

SELECT
    Lst.SalesOfficeCode,
    Lst.SalesOfficeName,
    Lst.BrokerName,
    Lst.CustomerCode,
    Lst.CustomerName,
    Lst.ProductCode,
    Lst.ProductName,
    Lst.UnitName,
    Lst.SaleDate,

    Lst.Quantity,
    Lst.GrossAmount,
    Lst.DiscountAmount,
    Lst.AdditionAmount,
    Lst.NetAmount,

    Lst.ReturnQuantity,
    Lst.ReturnGrossAmount,
    Lst.ReturnDiscountAmount,
    Lst.ReturnAdditionAmount,
    Lst.ReturnNetAmount,

    -- Net values after deducting returns
    ISNULL(Lst.Quantity, 0)
        - ISNULL(Lst.ReturnQuantity, 0) AS NetQuantity,

    ISNULL(Lst.GrossAmount, 0)
        - ISNULL(Lst.ReturnGrossAmount, 0) AS NetGrossAmount,

    ISNULL(Lst.DiscountAmount, 0)
        - ISNULL(Lst.ReturnDiscountAmount, 0) AS NetDiscountAmount,

    ISNULL(Lst.AdditionAmount, 0)
        - ISNULL(Lst.ReturnAdditionAmount, 0) AS NetAdditionAmount,

    ISNULL(Lst.NetAmount, 0)
        - ISNULL(Lst.ReturnNetAmount, 0) AS NetSalesAmount,

    Lst.ItemID,
    Lst.InvoiceNumber

FROM
(
    /* =========================================================
       SALES INVOICES
       ========================================================= */

    SELECT
        SO.Code AS SalesOfficeCode,
        SO.Name AS SalesOfficeName,

        P.Number AS ProductCode,
        P.Name AS ProductName,

        U.Name AS UnitName,

        B.Name AS BrokerName,

        C.Number AS CustomerCode,
        C.Name AS CustomerName,

        I.Date AS SaleDate,

        SUM(II.Quantity) AS Quantity,
        SUM(II.GrossAmount) AS GrossAmount,
        SUM(II.DiscountAmount) AS DiscountAmount,
        SUM(II.AdditionAmount) AS AdditionAmount,
        SUM(II.NetAmount) AS NetAmount,

        0 AS ReturnQuantity,
        0 AS ReturnGrossAmount,
        0 AS ReturnDiscountAmount,
        0 AS ReturnAdditionAmount,
        0 AS ReturnNetAmount,

        II.ItemID,
        I.InvoiceNumber

    FROM Sales.Invoice AS I

    INNER JOIN Sales.Customer AS C
        ON C.CustomerID = I.CustomerID
        AND I.Status <> 6

    INNER JOIN Sales.SalesOffice AS SO
        ON SO.SalesOfficeID = I.SalesOfficeID

    INNER JOIN Sales.InvoiceItem AS II
        ON II.InvoiceID = I.InvoiceID

    INNER JOIN Product.Product AS P
        ON P.ProductID = II.ProductID

    INNER JOIN Product.Unit AS U
        ON U.UnitID = P.UnitID

    LEFT JOIN Sales.Broker AS B
        ON B.BrokerID = I.BrokerID

    GROUP BY
        SO.Code,
        SO.Name,
        P.Number,
        P.Name,
        U.Name,
        B.Name,
        I.Date,
        C.Number,
        C.Name,
        II.ItemID,
        I.InvoiceNumber


    UNION ALL


    /* =========================================================
       RETURN INVOICES
       ========================================================= */

    SELECT
        SO.Code AS SalesOfficeCode,
        SO.Name AS SalesOfficeName,

        P.Number AS ProductCode,
        P.Name AS ProductName,

        U.Name AS UnitName,

        B.Name AS BrokerName,

        C.Number AS CustomerCode,
        C.Name AS CustomerName,

        RI.Date AS SaleDate,

        0 AS Quantity,
        0 AS GrossAmount,
        0 AS DiscountAmount,
        0 AS AdditionAmount,
        0 AS NetAmount,

        SUM(RII.Quantity) AS ReturnQuantity,
        SUM(RII.GrossAmount) AS ReturnGrossAmount,
        SUM(RII.DiscountAmount) AS ReturnDiscountAmount,
        SUM(RII.AdditionAmount) AS ReturnAdditionAmount,
        SUM(RII.NetAmount) AS ReturnNetAmount,

        RII.ItemID,
        RI.InvoiceNumber

    FROM Sales.ReturnInvoice AS RI

    INNER JOIN Sales.Customer AS C
        ON C.CustomerID = RI.CustomerID
        AND RI.Status <> 6

    INNER JOIN Sales.SalesOffice AS SO
        ON SO.SalesOfficeID = RI.SalesOfficeID

    INNER JOIN Sales.ReturnInvoiceItem AS RII
        ON RII.ReturnInvoiceID = RI.ReturnInvoiceID

    INNER JOIN Product.Product AS P
        ON P.ProductID = RII.ProductID

    INNER JOIN Product.Unit AS U
        ON U.UnitID = P.UnitID

    LEFT JOIN Sales.Broker AS B
        ON B.BrokerID = RI.BrokerID

    GROUP BY
        SO.Code,
        SO.Name,
        P.Number,
        P.Name,
        U.Name,
        B.Name,
        RI.Date,
        C.Number,
        C.Name,
        RII.ItemID,
        RI.InvoiceNumber

) AS Lst;
