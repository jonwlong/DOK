codeunit 50001 "DOK Test Sales Orders"
{
    Subtype = Test;

    [Test]
    procedure Test_PostSalesOrder()
    var
        SalesHeader: Record "Sales Header";
        SalesPost: Codeunit "Sales-Post";
        PostedWithoutErrors: Boolean;
    begin

        // [GIVEN] a Sales Order with 1 Sales Line
        SalesHeader := TestFixturesSales.CreateSalesOrder();
        TestFixturesSales.AddSalesLinesToSalesHeader(SalesHeader, 1);
        SalesHeader.Validate(Ship, true);
        SalesHeader.Validate(Invoice, true);
        SalesHeader.Modify(true);

        // [WHEN] we post the Sales Order
        Commit();
        PostedWithoutErrors := SalesPost.Run(SalesHeader);

        // [THEN] the Sales Order is posted without error
        TestHelpers.AssertTrue(PostedWithoutErrors, 'Sales Order was not posted without error. %1', GetLastErrorText());

    end;

    [Test]
    procedure Test_CalculateFreightOnRelease1Line()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        ReleaseSalesDoc: Codeunit "Release Sales Document";
    begin
        // [GIVEN] A Sales Order with 1 Sales Line
        SalesHeader := TestFixturesSales.CreateSalesOrder();
        TestFixturesSales.AddSalesLinesToSalesHeader(SalesHeader, 1);

        // [WHEN] When we release the order
        ReleaseSalesDoc.Run(SalesHeader);

        // [THEN] The Sales Header contains a Freight line 
        TestHelpers.AssertTrue(SalesLine.Get(SalesLine."Document Type"::Order, SalesHeader."No.", 999999), 'Freight Sales Line not found');

        // [THEN] The Freight line has a Quantity > 0
        TestHelpers.AssertTrue(SalesLine.Quantity > 0, 'Freight Quantity is not greater than 0');

    end;

    [Test]
    procedure Test_CalculateFreightOnRelease10Lines()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        ReleaseSalesDoc: Codeunit "Release Sales Document";
    begin
        // [GIVEN] A Sales Order with 10 Sales Lines
        SalesHeader := TestFixturesSales.CreateSalesOrder();
        TestFixturesSales.AddSalesLinesToSalesHeader(SalesHeader, 10);

        // [WHEN] When we release the order
        ReleaseSalesDoc.Run(SalesHeader);

        // [THEN] The Sales Header contains a Freight line 
        TestHelpers.AssertTrue(SalesLine.Get(SalesLine."Document Type"::Order, SalesHeader."No.", 999999), 'Freight Sales Line not found');

        // [THEN] The Freight line has a Quantity > 0
        TestHelpers.AssertTrue(SalesLine.Quantity > 0, 'Freight Quantity is not greater than 0');

    end;

    var
        TestHelpers: Codeunit "DOK Test Helpers";
        TestFixturesSales: Codeunit "DOK Test Fixtures Sales";
        Initialized: Boolean;
}