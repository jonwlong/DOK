codeunit 50001 "DOK Test Sales Orders"
{
    Subtype = Test;

    local procedure Initialze()
    var
        Resource: Record Resource;
        Setup: Record "DOK Setup";
        FreightCode: Code[20];
    begin

        if Initialized then
            exit;
        Initialized := true;
        FreightCode := CopyStr(TestHelpersUtilities.GetRandomString(20), 1, MaxStrLen(FreightCode));
        if not Setup.Get() then begin
            Setup.Init();
            Setup."Freight No." := FreightCode;
            Setup.Insert();
        end else begin
            Setup."Freight No." := FreightCode;
            Setup.Modify(true)
        end;
        TestHelpersUtilities.CreateResource(Resource, FreightCode);
        WorkDate(Today);

    end;

    [Test]
    procedure Test_PostSalesOrder()
    var
        SalesHeader: Record "Sales Header";
        SalesPost: Codeunit "Sales-Post";
        PostedWithoutErrors: Boolean;
    begin
        Initialze();

        // [GIVEN] a Sales Order with 1 Sales Line
        SalesHeader := TestFixturesSales.CreateSalesOrder();
        TestFixturesSales.AddSalesLinesToSalesHeader(SalesHeader, 1);
        SalesHeader.Validate(Ship, true);
        SalesHeader.Validate(Invoice, true);
        SalesHeader.Modify(true);

        // [WHEN] we post the Sales Order
        PostedWithoutErrors := SalesPost.Run(SalesHeader);

        // [THEN] the Sales Order is posted without errors
        TestHelpers.AssertTrue(PostedWithoutErrors, 'Sales Order was not posted without error. %1', GetLastErrorText());

    end;

    [Test]
    procedure Test_OriginalQuantityIsPopulatedOnNewLines()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
    begin
        // [GIVEN] A Sales Order
        SalesHeader := TestFixturesSales.CreateSalesOrder();

        // [WHEN] When we add a new line
        TestFixturesSales.AddSalesLinesToSalesHeader(SalesHeader, 1);

        // [THEN] Then Expected Output is the Orginal Order Qty. is populated with the same value as the Quantity field 
        TestHelpers.AreEqual(SalesLine."DOK Original Order Qty.", SalesLine.Quantity, 'Original Quantity is not populated with the same value as the Quantity field');
    end;

    [TEST]
    procedure Test_OriginalQuantityIsPopulatedOnNewLine()
    var
        SalesLine: Record "Sales Line";
    begin

        // [GIVEN] A Sales Line of type Order
        SalesLine := TestFixturesSales.CreateSalesLine(4);

        // [THEN] Then Expected Output is the Orginal Order Qty. is populated with the same value as the Quantity field 
        TestHelpers.AreEqual(SalesLine."DOK Original Order Qty.", SalesLine.Quantity, 'Original Quantity is not populated with the same value as the Quantity field');

    end;


    [Test]
    procedure Test_OriginalQuantityIsNotModifiedAfterQuantityModified()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        OriginalQuantity: Decimal;
    begin
        // [GIVEN] A Sales Order
        SalesHeader := TestFixturesSales.CreateSalesOrder();

        // [WHEN] When we add a new line
        TestFixturesSales.AddSalesLinesToSalesHeader(SalesHeader, 1);

        // [WHEN] When we modify the Quantity
        SalesLine.Get(SalesLine."Document Type"::Order, SalesHeader."No.", 10000);
        OriginalQuantity := SalesLine.Quantity;
        SalesLine.Validate(Quantity, 0);
        SalesLine.Modify(true);

        // [THEN] Then Expected Output is the Orginal Order Qty. is populated with the same value as the Quantity field 
        TestHelpers.AreEqual(SalesLine."DOK Original Order Qty.", OriginalQuantity, 'Original Quantity is not populated with the same value as the Quantity field');
    end;

    [Test]
    procedure Test_OriginalQuantityIsPassedToSalesInvoiceLinesOnPost()
    var
        SalesHeader: Record "Sales Header";
        SalesInvoiceLine: Record "Sales Invoice Line";
    begin
        // [GIVEN] A Sales Order
        SalesHeader := TestFixturesSales.CreateSalesOrder();

        // [WHEN] When we add a new line and post the Sales Order
        TestFixturesSales.AddSalesLinesToSalesHeader(SalesHeader, 1);
        SalesHeader.PostShipMSTOrders();

        // [THEN] The Orginal Order Qty. is populated with the same value as the Quantity field for each Sales Invoice Line
        SalesInvoiceLine.SetRange("Document No.", SalesHeader."DOK MST Order No.");
        SalesInvoiceLine.SetRange(Type, SalesInvoiceLine.Type::Item);
        if SalesInvoiceLine.FindSet() then
            repeat
                TestHelpers.AreEqual(SalesInvoiceLine."DOK Original Order Qty.", SalesInvoiceLine.Quantity, 'Original Quantity is not populated with the same value as the Quantity field');
            until SalesInvoiceLine.Next() = 0;
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

    [Test]
    procedure Test_CreateMSTEntriesFromSalesOrder()
    var
        SalesHeader: Record "Sales Header";
        MST: Record "DOK Multiple Ship-to Entries";
        SalesLine: Record "Sales Line";
        MSTMgt: Codeunit "DOK MST Management";
    begin
        // [GIVEN] A Sales Order with 1 Sales Line and 2 MSTs
        SalesHeader := TestFixturesSales.CreateSalesOrder();
        TestFixturesSales.AddSalesLinesToSalesHeader(SalesHeader, 1);

        // [WHEN] we create MST Entries
        MSTMgt.CreateMockMSTOrders(SalesHeader."No.", 2);

        // [THEN] The quantity on the Sales Order line should reflect the total quantity of the MSTs
        SalesLine.Get(SalesLine."Document Type"::Order, SalesHeader."No.", 10000);
        MST.SetRange("Order No.", SalesHeader."No.");
        MST.SetRange("Line No.", 10000);
        MST.CalcSums(Quantity);
        TestHelpers.AssertTrue(SalesLine.Quantity = MST.Quantity, 'Total Quantity is not %1, It''s %2', SalesLine.Quantity, MST.Quantity);

        // [THEN] There should be 2 MSTs
        TestHelpers.AssertTrue(MST.Count = 2, 'Expected 2 MSTs to be created, but found %1', MST.Count);
    end;

    [Test]
    procedure Test_CreateOrdersFromMSTEntries()
    var
        MSTSalesHeader: Record "Sales Header";
        SalesHeader: Record "Sales Header";
        MSTManagement: Codeunit "DOK MST Management";
    begin
        Initialze();

        // [GIVEN] A Sales Order with 1 Sales Line and 2 MSTs
        MSTSalesHeader := TestFixturesSales.CreateMSTSalesOrderWithMSTEntries(1, 2);

        // [WHEN] we run the custom MST order creation procedure
        MSTSalesHeader.CreateOrdersFromMST();

        // [THEN] 2 Sales Orders should have been created
        SalesHeader.SetRange("DOK MST Order No.", MSTSalesHeader."No.");
        TestHelpers.AssertTrue(SalesHeader.Count = 2, 'Expected 2 Sales Orders to be created. %1 were created', SalesHeader.Count);

        // [THEN] Sales Orders created in the posting have the qty on the associated sales line from the MSTs
        TestHelpers.AssertTrue(MSTManagement.MSTEntriesAndCreatedSalesOrdersReconcile(MSTSalesHeader."No."), 'The MST Entries and the created Sales Orders do not reconcile');
    end;

    [Test]
    procedure Test_PostShipOrdersCreatedFromMSTOrder2Shipments()
    var
        MSTSalesHeader: Record "Sales Header";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
    begin

        Initialze();

        // [GIVEN] A Sales Order with 1 Sales Line with 2 MSTs each
        MSTSalesHeader := TestFixturesSales.CreateMSTSalesOrderReadyToPost(1, 2);

        // [WHEN] we post the Sales Orders
        MSTSalesHeader.PostShipMSTOrders();

        // [THEN] 2 Sales Orders should each have all lines shipped
        SalesHeader.SetRange("DOK MST Order No.", MSTSalesHeader."No.");
        SalesHeader.FindSet();
        repeat
            SalesLine.SetRange("Document Type", SalesLine."Document Type"::Order);
            SalesLine.SetRange("Document No.", SalesHeader."No.");
            SalesLine.FindSet();
            repeat
                TestHelpers.AssertTrue(SalesLine.Quantity = SalesLine."Quantity Shipped", 'Quantity Shipped is not equal to Quantity on Sales Line');
            until SalesLine.Next() = 0;
        until SalesHeader.Next() = 0;

    end;

    [Test]
    procedure Test_PostShipOrdersCreatedFromMSTOrder20Shipments()
    var
        MSTSalesHeader: Record "Sales Header";
        SalesShipmentHeader: Record "Sales Shipment Header";
        SalesShipLine: Record "Sales Shipment Line";
    begin

        Initialze();

        // [GIVEN] A Sales Order with 2 Sales Line with 20 MSTs each
        MSTSalesHeader := TestFixturesSales.CreateMSTSalesOrderReadyToPost(2, 10);

        // [WHEN] we post the Sales Orders
        MSTSalesHeader.PostShipMSTOrders();

        // [THEN] 4 sales Shipment Headers should have been created.
        SalesShipmentHeader.SetRange("DOK MST Order No.", MSTSalesHeader."No.");
        TestHelpers.AssertTrue(SalesShipmentHeader.Count = 20, 'Expected 4 Sales Shipment Headers to be created. Only %1 were created', SalesShipmentHeader.Count);

        // [THEN] 8 shipment lines should have been created
        SalesShipLine.SetRange("DOK MST Order No.", MSTSalesHeader."No.");
        TestHelpers.AssertTrue(SalesShipLine.Count = 40, 'Expected 8 Sales Shipment Lines to be created. Only %1 were created', SalesShipLine.Count);

    end;

    [Test]
    procedure Test_CreateMSTInvoice()
    var
        MSTSalesHeader: Record "Sales Header";
        SalesInvoiceHeader: Record "Sales Header";
        SalesShipLine: Record "Sales Shipment Line";
        SalesShipmentHeader: Record "Sales Shipment Header";
        MSTMgt: Codeunit "DOK MST Management";
    begin

        Initialze();

        // [GIVEN] A Sales Order with 2 Sales Line with 20 MSTs each
        MSTSalesHeader := TestFixturesSales.CreateMSTSalesOrderWithPostedShipments(1, 10);

        // [WHEN] we create an invoice from the MST Order
        MSTMgt.CreateInvoiceWithCombinedMSTShipments(MSTSalesHeader."No.");

        // [THEN] 10 sales Shipment Headers should have been created.
        SalesShipmentHeader.SetRange("DOK MST Order No.", MSTSalesHeader."No.");
        TestHelpers.AssertTrue(SalesShipmentHeader.Count = 10, 'Expected 10 Sales Shipment Headers to be created. %1 were created', SalesShipmentHeader.Count);

        // [THEN] 8 shipment lines should have been created
        SalesShipLine.SetRange("DOK MST Order No.", MSTSalesHeader."No.");
        TestHelpers.AssertTrue(SalesShipLine.Count = 20, 'Expected 8 Sales Shipment Lines to be created. %1 were created', SalesShipLine.Count);

        // [THEN] 1 sales order of type invoice should have been created
        SalesInvoiceHeader.SetRange("DOK MST Order No.", MSTSalesHeader."No.");
        SalesInvoiceHeader.SetRange("Document Type", SalesInvoiceHeader."Document Type"::Invoice);
        TestHelpers.AssertTrue(SalesInvoiceHeader.Count = 1, 'Expected 1 Sales Invoice Header to be created. Only %1 were created', SalesInvoiceHeader.Count);

    end;

    [Test]
    procedure Test_EndToEndPostMSTInvoice()
    var
        SalesHeader: Record "Sales Header";
        PostedSalesInvoice: Record "Sales Invoice Header";
        PostedSalesInvoiceLine: Record "Sales Invoice Line";
        SalesPost: Codeunit "Sales-Post";
    begin

        Initialze();

        // [GIVEN] A Sales Order with 1 Sales Line and 2 MSTs
        SalesHeader := TestFixturesSales.CreateSalesInvoiceWithMSTShipmentLines(SalesHeader, 1, 4);

        // [WHEN] we post the Sales Order of type Invoice
        SalesPost.Run(SalesHeader);

        // [THEN] The Sales Invoice is posted with MSTOrderNo
        PostedSalesInvoice.SetRange("DOK MST Order No.", SalesHeader."DOK MST Order No.");
        TestHelpers.AssertTrue(not PostedSalesInvoice.IsEmpty, 'Sales Invoice was not posted with MST Order No. %1', SalesHeader."DOK MST Order No.");

        // [THEN] the invoice contains 12 lines
        PostedSalesInvoice.FindFirst();
        PostedSalesInvoiceLine.SetRange("Document No.", PostedSalesInvoice."No.");
        TestHelpers.AssertTrue(PostedSalesInvoiceLine.Count = 12, 'Expected 12 Sales Invoice Lines to be created. %1 were created', PostedSalesInvoiceLine.Count);
    end;

    // [TEST]
    // procedure Test_PageActionCreateInvoice()
    // var
    //     SalesHeader: Record "Sales Header";
    //     SalesOrderPage: TestPage "Sales Order";
    // begin
    //     // [GIVEN] A SalesOrderPage with an active Sales Order 1 line 2 MSTs
    //     SalesHeader := TestFixturesSales.CreateSalesOrder();
    //     TestFixturesSales.AddSalesLinesToSalesHeader(SalesHeader, 1);
    //     TestFixturesSales.CreateMSTEntries(SalesHeader, 2);

    //     // [WHEN] We run the action "Post & Ship MST Invoice"
    //     // run action on page
    //     SalesOrderPage.OpenNew();
    //     SalesOrderPage.GoToRecord(SalesHeader);
    //     SalesOrderPage."Post & Ship MST Invoice_Promoted".Invoke();

    //     // [THEN] The Sales Invoice is created with MSTOrderNo
    //     SalesHeader.SetRange("DOK MST Order No.", SalesHeader."No.");
    //     TestHelpers.AssertTrue(not SalesHeader.IsEmpty, 'Sales Invoice was not posted with MST Order No. %1', SalesHeader."DOK MST Order No.");


    // end;


    //All of your selections were processed
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
        Initialized: Boolean;
}