codeunit 50004 "DOK Test Fixtures MST"
{

    // procedure CreateMSTSalesOrderWithMSTEntries(NumberOfSalesLines: Integer; NumberOfMSTOrders: Integer) SalesHeader: Record "Sales Header"
    // var
    //     MSTManagement: Codeunit "DOK MST Management";
    // begin
    //     SalesHeader := TestFixturesSales.CreateSalesOrder();
    //     TestFixturesSales.AddSalesLinesToSalesHeader(SalesHeader, NumberOfSalesLines);
    //     MSTManagement.CreateMockMSTEntries(SalesHeader."No.", NumberOfMSTOrders);
    // end;


    var
        TestFixturesSales: Codeunit "DOK Test Fixtures Sales";
}