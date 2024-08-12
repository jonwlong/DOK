codeunit 50003 "DOK Test Fixtures Sales"
{

    procedure CreateSalesOrder() SalesHeader: Record "Sales Header"
    var
    begin
        SalesHeader.INIT;
        SalesHeader.Validate("Document Type", SalesHeader."Document Type"::Order);
        SalesHeader.Validate("Sell-to Customer No.", GetRandomCustomer()."No.");
        SalesHeader.INSERT(TRUE);
    end;


    local procedure CreateSalesLine(SalesHeader: Record "Sales Header") SalesLine: Record "Sales Line"
    var
        Item: Record Item;
    begin
        SalesLine.INIT;
        SalesLine.Validate("Document Type", SalesLine."Document Type"::Order);
        SalesLine.Validate("Document No.", SalesHeader."No.");
        SalesLine.Validate(Type, SalesLine.Type::Item);
        SalesLine.Validate("No.", GetRandomItem()."No.");
        SalesLine.Validate(Quantity, Random(100));
        SalesLine."Line No." := SalesLine.Count + 10000;
        if SalesLine.Quantity = 0 then
            SalesLine.Validate(Quantity, 1);
        EXIT(SalesLine);
    end;

    procedure CreateSalesLines(SalesHeader: Record "Sales Header"; NumberOfLines: Integer)
    var
        i: Integer;
        SalesLine: Record "Sales Line";
    begin
        for i := 1 to NumberOfLines do begin
            SalesLine := CreateSalesLine(SalesHeader);
            SalesLine.INSERT(TRUE);
        end;
    end;

    procedure AddXNumberOfSalesLinesToSalesOrder(SalesHeader: Record "Sales Header"; NumberOfLines: Integer)
    var
        i: Integer;
        SalesLine: Record "Sales Line";
    begin
        for i := 1 to NumberOfLines do begin
            SalesLine := CreateSalesLine(SalesHeader);
            SalesLine.INSERT(TRUE);
        end;
    end;

    procedure GetRandomCustomer() Customer: Record Customer
    var
        RandomInt: Integer;
    begin
        Customer.FINDSET;
        RandomInt := Random(Customer.COUNT);
        Customer.Next(RandomInt);
        EXIT(Customer);
    end;

    procedure GetRandomItem() Item: Record Item
    var
        RandomInt: Integer;
    begin
        Item.FINDSET;
        RandomInt := Random(Item.COUNT);
        Item.Next(RandomInt);
        EXIT(Item);
    end;

    procedure GetLastPostedSalesInvoice() LastPostedSalesInvoice: Record "Sales Invoice Header"
    var
        NoSeries: Record "No. Series";
        NoSeriesLine: Record "No. Series Line";
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
    begin
        SalesReceivablesSetup.Get();
        NoSeriesLine.Get(SalesReceivablesSetup."Posted Invoice Nos.", 10000);
        LastPostedSalesInvoice.Get(NoSeriesLine."Last No. Used");
    end;

}