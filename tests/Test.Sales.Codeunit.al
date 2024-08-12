codeunit 50001 "Test Sales Orders"
{
    Subtype = Test;

    [Test]
    procedure Test_OriginalQuantityIsPopulatedOnNewLines()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        Item: Record Item;
    begin
        // [GIVEN] A Sales Order
        // [GIVEN] A Sales Order
        SalesHeader := TestFixturesSales.CreateSalesOrder();

        // [WHEN] When we add a new line
        TestFixturesSales.CreateSalesLines(SalesHeader, 1);

        // [THEN] Then Expected Output is the Orginal Order Qty. is populated with the same value as the Quantity field 
        TestHelpers.AreEqual(SalesLine."DOK Original Order Qty.", SalesLine.Quantity, 'Original Quantity is not populated with the same value as the Quantity field');
    end;

    [Test]
    procedure Test_OriginalQuantityIsNotModifiedAfterQuantityModified()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        Item: Record Item;
    begin
        // [GIVEN] A Sales Order
        // [GIVEN] A Sales Order
        SalesHeader := TestFixturesSales.CreateSalesOrder();

        // [WHEN] When we add a new line
        TestFixturesSales.CreateSalesLines(SalesHeader, 1);

        // [WHEN] When we modify the Quantity
        SalesLine.Get(SalesLine."Document Type"::Order, SalesHeader."No.", 10000);
        SalesLine.Validate(Quantity, 0);
        SalesLine.MODIFY(TRUE);

        // [THEN] Then Expected Output is the Orginal Order Qty. is populated with the same value as the Quantity field 
        TestHelpers.AreEqual(SalesLine."DOK Original Order Qty.", SalesLine.Quantity, 'Original Quantity is not populated with the same value as the Quantity field');
    end;

    [Test]
    procedure Test_OriginalQuantityIsPassedToSalesInvoiceLinesOnPost()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        Item: Record Item;
        SalesInvoiceLine: Record "Sales Invoice Line";
        SalesPost: Codeunit "Sales-Post";
    begin
        // [GIVEN] A Sales Order
        SalesHeader := TestFixturesSales.CreateSalesOrder();

        // [WHEN] When we add a new line and post the Sales Order
        TestFixturesSales.CreateSalesLines(SalesHeader, 1);
        SalesPost.Run(SalesHeader);

        // [THEN] The Orginal Order Qty. is populated with the same value as the Quantity field for each Sales Invoice Line
        SalesInvoiceLine.SETRANGE("Document No.", TestHelpersSales.GetLastPostedSalesInvoice()."No.");
        SalesInvoiceLine.SETRANGE(Type, SalesInvoiceLine.Type::Item);
        if SalesInvoiceLine.FINDSET then
            repeat
                TestHelpers.AreEqual(SalesInvoiceLine."DOK Original Order Qty.", SalesInvoiceLine.Quantity, 'Original Quantity is not populated with the same value as the Quantity field');
            until SalesInvoiceLine.NEXT = 0;
    end;

    [Test]
    procedure "Test_CalculateFreightOnRelease1Line"()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        ReleaseSalesDoc: Codeunit "Release Sales Document";
    begin
        // [GIVEN] A Sales Order with 1 Sales Line
        SalesHeader := TestFixturesSales.CreateSalesOrder();
        TestFixturesSales.CreateSalesLines(SalesHeader, 1);

        // [WHEN] When we release the order
        ReleaseSalesDoc.Run(SalesHeader);

        // [THEN] The Sales Header contains a Freight line 
        TestHelpers.AssertTrue(SalesLine.GET(SalesLine."Document Type"::Order, SalesHeader."No.", 999999), 'Freight Sales Line not found');
        // [THEN] The Freight line has a Quantity > 0
        TestHelpers.AssertTrue(SalesLine.Quantity > 0, 'Freight Quantity is not greater than 0');

    end;

    [Test]
    procedure "Test_CalculateFreightOnRelease10Lines"()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        ReleaseSalesDoc: Codeunit "Release Sales Document";
    begin
        // [GIVEN] A Sales Order with 1 Sales Line
        SalesHeader := TestFixturesSales.CreateSalesOrder();
        TestFixturesSales.CreateSalesLines(SalesHeader, 10);

        // [WHEN] When we release the order
        ReleaseSalesDoc.Run(SalesHeader);

        // [THEN] The Sales Header contains a Freight line 
        TestHelpers.AssertTrue(SalesLine.GET(SalesLine."Document Type"::Order, SalesHeader."No.", 999999), 'Freight Sales Line not found');
        // [THEN] The Freight line has a Quantity > 0
        TestHelpers.AssertTrue(SalesLine.Quantity > 0, 'Freight Quantity is not greater than 0');

    end;

    var
        TestHelpers: Codeunit "DOK Test Helpers";
        TestFixturesSales: Codeunit "DOK Test Fixtures Sales";
        TestHelpersSales: Codeunit "Test Helpers Sales";

}