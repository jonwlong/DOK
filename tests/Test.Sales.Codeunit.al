codeunit 50001 "Test Sales Orders"
{
    Subtype = Test;

    local procedure Initialze()
    var
        Resource: Record "Resource";
        Setup: Record "DOK Setup";
        FreightCode: Code[20];
    begin

        if Initialized then
            exit;
        Initialized := true;
        FreightCode := TestHelpersUtilities.GetRandomString(20);
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
        Resource: Record Resource;
        Setup: Record "DOK Setup";
        FreightCode: Code[20];
    begin
        Initialze();

        // [GIVEN] a Sales Order with 1 Sales Line
        SalesHeader := TestFixturesSales.CreateSalesOrder();
        TestFixturesSales.CreateSalesLines(SalesHeader, 1);
        SalesHeader.Ship := true;
        SalesHeader.Invoice := true;
        SalesHeader.Modify(true);

        // [WHEN] we post the Sales Order
        SalesHeader.PostMSTOrder();
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
        TestFixturesSales.CreateSalesLines(SalesHeader, 1);

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
        TestFixturesSales.CreateSalesLines(SalesHeader, 1);

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
        TestFixturesSales.CreateSalesLines(SalesHeader, 1);
        SalesHeader.PostMSTOrder();

        // [THEN] The Orginal Order Qty. is populated with the same value as the Quantity field for each Sales Invoice Line
        SalesInvoiceLine.SetRange("Document No.", SalesHeader."DOK MST Order No.");
        SalesInvoiceLine.SetRange(Type, SalesInvoiceLine.Type::Item);
        if SalesInvoiceLine.FindSet then
            repeat
                TestHelpers.AreEqual(SalesInvoiceLine."DOK Original Order Qty.", SalesInvoiceLine.Quantity, 'Original Quantity is not populated with the same value as the Quantity field');
            until SalesInvoiceLine.Next = 0;
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
        TestFixturesSales.CreateSalesLines(SalesHeader, 1);

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
        TestFixturesSales.CreateSalesLines(SalesHeader, 10);

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
        TestFixturesSales.CreateSalesLines(SalesHeader, 1);

        // [WHEN] we add 2 MSTs
        TestFixturesSales.ImportMSTOrders(SalesHeader, 2);

        // [THEN] The quantity on the Sales Order line is updated to reflect the total quantity of the MSTs
        SalesLine.Get(SalesLine."Document Type"::Order, SalesHeader."No.", 10000);
        MST.SetRange("Order No.", SalesHeader."No.");
        MST.SetRange("Line No.", 10000);
        MST.CalcSums(Quantity);
        TestHelpers.AssertTrue(SalesLine.Quantity = MST.Quantity, 'Total Quantity is not %1, It''s %2', SalesLine.Quantity, MST.Quantity);
    end;

    [Test]
    procedure Test_CreateMSTOrderUpdatesRelatedOrderLineQuantity8MSTs()
    var
        SalesHeader: Record "Sales Header";
        MST: Record "DOK Multiple Ship-to Orders";
        SalesLine: Record "Sales Line";
    begin
        // [GIVEN] A Sales Order with 1 Sales Line and 2 MSTs
        SalesHeader := TestFixturesSales.CreateSalesOrder();
        TestFixturesSales.CreateSalesLines(SalesHeader, 2);

        // [WHEN] we add 4 MSTs to each line
        TestFixturesSales.ImportMSTOrders(SalesHeader, 4);

        // [THEN] The quantity on the Sales Order lines is updated to reflect the total quantity of the MSTs
        SalesLine.SetRange("Document Type", SalesLine."Document Type"::Order);
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetRange(Type, SalesLine.Type::Item);
        if SalesLine.FindSet then
            repeat
                MST.SetRange("Order No.", SalesHeader."No.");
                MST.SetRange("Line No.", SalesLine."Line No.");
                MST.CalcSums(Quantity);
                TestHelpers.AssertTrue(SalesLine.Quantity = MST.Quantity, 'Total Quantity is not %1, It''s %2', MST.Quantity, SalesLine.Quantity);
            until SalesLine.Next = 0;
    end;

    [Test]
    procedure Test_MSTOrderCreates2OrdersOnPost()
    var
        SalesHeader: Record "Sales Header";
        MST: Record "DOK Multiple Ship-to Orders";
        SalesLine: Record "Sales Line";
        Setup: Record "DOK Setup";
        Resource: Record Resource;
        MSTOrderNo: Code[20];
        MSTManagement: Codeunit "DOK MST Management";
        QtyOnOrderLinesCreatedFromMSTOrders: Decimal;
        FreightCode: Code[20];
    begin
        Initialze();

        // [GIVEN] A Sales Order with 1 Sales Line and 2 MSTs
        SalesHeader := TestFixturesSales.CreateSalesOrder();
        TestFixturesSales.CreateSalesLines(SalesHeader, 1);
        TestFixturesSales.ImportMSTOrders(SalesHeader, 2);

        // [WHEN] we post the Sales Order
        MSTOrderNo := SalesHeader."No.";
        MSTManagement.CreateOrdersFromMST(SalesHeader);
        SalesHeader.PostMSTOrder();

        // [THEN] 2 Sales Orders where the "DOK MST Order No." = the SalesHeader No.
        Clear(SalesHeader);
        SalesHeader.SetRange("DOK MST Order No.", MSTOrderNo);
        TestHelpers.AssertTrue(SalesHeader.Count = 2, 'Expected 2 Sales Orders to be created, but found %1', SalesHeader.Count);
        // Assert that the Sales Orders created in the posting have the qty on the associated sales line from the MSTs
        SalesHeader.Reset();
        SalesHeader.SetRange("DOK MST Order No.", MSTOrderNo);
        if SalesHeader.FindSet then
            repeat
                SalesLine.SetRange("Document Type", SalesLine."Document Type"::Order);
                SalesLine.SetRange("Document No.", SalesHeader."No.");
                SalesLine.SetRange(Type, SalesLine.Type::Item);
                SalesLine.CalcSums(Quantity);
                QtyOnOrderLinesCreatedFromMSTOrders += SalesLine.Quantity;
            until SalesHeader.Next = 0;
        // Assert that the total quantity on the Sales Order lines created from the MSTs is equal to the total quantity on the MSTs
        MST.SetRange("Order No.", MSTOrderNo);
        MST.CalcSums(Quantity);
        TestHelpers.AssertTrue(QtyOnOrderLinesCreatedFromMSTOrders = MST.Quantity, 'Total Quantity is not %1, It''s %2', MST.Quantity, QtyOnOrderLinesCreatedFromMSTOrders);
    end;

    [Test]
    procedure Test_PostOrdersCreatedFromMSTs()
    var
        SalesHeader: Record "Sales Header";
        Resource: Record Resource;
        Setup: Record "DOK Setup";
        MSTOrderNo: Code[20];
        FreightCode: Code[20];
    begin

        Initialze();

        // [GIVEN] A Sales Order with 1 Sales Line and 2 MSTs
        SalesHeader := TestFixturesSales.CreateSalesOrder();
        TestFixturesSales.CreateSalesLines(SalesHeader, 1);
        TestFixturesSales.ImportMSTOrders(SalesHeader, 2);

        // [WHEN] we post the Sales Order
        MSTOrderNo := SalesHeader."No.";
        SalesHeader.PostMSTOrder();

        // [THEN] 2 Sales Invoices are posted from the Sales Orders created from the MSTs
        SalesHeader.SetRange("DOK MST Order No.", MSTOrderNo);

    end;

    [Test]
    procedure Test_PostOrdersCreatedFrom2Lines8MSTs()
    var
        SalesHeader: Record "Sales Header";
        Resource: Record Resource;
        Setup: Record "DOK Setup";
        MSTOrderNo: Code[20];
        FreightCode: Code[20];
    begin

        Initialze();

        // [GIVEN] A Sales Order with 1 Sales Line and 2 MSTs
        SalesHeader := TestFixturesSales.CreateSalesOrder();
        TestFixturesSales.CreateSalesLines(SalesHeader, 2);
        TestFixturesSales.ImportMSTOrders(SalesHeader, 4);

        // [WHEN] we post the Sales Order
        MSTOrderNo := SalesHeader."No.";
        SalesHeader.PostMSTOrder();

        // [THEN] 2 Sales Invoices are posted from the Sales Orders created from the MSTs
        SalesHeader.SetRange("DOK MST Order No.", MSTOrderNo);

    end;

    // [Test]
    // procedure Test_PostOrdersCreatedFrom10Lines200MSTs()
    // var
    //     SalesHeader: Record "Sales Header";
    //     Resource: Record Resource;
    //     Setup: Record "DOK Setup";
    //     MSTOrderNo: Code[20];
    //     FreightCode: Code[20];
    // begin

    //     Initialze();

    //     // [GIVEN] A Sales Order with 1 Sales Line and 2 MSTs
    //     SalesHeader := TestFixturesSales.CreateSalesOrder();
    //     TestFixturesSales.CreateSalesLines(SalesHeader, 10);
    //     TestFixturesSales.ImportMSTOrders(SalesHeader, 20);

    //     // [WHEN] we post the Sales Order
    //     MSTOrderNo := SalesHeader."No.";
    //     SalesHeader.PostMSTOrder();

    //     // [THEN] 2 Sales Invoices are posted from the Sales Orders created from the MSTs
    //     SalesHeader.SetRange("DOK MST Order No.", MSTOrderNo);

    // end;

    [Test]
    [HandlerFunctions('PostBatchSalesPostingMessageHandler')]

    procedure Test_PostOrdersCreatedFrom1Line4MSTPostedCreates8ShipLines()
    var
        SalesHeader: Record "Sales Header";
        SalesShipLine: Record "Sales Shipment Line";
        Resource: Record Resource;
        Setup: Record "DOK Setup";
        BatchPostMSTSalesOrders: Codeunit "DOK Batch Post MST SalesOrders";
        SalesShipmentHeader: Record "Sales Shipment Header";
        MSTMgt: Codeunit "DOK MST Management";
        MSTOrderNo: Code[20];
        FreightCode: Code[20];
    begin

        Initialze();

        // [GIVEN] A Sales Order with 1 Sales Line and 2 MSTs
        SalesHeader := TestFixturesSales.CreateSalesOrder();
        TestFixturesSales.CreateSalesLines(SalesHeader, 1);
        TestFixturesSales.ImportMSTOrders(SalesHeader, 4);

        // [WHEN] we post the Sales Order
        MSTOrderNo := SalesHeader."No.";
        // SalesHeader.PostMSTOrder(); can't post an MST Order. Need to post the orders that are created from it
        MSTMgt.CreateOrdersFromMST(SalesHeader);
        BatchPostMSTSalesOrders.PostShipMSTSalesOrders(MSTOrderNo);
        // BatchPostMSTSalesOrders.PostCombinedMSTSalesOrders(MSTOrderNo);

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
        Resource: Record Resource;
        Setup: Record "DOK Setup";
        BatchPostMSTSalesOrders: Codeunit "DOK Batch Post MST SalesOrders";
        SalesShipmentHeader: Record "Sales Shipment Header";
        MSTMgt: Codeunit "DOK MST Management";
        MSTOrderNo: Code[20];
        FreightCode: Code[20];
    begin

        Initialze();

        // [GIVEN] A Sales Order with 1 Sales Line and 2 MSTs
        SalesHeader := TestFixturesSales.CreateSalesOrder();
        TestFixturesSales.CreateSalesLines(SalesHeader, 1);
        TestFixturesSales.ImportMSTOrders(SalesHeader, 4);

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
        Resource: Record Resource;
        Setup: Record "DOK Setup";
        BatchPostMSTSalesOrders: Codeunit "DOK Batch Post MST SalesOrders";
        SalesShipmentHeader: Record "Sales Shipment Header";
        MSTMgt: Codeunit "DOK MST Management";
        MSTOrderNo: Code[20];
        FreightCode: Code[20];
    begin

        Initialze();

        // [GIVEN] A Sales Order with 1 Sales Line and 2 MSTs
        SalesHeader := TestFixturesSales.CreateSalesOrder();
        TestFixturesSales.CreateSalesLines(SalesHeader, 1);
        TestFixturesSales.ImportMSTOrders(SalesHeader, 4);

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

    procedure Test_CombineMSTShipmentTo1InvoiceContains12LinesPost()
    var
        SalesHeader: Record "Sales Header";
        SalesInvoiceHeader: Record "Sales Header";
        Resource: Record Resource;
        Setup: Record "DOK Setup";
        BatchPostMSTSalesOrders: Codeunit "DOK Batch Post MST SalesOrders";
        MSTMgt: Codeunit "DOK MST Management";
        MSTOrderNo: Code[20];
        FreightCode: Code[20];
        SalesPost: Codeunit "Sales-Post";
    begin

        Initialze();

        // [GIVEN] A Sales Order with 1 Sales Line and 2 MSTs
        SalesHeader := TestFixturesSales.CreateSalesOrder();
        TestFixturesSales.CreateSalesLines(SalesHeader, 1);
        TestFixturesSales.ImportMSTOrders(SalesHeader, 4);

        // [WHEN] we post the Sales Order of type Invoice
        MSTOrderNo := SalesHeader."No.";
        MSTMgt.CreateOrdersFromMST(SalesHeader);
        BatchPostMSTSalesOrders.PostShipMSTSalesOrders(MSTOrderNo);
        BatchPostMSTSalesOrders.CreateInvoiceWithCombinedMSTShipments(MSTOrderNo);
        SalesInvoiceHeader.SetRange("DOK MST Order No.", MSTOrderNo);
        SalesInvoiceHeader.SetRange("Document Type", SalesInvoiceHeader."Document Type"::Invoice);
        SalesInvoiceHeader.FindFirst();
        SalesPost.Run(SalesInvoiceHeader);

        // [THEN] The Sales Invoice is posted


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