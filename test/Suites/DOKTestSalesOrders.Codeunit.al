codeunit 50001 "DOK Test Sales Orders"
{
    Subtype = Test;

    local procedure Initialize()
    begin

        if Initialized then
            exit;
        Initialized := true;

        TestSetup.CreateFreightResource();

    end;

    // First, we delete this since we don't ever test MS code
    // [Test]
    // procedure Test_PostSalesOrder()
    // var
    //     SalesHeader: Record "Sales Header";
    //     SalesPost: Codeunit "Sales-Post";
    //     PostedWithoutErrors: Boolean;
    // begin
    //     Initialize();

    //     // [GIVEN] a Sales Order with 1 Sales Line
    //     SalesHeader := TestFixturesSales.CreateSalesOrder();
    //     TestFixturesSales.AddSalesLinesToSalesHeader(SalesHeader, 1);
    //     SalesHeader.Validate(Ship, true);
    //     SalesHeader.Validate(Invoice, true);
    //     SalesHeader.Modify(true);

    //     // [WHEN] we post the Sales Order
    //     Commit();
    //     SalesPost.ReleaseSalesDocument(SalesHeader);
    //     PostedWithoutErrors := SalesPost.Run(SalesHeader);

    //     // [THEN] The Sales Order was posted without error
    //     TestHelpers.AssertTrue(PostedWithoutErrors, 'Sales Order was not posted without error. %1', GetLastErrorText());

    // end;

    // Next, we identify our dependencies
    // 1: Sales Header
    // 2: Sales Line
    // 3: Release Sales Document codeunit
    // 4: Test Fixtures Sales codeunit
    // Then we define what we are testing
    // 1: Calculate Freight on Release
    // 2: Create a Freight Line on Release
    // and create our test cases
    // 1: Our Calculate Freight procedure is getting called OnRelease
    // 2: Calclate Freight is returning a value > 0
    // 3: Freight Line is created when you calculate freight
    // Then we define our assertions
    // 1: Freight Line exists
    // 2: Freight Line has Quantity > 0
    // TestFixtures>SalesHeader>SalesLine>

    [TEST]
    procedure Test_CalculateFreightIsCalledOnRelease()
    var
        ReleaseSalesDocument: Codeunit "Release Sales Document";
    begin

        // [WHEN]
        // ReleaseSalesDocument.); 

        // [THEN] 

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
        PostedSalesInvoice := TestHelperUtilities.GetLastPostedSalesInvoice();
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
        TestHelperUtilities: Codeunit "DOK Test Helper Utilities";
        TestSetup: Codeunit "DOK Test Setup";
        Initialized: Boolean;
}