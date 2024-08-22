codeunit 50004 "DOK Test Fixtures MST"
{

    procedure CreateSalesInvoiceWithMSTShipmentLines(SalesHeader: Record "Sales Header"; NumberOfSalesLines: Integer; NumberOfMSTOrders: Integer) SalesInvoiceHeader: Record "Sales Header"
    var
        MSTManagement: Codeunit "DOK MST Management";
        MSTOrderNo: Code[20];
    begin
        SalesHeader := TestFixturesSales.CreateSalesOrder();
        TestFixturesSales.AddSalesLinesToSalesHeader(SalesHeader, NumberOfSalesLines);
        MSTManagement.CreateMockMSTEntries(SalesHeader."No.", NumberOfMSTOrders);
        MSTOrderNo := SalesHeader."No.";
        MSTManagement.CreateOrdersFromMSTEntries(SalesHeader);
        MSTManagement.PostShipOrdersCreatedFromMST(SalesHeader);
        MSTManagement.CreateInvoiceWithCombinedMSTShipments(MSTOrderNo);
        SalesInvoiceHeader.SetRange("DOK MST Order No.", MSTOrderNo);
        SalesInvoiceHeader.SetRange("Document Type", SalesInvoiceHeader."Document Type"::Invoice);
        SalesInvoiceHeader.FindFirst();
    end;

    procedure CreateMSTSalesOrderWithMSTEntries(NumberOfSalesLines: Integer; NumberOfMSTOrders: Integer) SalesHeader: Record "Sales Header"
    var
        MSTManagement: Codeunit "DOK MST Management";
    begin
        SalesHeader := TestFixturesSales.CreateSalesOrder();
        TestFixturesSales.AddSalesLinesToSalesHeader(SalesHeader, NumberOfSalesLines);
        MSTManagement.CreateMockMSTEntries(SalesHeader."No.", NumberOfMSTOrders);
    end;

    procedure CreateMSTSalesOrderReadyToPost(NumberOfSalesLines: Integer; NumberOfMSTOrders: Integer) SalesHeader: Record "Sales Header"
    var
        MSTManagement: Codeunit "DOK MST Management";
    begin
        SalesHeader := TestFixturesSales.CreateSalesOrder();
        TestFixturesSales.AddSalesLinesToSalesHeader(SalesHeader, NumberOfSalesLines);
        MSTManagement.CreateMockMSTEntries(SalesHeader."No.", NumberOfMSTOrders);
        MSTManagement.CreateOrdersFromMSTEntries(SalesHeader);
    end;

    procedure CreateMSTSalesOrderWithPostedShipments(NumberOfSalesLines: Integer; NumberOfMSTOrders: Integer) SalesHeader: Record "Sales Header"
    var
        MSTManagement: Codeunit "DOK MST Management";
    begin
        SalesHeader := TestFixturesSales.CreateSalesOrder();
        TestFixturesSales.AddSalesLinesToSalesHeader(SalesHeader, NumberOfSalesLines);
        MSTManagement.CreateMockMSTEntries(SalesHeader."No.", NumberOfMSTOrders);
        MSTManagement.CreateOrdersFromMSTEntries(SalesHeader);
        MSTManagement.PostShipOrdersCreatedFromMST(SalesHeader);
    end;


    procedure GetRandomCustomer() Customer: Record Customer
    var
        RandomInt: Integer;
    begin
        Customer.FindSet();
        RandomInt := Random(Customer.Count);
        Customer.Next(RandomInt);
        exit(Customer);
    end;

    procedure GetRandomItem() Item: Record Item
    var
        RandomInt: Integer;
    begin
        Item.SetFilter(Blocked, '=%1', false);
        Item.SetFilter("Item Tracking Code", '=%1', '');
        Item.SetFilter("Gen. Prod. Posting Group", '<>%1', 'RAW MAT');
        Item.FindSet();
        RandomInt := Random(Item.Count);
        Item.Next(RandomInt);
        exit(Item);
    end;

    procedure GetLastPostedSalesInvoice() LastPostedSalesInvoice: Record "Sales Invoice Header"
    var
        NoSeriesLine: Record "No. Series Line";
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
    begin
        SalesReceivablesSetup.Get();
        NoSeriesLine.Get(SalesReceivablesSetup."Posted Invoice Nos.", 10000);
        LastPostedSalesInvoice.Get(NoSeriesLine."Last No. Used");
    end;

    var
        TestFixturesSales: Codeunit "DOK Test Fixtures Sales";
        TestFixturesMST: Codeunit "DOK Test Fixtures MST";
}