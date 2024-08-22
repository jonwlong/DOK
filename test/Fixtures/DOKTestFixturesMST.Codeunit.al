codeunit 50004 "DOK Test Fixtures MST"
{

    // procedure CreateSalesInvoiceWithMSTShipmentLines(SalesHeader: Record "Sales Header"; NumberOfSalesLines: Integer; NumberOfMSTOrders: Integer) SalesInvoiceHeader: Record "Sales Header"
    // var
    //     MSTManagement: Codeunit "DOK MST Management";
    //     MSTOrderNo: Code[20];
    // begin
    //     SalesHeader := TestFixturesSales.CreateSalesOrder();
    //     TestFixturesSales.AddSalesLinesToSalesHeader(SalesHeader, NumberOfSalesLines);
    //     MSTManagement.CreateMockMSTEntries(SalesHeader."No.", NumberOfMSTOrders);
    //     MSTOrderNo := SalesHeader."No.";
    //     MSTManagement.CreateOrdersFromMSTEntries(SalesHeader);
    //     MSTManagement.PostShipOrdersCreatedFromMST(SalesHeader);
    //     MSTManagement.CreateInvoiceWithCombinedMSTShipments(MSTOrderNo);
    //     SalesInvoiceHeader.SetRange("DOK MST Order No.", MSTOrderNo);
    //     SalesInvoiceHeader.SetRange("Document Type", SalesInvoiceHeader."Document Type"::Invoice);
    //     SalesInvoiceHeader.FindFirst();
    // end;

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


    var
        TestFixturesSales: Codeunit "DOK Test Fixtures Sales";
}