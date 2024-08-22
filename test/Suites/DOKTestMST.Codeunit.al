codeunit 50011 "DOK Test MST"
{
    Subtype = Test;

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

    var
        TestHelpers: Codeunit "DOK Test Helpers";
        TestFixturesSales: Codeunit "DOK Test Fixtures Sales";
}