codeunit 50001 "Test Sales Orders"
{
    Subtype = Test;

    [Test]
    procedure Test_PostSalesOrder()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SalesPost: Codeunit "Sales-Post";
        PostedWithoutErrors: Boolean;
        Resource: Record Resource;
        Setup: Record "DOK Setup";
        TaxGroup: Record "Tax Group";
        FreightCode: Code[20];
    begin
        //[SETUP] Create a Resource for the Freight line
        FreightCode := TestHelpersUtilities.GetRandomString(20);
        if not Setup.Get() then begin
            Setup.Init();
            Setup."Freight No." := FreightCode;
            Setup.Insert();
        end else begin
            Setup."Freight No." := FreightCode;
            Setup.Modify(TRUE)
        end;
        TestHelpersUtilities.CreateResource(Resource, FreightCode);

        // [GIVEN] a Sales Order with 1 Sales Line
        SalesHeader := TestFixturesSales.CreateSalesOrder();
        TestFixturesSales.CreateSalesLines(SalesHeader, 1);
        SalesHeader.Ship := TRUE;
        SalesHeader.Invoice := TRUE;
        SalesHeader.Modify(TRUE);

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
        SalesHeader.PostMSTOrder();

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
        MST.CALCSUMS("Quantity");
        TestHelpers.AssertTrue(SalesLine."Quantity" = MST.Quantity, 'Total Quantity is not %1, It''s %2', SalesLine."Quantity", MST.Quantity);
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
        SalesLine.SETRANGE(Type, SalesLine.Type::Item);
        if SalesLine.FINDSET then
            repeat
                MST.SetRange("Order No.", SalesHeader."No.");
                MST.SetRange("Line No.", SalesLine."Line No.");
                MST.CALCSUMS("Quantity");
                TestHelpers.AssertTrue(SalesLine."Quantity" = MST.Quantity, 'Total Quantity is not %1, It''s %2', MST.Quantity, SalesLine."Quantity");
            until SalesLine.NEXT = 0;
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
        SalesPost: Codeunit "Sales-Post";
        MSTManagement: Codeunit "DOK MST Management";
        QtyOnOrderLinesCreatedFromMSTOrders: Decimal;
        FreightCode: Code[20];
    begin
        //[SETUP] Create a Resource for the Freight line
        FreightCode := TestHelpersUtilities.GetRandomString(20);
        if not Setup.Get() then begin
            Setup.Init();
            Setup."Freight No." := FreightCode;
            Setup.Insert();
        end else begin
            Setup."Freight No." := FreightCode;
            Setup.Modify(TRUE)
        end;
        TestHelpersUtilities.CreateResource(Resource, FreightCode);

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
        SalesHeader.SETRANGE("DOK MST Order No.", MSTOrderNo);
        TestHelpers.AssertTrue(SalesHeader.COUNT = 2, 'Expected 2 Sales Orders to be created, but found %1', SalesHeader.COUNT);
        // Assert that the Sales Orders created in the posting have the qty on the associated sales line from the MSTs
        SalesHeader.Reset();
        SalesHeader.SETRANGE("DOK MST Order No.", MSTOrderNo);
        if SalesHeader.FINDSET then
            repeat
                SalesLine.SETRANGE("Document Type", SalesLine."Document Type"::Order);
                SalesLine.SETRANGE("Document No.", SalesHeader."No.");
                SalesLine.SETRANGE(Type, SalesLine.Type::Item);
                SalesLine.CALCSUMS("Quantity");
                QtyOnOrderLinesCreatedFromMSTOrders += SalesLine.Quantity;
            until SalesHeader.NEXT = 0;
        // Assert that the total quantity on the Sales Order lines created from the MSTs is equal to the total quantity on the MSTs
        MST.SETRANGE("Order No.", MSTOrderNo);
        MST.CALCSUMS("Quantity");
        TestHelpers.AssertTrue(QtyOnOrderLinesCreatedFromMSTOrders = MST.Quantity, 'Total Quantity is not %1, It''s %2', MST.Quantity, QtyOnOrderLinesCreatedFromMSTOrders);
    end;

    [Test]
    procedure Test_PostOrdersCreatedFromMSTs()
    var
        SalesHeader: Record "Sales Header";
        MST: Record "DOK Multiple Ship-to Orders";
        SalesLine: Record "Sales Line";
        Resource: Record Resource;
        Setup: Record "DOK Setup";
        MSTOrderNo: Code[20];
        FreightCode: Code[20];
        SalesPost: Codeunit "Sales-Post";
        QtyOnOrderLinesCreatedFromMSTOrders: Decimal;
    begin

        //[SETUP] Create a Resource for the Freight line
        FreightCode := TestHelpersUtilities.GetRandomString(20);
        if not Setup.Get() then begin
            Setup.Init();
            Setup."Freight No." := FreightCode;
            Setup.Insert();
        end else begin
            Setup."Freight No." := FreightCode;
            Setup.Modify(TRUE)
        end;
        TestHelpersUtilities.CreateResource(Resource, FreightCode);

        // [GIVEN] A Sales Order with 1 Sales Line and 2 MSTs
        SalesHeader := TestFixturesSales.CreateSalesOrder();
        TestFixturesSales.CreateSalesLines(SalesHeader, 1);
        TestFixturesSales.ImportMSTOrders(SalesHeader, 2);

        // [WHEN] we post the Sales Order
        MSTOrderNo := SalesHeader."No.";
        SalesHeader.PostMSTOrder();

        // [THEN] 2 Sales Invoices are posted from the Sales Orders created from the MSTs
        SalesHeader.SETRANGE("DOK MST Order No.", MSTOrderNo);

    end;

    [Test]
    procedure Test_PostOrdersCreatedFrom2Lines8MSTs()
    var
        SalesHeader: Record "Sales Header";
        MST: Record "DOK Multiple Ship-to Orders";
        SalesLine: Record "Sales Line";
        Resource: Record Resource;
        Setup: Record "DOK Setup";
        MSTOrderNo: Code[20];
        FreightCode: Code[20];
        SalesPost: Codeunit "Sales-Post";
        QtyOnOrderLinesCreatedFromMSTOrders: Decimal;
    begin

        // [SETUP] Create a Resource for the Freight line
        //[SETUP] Create a Resource for the Freight line
        FreightCode := TestHelpersUtilities.GetRandomString(20);
        if not Setup.Get() then begin
            Setup.Init();
            Setup."Freight No." := FreightCode;
            Setup.Insert();
        end else begin
            Setup."Freight No." := FreightCode;
            Setup.Modify(TRUE)
        end;
        TestHelpersUtilities.CreateResource(Resource, FreightCode);

        // [GIVEN] A Sales Order with 1 Sales Line and 2 MSTs
        SalesHeader := TestFixturesSales.CreateSalesOrder();
        TestFixturesSales.CreateSalesLines(SalesHeader, 2);
        TestFixturesSales.ImportMSTOrders(SalesHeader, 4);

        // [WHEN] we post the Sales Order
        MSTOrderNo := SalesHeader."No.";
        SalesHeader.PostMSTOrder();

        // [THEN] 2 Sales Invoices are posted from the Sales Orders created from the MSTs
        SalesHeader.SETRANGE("DOK MST Order No.", MSTOrderNo);

    end;

    [Test]
    procedure Test_PostOrdersCreatedFrom10Lines200MSTs()
    var
        SalesHeader: Record "Sales Header";
        MST: Record "DOK Multiple Ship-to Orders";
        SalesLine: Record "Sales Line";
        Resource: Record Resource;
        Setup: Record "DOK Setup";
        MSTOrderNo: Code[20];
        FreightCode: Code[20];
        SalesPost: Codeunit "Sales-Post";
        QtyOnOrderLinesCreatedFromMSTOrders: Decimal;
    begin

        // [SETUP] Create a Resource for the Freight line
        //[SETUP] Create a Resource for the Freight line
        FreightCode := TestHelpersUtilities.GetRandomString(20);
        if not Setup.Get() then begin
            Setup.Init();
            Setup."Freight No." := FreightCode;
            Setup.Insert();
        end else begin
            Setup."Freight No." := FreightCode;
            Setup.Modify(TRUE)
        end;
        TestHelpersUtilities.CreateResource(Resource, FreightCode);

        // [GIVEN] A Sales Order with 1 Sales Line and 2 MSTs
        SalesHeader := TestFixturesSales.CreateSalesOrder();
        TestFixturesSales.CreateSalesLines(SalesHeader, 10);
        TestFixturesSales.ImportMSTOrders(SalesHeader, 20);

        // [WHEN] we post the Sales Order
        MSTOrderNo := SalesHeader."No.";
        SalesHeader.PostMSTOrder();

        // [THEN] 2 Sales Invoices are posted from the Sales Orders created from the MSTs
        SalesHeader.SETRANGE("DOK MST Order No.", MSTOrderNo);

    end;

    [Test]
    [HandlerFunctions('PostBatchSalesPostingMessageHandler')]

    procedure Test_PostOrdersCreatedFrom1Line4MSTPostedCreates8ShipLines()
    var
        SalesHeader: Record "Sales Header";
        MST: Record "DOK Multiple Ship-to Orders";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesLine: Record "Sales Line";
        SalesShipLine: Record "Sales Shipment Line";
        Resource: Record Resource;
        Setup: Record "DOK Setup";
        BatchPostMSTSalesOrders: Codeunit "DOK Batch Post MST SalesOrders";
        SalesShipmentHeader: Record "Sales Shipment Header";
        MSTMgt: Codeunit "DOK MST Management";
        MSTOrderNo: Code[20];
        FreightCode: Code[20];
        SalesPost: Codeunit "Sales-Post";
        QtyOnOrderLinesCreatedFromMSTOrders: Decimal;
        SalesInvoiceCountBefore: Integer;
        SalesInvoiceCountAfter: Integer;
    begin

        // [SETUP] Create a Resource for the Freight line
        //[SETUP] Create a Resource for the Freight line
        FreightCode := TestHelpersUtilities.GetRandomString(20);
        if not Setup.Get() then begin
            Setup.Init();
            Setup."Freight No." := FreightCode;
            Setup.Insert();
        end else begin
            Setup."Freight No." := FreightCode;
            Setup.Modify(TRUE)
        end;
        TestHelpersUtilities.CreateResource(Resource, FreightCode);

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
        SalesShipmentHeader.SETRANGE("DOK MST Order No.", MSTOrderNo);
        TestHelpers.AssertTrue(SalesShipmentHeader.COUNT = 4, 'Expected 4 Sales Shipment Headers to be created. Only %1 were created', SalesShipmentHeader.COUNT);

        // [THEN] 8 shipment lines should have been created
        SalesShipLine.SETRANGE("DOK MST Order No.", MSTOrderNo);
        TestHelpers.AssertTrue(SalesShipLine.COUNT = 8, 'Expected 8 Sales Shipment Lines to be created. Only %1 were created', SalesShipLine.COUNT);

    end;

    [Test]
    [HandlerFunctions('PostBatchSalesPostingMessageHandler')]

    procedure Test_CombineMSTShipmentTo1Invoice()
    var
        SalesHeader: Record "Sales Header";
        MST: Record "DOK Multiple Ship-to Orders";
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
        SalesPost: Codeunit "Sales-Post";
        QtyOnOrderLinesCreatedFromMSTOrders: Decimal;
    begin

        // [SETUP] Create a Resource for the Freight line
        //[SETUP] Create a Resource for the Freight line
        FreightCode := TestHelpersUtilities.GetRandomString(20);
        if not Setup.Get() then begin
            Setup.Init();
            Setup."Freight No." := FreightCode;
            Setup.Insert();
        end else begin
            Setup."Freight No." := FreightCode;
            Setup.Modify(TRUE)
        end;
        TestHelpersUtilities.CreateResource(Resource, FreightCode);

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
        SalesShipmentHeader.SETRANGE("DOK MST Order No.", MSTOrderNo);
        TestHelpers.AssertTrue(SalesShipmentHeader.COUNT = 4, 'Expected 4 Sales Shipment Headers to be created. Only %1 were created', SalesShipmentHeader.COUNT);

        // [THEN] 8 shipment lines should have been created
        SalesShipLine.SETRANGE("DOK MST Order No.", MSTOrderNo);
        TestHelpers.AssertTrue(SalesShipLine.COUNT = 8, 'Expected 8 Sales Shipment Lines to be created. Only %1 were created', SalesShipLine.COUNT);

        // [THEN] 1 sales order of type invoice should have been created
        SalesInvoiceHeader.SETRANGE("DOK MST Order No.", MSTOrderNo);
        SalesInvoiceHeader.SETRANGE("Document Type", SalesInvoiceHeader."Document Type"::Invoice);
        TestHelpers.AssertTrue(SalesInvoiceHeader.COUNT = 1, 'Expected 1 Sales Invoice Header to be created. Only %1 were created', SalesInvoiceHeader.COUNT);

    end;

    [Test]
    [HandlerFunctions('PostBatchSalesPostingMessageHandler')]

    procedure Test_CombineMSTShipmentTo1InvoiceContains8Lines()
    var
        SalesHeader: Record "Sales Header";
        MST: Record "DOK Multiple Ship-to Orders";
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
        SalesPost: Codeunit "Sales-Post";
        QtyOnOrderLinesCreatedFromMSTOrders: Decimal;
    begin

        // [SETUP] Create a Resource for the Freight line
        //[SETUP] Create a Resource for the Freight line
        FreightCode := TestHelpersUtilities.GetRandomString(20);
        if not Setup.Get() then begin
            Setup.Init();
            Setup."Freight No." := FreightCode;
            Setup.Insert();
        end else begin
            Setup."Freight No." := FreightCode;
            Setup.Modify(TRUE)
        end;
        TestHelpersUtilities.CreateResource(Resource, FreightCode);

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
        SalesShipmentHeader.SETRANGE("DOK MST Order No.", MSTOrderNo);
        TestHelpers.AssertTrue(SalesShipmentHeader.COUNT = 4, 'Expected 4 Sales Shipment Headers to be created. Only %1 were created', SalesShipmentHeader.COUNT);

        // [THEN] 8 shipment lines should have been created
        SalesShipLine.SETRANGE("DOK MST Order No.", MSTOrderNo);
        TestHelpers.AssertTrue(SalesShipLine.COUNT = 8, 'Expected 8 Sales Shipment Lines to be created. Only %1 were created', SalesShipLine.COUNT);

        // [THEN] 1 sales order of type invoice should have been created
        SalesInvoiceHeader.SETRANGE("DOK MST Order No.", MSTOrderNo);
        SalesInvoiceHeader.SETRANGE("Document Type", SalesInvoiceHeader."Document Type"::Invoice);
        TestHelpers.AssertTrue(SalesInvoiceHeader.COUNT = 1, 'Expected 1 Sales Invoice Header to be created. Only %1 were created', SalesInvoiceHeader.COUNT);

        // [THEN] 8 sales invoice lines should have been created
        SalesInvoiceHeader.FindFirst();
        SalesLine.SETRANGE("Document Type", SalesLine."Document Type"::Invoice);
        SalesLine.SETRANGE("Document No.", SalesInvoiceHeader."No.");
        TestHelpers.AssertTrue(SalesLine.COUNT = 8, 'Expected 8 Sales Invoice Lines to be created. Only %1 were created', SalesLine.COUNT);

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
        TestHelpersSales: Codeunit "Test Helpers Sales";

}