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
        PostedWithoutErrors: Boolean;
    begin
        Initialze();

        // [GIVEN] a Sales Order with 1 Sales Line
        SalesHeader := TestFixturesSales.CreateSalesOrder();
        TestFixturesSales.AddSalesLinesToSalesHeader(SalesHeader, 1);
        SalesHeader.Ship := true;
        SalesHeader.Invoice := true;
        SalesHeader.Modify(true);

        // [WHEN] we post the Sales Order
        SalesHeader.PostShipMSTOrder();
        PostedWithoutErrors := GetLastErrorText() = '';

        // [THEN] the Sales Order is posted without errors
        TestHelpers.AssertTrue(PostedWithoutErrors, 'Sales Order was not posted without error %1', GetLastErrorText());
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
        SalesHeader.PostShipMSTOrder();

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
        // [GIVEN] A Sales Order with 1 Sales Line
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
    procedure Test_CreateMSTOrderUpdatesRelatedOrderLineQuantity2MSTs()
    var
        SalesHeader: Record "Sales Header";
        MST: Record "DOK Multiple Ship-to Orders";
        SalesLine: Record "Sales Line";
    begin
        // [GIVEN] A Sales Order with 1 Sales Line and 2 MSTs
        SalesHeader := TestFixturesSales.CreateSalesOrder();
        TestFixturesSales.AddSalesLinesToSalesHeader(SalesHeader, 1);
        TestFixturesSales.CreateMSTOrders(SalesHeader, 2);

        // [WHEN] we get the sum of the quantity on the MSTs
        SalesLine.Get(SalesLine."Document Type"::Order, SalesHeader."No.", 10000);
        MST.SetRange("Order No.", SalesHeader."No.");
        MST.SetRange("Line No.", 10000);
        MST.CalcSums(Quantity);

        // [THEN] The quantity on the Sales Order line should reflect the total quantity of the MSTs
        TestHelpers.AssertTrue(SalesLine.Quantity = MST.Quantity, 'Total Quantity is not %1, It''s %2', SalesLine.Quantity, MST.Quantity);
    end;

    [Test]
    procedure Test_CreateMSTOrderUpdatesRelatedOrderLineQuantity8MSTs()
    var
        SalesHeader: Record "Sales Header";
        MST: Record "DOK Multiple Ship-to Orders";
        SalesLine: Record "Sales Line";
    begin
        // [GIVEN] A Sales Order with 2 Sales Lines
        SalesHeader := TestFixturesSales.CreateSalesOrder();
        TestFixturesSales.AddSalesLinesToSalesHeader(SalesHeader, 2);

        // [WHEN] we add 4 MSTs to each line
        TestFixturesSales.CreateMSTOrders(SalesHeader, 4);

        // [THEN] The quantity on the Sales Order lines reflect the total quantity of the related MSTs
        SalesLine.SetRange("Document Type", SalesLine."Document Type"::Order);
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetRange(Type, SalesLine.Type::Item);
        if SalesLine.FindSet() then
            repeat
                MST.SetRange("Order No.", SalesHeader."No.");
                MST.SetRange("Line No.", SalesLine."Line No.");
                MST.CalcSums(Quantity);
                TestHelpers.AssertTrue(SalesLine.Quantity = MST.Quantity, 'Total Quantity is not %1, It''s %2', MST.Quantity, SalesLine.Quantity);
            until SalesLine.Next() = 0;
    end;

    [Test]
    procedure Test_CreateOrdersFromMSTResultsIn2OrdersAndQuantityMatchesOriginalOrder()
    var
        SalesHeader: Record "Sales Header";
        MST: Record "DOK Multiple Ship-to Orders";
        SalesLine: Record "Sales Line";
        MSTManagement: Codeunit "DOK MST Management";
        MSTOrderNo: Code[20];
        QtyOnOrderLinesCreatedFromMSTOrders: Decimal;
    begin
        Initialze();

        // [GIVEN] A Sales Order with 1 Sales Line and 2 MSTs
        SalesHeader := TestFixturesSales.CreateSalesOrder();
        TestFixturesSales.AddSalesLinesToSalesHeader(SalesHeader, 1);
        TestFixturesSales.CreateMSTOrders(SalesHeader, 2);

        // [WHEN] we run the custom MST order creation procedure
        MSTOrderNo := SalesHeader."No.";
        MSTManagement.CreateOrdersFromMST(SalesHeader);

        // [THEN] 2 Sales Orders where the "DOK MST Order No." = the SalesHeader No.
        Clear(SalesHeader);
        SalesHeader.SetRange("DOK MST Order No.", MSTOrderNo);
        TestHelpers.AssertTrue(SalesHeader.Count = 2, 'Expected 2 Sales Orders to be created, but found %1', SalesHeader.Count);
        // Assert that the Sales Orders created in the posting have the qty on the associated sales line from the MSTs
        SalesHeader.Reset();
        SalesHeader.SetRange("DOK MST Order No.", MSTOrderNo);
        if SalesHeader.FindSet() then
            repeat
                SalesLine.SetRange("Document Type", SalesLine."Document Type"::Order);
                SalesLine.SetRange("Document No.", SalesHeader."No.");
                SalesLine.SetRange(Type, SalesLine.Type::Item);
                SalesLine.CalcSums(Quantity);
                QtyOnOrderLinesCreatedFromMSTOrders += SalesLine.Quantity;
            until SalesHeader.Next() = 0;
        // Assert that the total quantity on the Sales Order lines created from the MSTs is equal to the total quantity on the MSTs
        MST.SetRange("Order No.", MSTOrderNo);
        MST.CalcSums(Quantity);
        TestHelpers.AssertTrue(QtyOnOrderLinesCreatedFromMSTOrders = MST.Quantity, 'Total Quantity is not %1, It''s %2', MST.Quantity, QtyOnOrderLinesCreatedFromMSTOrders);
    end;

    [Test]
    procedure Test_PostOrdersCreatedFromMSTsGenerate()
    var
        SalesHeader: Record "Sales Header";
        MSTOrderNo: Code[20];
    begin

        Initialze();

        // [GIVEN] A Sales Order with 1 Sales Line and 2 MSTs
        SalesHeader := TestFixturesSales.CreateSalesOrder();
        TestFixturesSales.AddSalesLinesToSalesHeader(SalesHeader, 1);
        TestFixturesSales.CreateMSTOrders(SalesHeader, 2);

        // [WHEN] we post the Sales Order
        MSTOrderNo := SalesHeader."No.";
        SalesHeader.PostShipMSTOrder();

        // [THEN] 2 Sales Invoices are posted from the Sales Orders created from the MSTs
        SalesHeader.SetRange("DOK MST Order No.", MSTOrderNo);

    end;

    [Test]
    procedure Test_PostOrdersCreatedFrom2Lines8MSTs()
    var
        SalesHeader: Record "Sales Header";
        MSTOrderNo: Code[20];
    begin

        Initialze();

        // [GIVEN] A Sales Order with 1 Sales Line and 2 MSTs
        SalesHeader := TestFixturesSales.CreateSalesOrder();
        TestFixturesSales.AddSalesLinesToSalesHeader(SalesHeader, 2);
        TestFixturesSales.CreateMSTOrders(SalesHeader, 4);

        // [WHEN] we post the Sales Order
        MSTOrderNo := SalesHeader."No.";
        SalesHeader.PostShipMSTOrder();

        // [THEN] 2 Sales Invoices are posted from the Sales Orders created from the MSTs
        SalesHeader.SetRange("DOK MST Order No.", MSTOrderNo);

    end;

    [Test]
    [HandlerFunctions('PostBatchSalesPostingMessageHandler')]

    procedure Test_PostOrdersCreatedFrom1Line4MSTPostedCreates8ShipLines()
    var
        SalesHeader: Record "Sales Header";
        SalesShipLine: Record "Sales Shipment Line";
        SalesShipmentHeader: Record "Sales Shipment Header";
        BatchPostMSTSalesOrders: Codeunit "DOK Batch Post MST SalesOrders";
        MSTMgt: Codeunit "DOK MST Management";
        MSTOrderNo: Code[20];
    begin

        Initialze();

        // [GIVEN] A Sales Order with 1 Sales Line and 4 MSTs each
        SalesHeader := TestFixturesSales.CreateSalesOrder();
        TestFixturesSales.AddSalesLinesToSalesHeader(SalesHeader, 1);
        TestFixturesSales.CreateMSTOrders(SalesHeader, 4);

        // [WHEN] we post the Sales Order
        MSTOrderNo := SalesHeader."No.";
        MSTMgt.CreateOrdersFromMST(SalesHeader);
        BatchPostMSTSalesOrders.PostShipMSTSalesOrders(MSTOrderNo);

        // [THEN] 4 sales Shipment Headers should have been created.
        SalesShipmentHeader.SetRange("DOK MST Order No.", MSTOrderNo);
        TestHelpers.AssertTrue(SalesShipmentHeader.Count = 4, 'Expected 4 Sales Shipment Headers to be created. Only %1 were created', SalesShipmentHeader.Count);

        // [THEN] 8 shipment lines should have been created
        SalesShipLine.SetRange("DOK MST Order No.", MSTOrderNo);
        TestHelpers.AssertTrue(SalesShipLine.Count = 8, 'Expected 8 Sales Shipment Lines to be created. Only %1 were created', SalesShipLine.Count);

    end;

    [Test]
    [HandlerFunctions('PostBatchSalesPostingMessageHandler')]

    procedure Test_CombineMSTShipmentTo1Invoice()
    var
        SalesHeader: Record "Sales Header";
        SalesInvoiceHeader: Record "Sales Header";
        SalesShipLine: Record "Sales Shipment Line";
        SalesShipmentHeader: Record "Sales Shipment Header";
        BatchPostMSTSalesOrders: Codeunit "DOK Batch Post MST SalesOrders";
        MSTMgt: Codeunit "DOK MST Management";
        MSTOrderNo: Code[20];
    begin

        Initialze();

        // [GIVEN] A Sales Order with 1 Sales Line and 2 MSTs
        SalesHeader := TestFixturesSales.CreateSalesOrder();
        TestFixturesSales.AddSalesLinesToSalesHeader(SalesHeader, 1);
        TestFixturesSales.CreateMSTOrders(SalesHeader, 4);

        // [WHEN] we post the Sales Order
        MSTOrderNo := SalesHeader."No.";
        MSTMgt.CreateOrdersFromMST(SalesHeader);
        BatchPostMSTSalesOrders.PostShipMSTSalesOrders(MSTOrderNo);
        BatchPostMSTSalesOrders.CreateInvoiceWithCombinedMSTShipments(MSTOrderNo);

        // [THEN] 4 sales Shipment Headers should have been created.
        SalesShipmentHeader.SetRange("DOK MST Order No.", MSTOrderNo);
        TestHelpers.AssertTrue(SalesShipmentHeader.Count = 4, 'Expected 4 Sales Shipment Headers to be created. Only %1 were created', SalesShipmentHeader.Count);

        // [THEN] 8 shipment lines should have been created
        SalesShipLine.SetRange("DOK MST Order No.", MSTOrderNo);
        TestHelpers.AssertTrue(SalesShipLine.Count = 8, 'Expected 8 Sales Shipment Lines to be created. Only %1 were created', SalesShipLine.Count);

        // [THEN] 1 sales order of type invoice should have been created
        SalesInvoiceHeader.SetRange("DOK MST Order No.", MSTOrderNo);
        SalesInvoiceHeader.SetRange("Document Type", SalesInvoiceHeader."Document Type"::Invoice);
        TestHelpers.AssertTrue(SalesInvoiceHeader.Count = 1, 'Expected 1 Sales Invoice Header to be created. Only %1 were created', SalesInvoiceHeader.Count);

    end;

    [Test]
    [HandlerFunctions('PostBatchSalesPostingMessageHandler')]

    procedure Test_CombineMSTShipmentTo1InvoiceContains12Lines()
    var
        SalesHeader: Record "Sales Header";
        SalesInvoiceHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SalesShipLine: Record "Sales Shipment Line";
        SalesShipmentHeader: Record "Sales Shipment Header";
        BatchPostMSTSalesOrders: Codeunit "DOK Batch Post MST SalesOrders";
        MSTMgt: Codeunit "DOK MST Management";
        MSTOrderNo: Code[20];
    begin

        Initialze();

        // [GIVEN] A Sales Order with 1 Sales Line and 2 MSTs
        SalesHeader := TestFixturesSales.CreateSalesOrder();
        TestFixturesSales.AddSalesLinesToSalesHeader(SalesHeader, 1);
        TestFixturesSales.CreateMSTOrders(SalesHeader, 4);

        // [WHEN] we post the Sales Order
        MSTOrderNo := SalesHeader."No.";
        MSTMgt.CreateOrdersFromMST(SalesHeader);
        BatchPostMSTSalesOrders.PostShipMSTSalesOrders(MSTOrderNo);
        BatchPostMSTSalesOrders.CreateInvoiceWithCombinedMSTShipments(MSTOrderNo);

        // [THEN] 4 sales Shipment Headers should have been created.
        SalesShipmentHeader.SetRange("DOK MST Order No.", MSTOrderNo);
        TestHelpers.AssertTrue(SalesShipmentHeader.Count = 4, 'Expected 4 Sales Shipment Headers to be created. Only %1 were created', SalesShipmentHeader.Count);

        // [THEN] 8 shipment lines should have been created
        SalesShipLine.SetRange("DOK MST Order No.", MSTOrderNo);
        TestHelpers.AssertTrue(SalesShipLine.Count = 8, 'Expected 8 Sales Shipment Lines to be created. Only %1 were created', SalesShipLine.Count);

        // [THEN] 1 sales order of type invoice should have been created
        SalesInvoiceHeader.SetRange("DOK MST Order No.", MSTOrderNo);
        SalesInvoiceHeader.SetRange("Document Type", SalesInvoiceHeader."Document Type"::Invoice);
        TestHelpers.AssertTrue(SalesInvoiceHeader.Count = 1, 'Expected 1 Sales Invoice Header to be created. Only %1 were created', SalesInvoiceHeader.Count);

        // [THEN] 12 sales invoice lines should have been created
        SalesInvoiceHeader.FindFirst();
        SalesLine.SetRange("Document Type", SalesLine."Document Type"::Invoice);
        SalesLine.SetRange("Document No.", SalesInvoiceHeader."No.");
        TestHelpers.AssertTrue(SalesLine.Count = 12, 'Expected 12 Sales Invoice Lines to be created. %1 were created', SalesLine.Count);

    end;

    [Test]
    [HandlerFunctions('PostBatchSalesPostingMessageHandler')]

    procedure Test_CombineMSTShipmentTo1InvoiceContains12LinesPostInvoice()
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

    [Test]
    [HandlerFunctions('PostBatchSalesPostingMessageHandler')]

    procedure Test_CombineMSTShipmentTo1InvoiceContains24LinesPostInvoice()
    var
        SalesHeader: Record "Sales Header";
        PostedSalesInvoice: Record "Sales Invoice Header";
        PostedSalesInvoiceLine: Record "Sales Invoice Line";
        SalesPost: Codeunit "Sales-Post";
    begin

        Initialze();

        // [GIVEN] A Sales Order with 2 Sales Line and 4 MSTs for each Sales Line
        SalesHeader := TestFixturesSales.CreateSalesInvoiceWithMSTShipmentLines(SalesHeader, 2, 4);

        // [WHEN] we post the Sales Order of type Invoice
        SalesPost.Run(SalesHeader);

        // [THEN] The Sales Invoice is posted with MSTOrderNo
        PostedSalesInvoice.SetRange("DOK MST Order No.", SalesHeader."DOK MST Order No.");
        TestHelpers.AssertTrue(not PostedSalesInvoice.IsEmpty, 'Sales Invoice was not posted with MST Order No. %1', SalesHeader."DOK MST Order No.");

        // [THEN] the invoice contains 24 lines
        PostedSalesInvoice.FindFirst();
        PostedSalesInvoiceLine.SetRange("Document No.", PostedSalesInvoice."No.");
        TestHelpers.AssertTrue(PostedSalesInvoiceLine.Count = 24, 'Expected 24 Sales Invoice Lines to be created. %1 were created', PostedSalesInvoiceLine.Count);
    end;

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