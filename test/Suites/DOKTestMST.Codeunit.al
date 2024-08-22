codeunit 50011 "DOK Test MST"
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

    [Test]
    procedure Test_CreateMSTEntriesForSalesOrder()
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
        MSTMgt.CreateMockMSTEntries(SalesHeader."No.", 2);

        // [THEN] There should be 2 MSTs
        TestHelpers.AssertTrue(MST.Count = 2, 'Expected 2 MSTs to be created, but found %1', MST.Count);

        // [THEN] The quantity on the Sales Order line MST Quantity field should be greater than zero
        SalesLine.Get(SalesLine."Document Type"::Order, SalesHeader."No.", 10000);
        SalesLine.CalcFields("DOK MST Order Qty.");
        TestHelpers.AssertTrue(SalesLine."DOK MST Order Qty." > 0, 'MST Quantity is not greater than 0');

    end;

    [Test]
    procedure Test_CreateOrdersFromMSTEntries()
    var
        MSTSalesHeader: Record "Sales Header";
        SalesHeader: Record "Sales Header";
        MSTManagement: Codeunit "DOK MST Management";
    begin
        Initialize();

        // [GIVEN] A Sales Order with 1 Sales Line and 2 MSTs
        MSTSalesHeader := TestFixturesMST.CreateMSTSalesOrderWithMSTEntries(1, 2);

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

        Initialize();

        // [GIVEN] A Sales Order with 1 Sales Line with 2 MSTs each
        MSTSalesHeader := TestFixturesMST.CreateMSTSalesOrderReadyToPost(1, 2);

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

    var
        TestHelpers: Codeunit "DOK Test Helpers";
        TestFixturesSales: Codeunit "DOK Test Fixtures Sales";
        TestFixturesMST: Codeunit "DOK Test Fixtures MST";
        TestHelpersUtilities: Codeunit "DOK Test Utilities";
        Utilities: Codeunit "DOK Utilities";
        Initialized: Boolean;
}