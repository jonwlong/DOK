codeunit 50003 "DOK Test Fixtures Sales"
{

    procedure CreateSalesOrder() SalesHeader: Record "Sales Header"
    var
    begin
        SalesHeader.Init();
        SalesHeader.Validate("Document Type", SalesHeader."Document Type"::Order);
        SalesHeader.Validate("Sell-to Customer No.", GetRandomCustomer()."No.");
        SalesHeader.Insert(true);
    end;

    procedure CreateSalesOrderWithSalesLines(NumberOfLines: Integer) SalesHeader: Record "Sales Header"
    var
    begin
        SalesHeader := CreateSalesOrder();
        AddXNumberOfSalesLinesToSalesOrder(SalesHeader, NumberOfLines);
    end;

    local procedure CreateSalesLine(SalesHeader: Record "Sales Header") SalesLine: Record "Sales Line"
    var
        LineNo: Integer;
    begin
        SalesLine.SetRange("Document Type", SalesLine."Document Type"::Order);
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetRange(Type, SalesLine.Type::Item);
        if SalesLine.FindLast() then
            LineNo := SalesLine."Line No." + 10000
        else
            LineNo := 10000;


        SalesLine.Init();
        SalesLine.Validate("Document Type", SalesLine."Document Type"::Order);
        SalesLine.Validate("Document No.", SalesHeader."No.");
        SalesLine.Validate(Type, SalesLine.Type::Item);
        SalesLine.Validate("No.", GetRandomItem()."No.");
        SalesLine.Validate(Quantity, Random(100));
        SalesLine."Package Tracking No." := CopyStr(TestUtilities.GetRandomString(8), 1, MaxStrLen(SalesLine."Package Tracking No."));
        SalesLine."Line No." := LineNo;
        if SalesLine.Quantity = 0 then
            SalesLine.Validate(Quantity, 1);
    end;

    procedure CreateSalesLine(): Record "Sales Line"
    var
        SalesHeader: Record "Sales Header";
    begin
        SalesHeader := CreateSalesOrder();
        AddSalesLinesToSalesHeader(SalesHeader, 1);
    end;

    procedure GetRandomSalesHeaderOfTypeOrder() SalesHeader: Record "Sales Header"
    begin
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
        SalesHeader.FindSet();
        SalesHeader.Next(Random(SalesHeader.Count));
        SalesHeader."Shipment Date" := WorkDate();
        exit(SalesHeader);
    end;

    procedure AddSalesLinesToSalesHeader(SalesHeader: Record "Sales Header"; NumberOfLines: Integer)
    var
        SalesLine: Record "Sales Line";
        i: Integer;
    begin
        for i := 1 to NumberOfLines do begin
            SalesLine := CreateSalesLine(SalesHeader);
            SalesLine.Insert(true);
        end;
    end;

    procedure AddXNumberOfSalesLinesToSalesOrder(SalesHeader: Record "Sales Header"; NumberOfLines: Integer)
    var
        SalesLine: Record "Sales Line";
        i: Integer;
    begin
        for i := 1 to NumberOfLines do begin
            SalesLine := CreateSalesLine(SalesHeader);
            SalesLine.Insert(true);
        end;
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
        TestUtilities: Codeunit "DOK Test Utilities";

}