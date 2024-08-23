codeunit 50001 "DOK Test Sales Orders"
{
    Subtype = Test;

    local procedure Initialize()
    var
        Resource: Record Resource;
        Setup: Record "DOK Setup";
        FreightCode: Code[20];
    begin

        if Initialized then
            exit;
        Initialized := true;
        FreightCode := Utilities.GetRandomCode20();
        if not Setup.Get() then begin
            Setup.Init();
            Setup."Freight No." := FreightCode;
            Setup.Insert();
        end else begin
            Setup."Freight No." := FreightCode;
            Setup.Modify()
        end;
        TestHelpersUtilities.CreateResource(Resource, FreightCode);
        WorkDate(Today);

    end;

    procedure CreateNoSeriesForMST()
    var
    begin
        TestHelpersUtilities.CreateNoSeries('MST');
        TestHelpersUtilities.CreateNoSeriesLine('MST', '10000', '999999');
    end;

    [Test]
    procedure Test_PostSalesOrder()
    var
        SalesHeader: Record "Sales Header";
        SalesPost: Codeunit "Sales-Post";
        PostedWithoutErrors: Boolean;
    begin
        Initialize();

        // [GIVEN] a Sales Order with 1 Sales Line
        SalesHeader := TestFixturesSales.CreateSalesOrder();
        TestFixturesSales.AddSalesLinesToSalesHeader(SalesHeader, 1);
        SalesHeader.Validate(Ship, true);
        SalesHeader.Validate(Invoice, true);
        SalesHeader.Modify(true);

        // [WHEN] we post the Sales Order
        Commit();
        PostedWithoutErrors := SalesPost.Run(SalesHeader);

        // [THEN] The Sales Order was posted without error
        TestHelpers.AssertTrue(PostedWithoutErrors, 'Sales Order was not posted without error. %1', GetLastErrorText());

    end;

    [Test]
    procedure Test_CalculateFreightOnRelease1Line()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        ReleaseSalesDoc: Codeunit "Release Sales Document";
    begin

        Initialize();

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

    [Test]
    procedure Test_OriginalQuantityIsPopulatedOnNewLinesOnRelease()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        ReleaseSalesDoc: Codeunit "Release Sales Document";
    begin

        // [Setup]
        Initialize();

        // [GIVEN] A Sales Order with 5 lines
        SalesHeader := TestFixturesSales.CreateSalesOrderWithSalesLines(5);

        // [WHEN] When we release the order
        ReleaseSalesDoc.Run(SalesHeader);

        // [THEN] the Orginal Order Qty. is populated with the same value as the Quantity field
        SalesLine.SetRange("Document Type", SalesLine."Document Type"::Order);
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetRange("Type", SalesLine.Type::Item);
        if SalesLine.FindSet() then
            repeat
                TestHelpers.AssertTrue(SalesLine."DOK Original Order Qty." = SalesLine.Quantity,
                'Original Quantity %1 is not populated with the same value as the Quantity field %2', SalesLine."DOK Original Order Qty.", SalesLine.Quantity);
            until SalesLine.Next() = 0;
    end;

    [Test]
    procedure Test_OriginalQuantityNotChangedAfterQuantityModifiedThenReleased()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        ReleaseSalesDoc: Codeunit "Release Sales Document";
    begin

        // [Setup]
        Initialize();

        // [GIVEN] A Sales Order with 5 lines
        SalesHeader := TestFixturesSales.CreateSalesOrderWithSalesLines(5);

        // [WHEN] When we release the order reopend and modify the Quantity on each line
        ReleaseSalesDoc.Run(SalesHeader);
        ReleaseSalesDoc.PerformManualReopen(SalesHeader);
        SalesLine.SetRange("Document Type", SalesLine."Document Type"::Order);
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetRange("Type", SalesLine.Type::Item);
        if SalesLine.FindSet() then
            repeat
                SalesLine.Validate(Quantity, SalesLine.Quantity + 1);
                SalesLine.Modify(true);
            until SalesLine.Next() = 0;

        ReleaseSalesDoc.Run(SalesHeader);

        // [THEN] Quantity is not equal to Original Quantity
        SalesLine.SetRange("Document Type", SalesLine."Document Type"::Order);
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetRange("Type", SalesLine.Type::Item);
        if SalesLine.FindSet() then
            repeat
                TestHelpers.AssertTrue(SalesLine."DOK Original Order Qty." <> SalesLine.Quantity,
                'Original Quantity %1 is equal to the Quantity field %2', SalesLine."DOK Original Order Qty.", SalesLine.Quantity);
            until SalesLine.Next() = 0;
    end;

    [Test]
    procedure Test_OriginalQuantityIsPassedToSalesInvoiceLinesOnPost()
    var
        SalesHeader: Record "Sales Header";
        PostedSalesInvoice: Record "Sales Invoice Header";
        SalesInvoiceLine: Record "Sales Invoice Line";
        SalesPost: Codeunit "Sales-Post";
    begin

        Initialize();

        // [GIVEN] A Sales Order
        SalesHeader := TestFixturesSales.CreateSalesOrder();
        SalesHeader.Validate(Ship, true);
        SalesHeader.Validate(Invoice, true);
        SalesHeader.Modify(true);

        // [WHEN] When we add a new line and post the Sales Order
        TestFixturesSales.AddSalesLinesToSalesHeader(SalesHeader, 1);
        SalesPost.ReleaseSalesDocument(SalesHeader);
        SalesPost.Run(SalesHeader);

        // [THEN] The Orginal Order Qty. is populated with the same value as the Quantity field for each Sales Invoice Line
        PostedSalesInvoice := TestHelpersUtilities.GetLastPostedSalesInvoice();
        SalesInvoiceLine.SetRange("Document No.", PostedSalesInvoice."No.");
        SalesInvoiceLine.SetRange(Type, SalesInvoiceLine.Type::Item);
        if SalesInvoiceLine.FindSet() then
            repeat
                TestHelpers.AssertTrue(SalesInvoiceLine."DOK Original Order Qty." > 0, 'Original Quantity is not greater than 0');
                TestHelpers.AreEqual(SalesInvoiceLine."DOK Original Order Qty.", SalesInvoiceLine.Quantity, 'Original Quantity is not populated with the same value as the Quantity field');
            until SalesInvoiceLine.Next() = 0;
    end;

    [MessageHandler]
    procedure PostBatchSalesPostingMessageHandler(Message: Text[1024]);
    begin
        if Message in ['All of your selections were processed'] then
            exit;
    end;

    var
        TestHelpers: Codeunit "DOK Test Helpers";
        TestFixturesSales: Codeunit "DOK Test Fixtures Sales";
        TestHelpersUtilities: Codeunit "DOK Test Utilities";
        Utilities: Codeunit "DOK Utilities";
        Initialized: Boolean;
}