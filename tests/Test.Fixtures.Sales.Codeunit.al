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
        LineNo: Integer;
    begin
        SalesLine.SetRange("Document Type", SalesLine."Document Type"::Order);
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetRange(Type, SalesLine.Type::Item);
        if SalesLine.FINDLAST then
            LineNo := SalesLine."Line No." + 10000
        else
            LineNo := 10000;


        SalesLine.INIT;
        SalesLine.Validate("Document Type", SalesLine."Document Type"::Order);
        SalesLine.Validate("Document No.", SalesHeader."No.");
        SalesLine.Validate(Type, SalesLine.Type::Item);
        SalesLine.Validate("No.", GetRandomItem()."No.");
        SalesLine.Validate(Quantity, Random(100));
        SalesLine."Line No." := LineNo;
        if SalesLine.Quantity = 0 then
            SalesLine.Validate(Quantity, 1);
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
        Item.SetFilter("Blocked", '=%1', FALSE);
        Item.SetFilter("Item Tracking Code", '=%1', '');
        Item.SetFilter("Gen. Prod. Posting Group", '<>%1', 'RAW MAT');
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

    procedure CreateMSTOrders(SalesHeader: Record "Sales Header"; NumberOfMSTOrders: Integer);
    var
        MSTOrders: Record "DOK Multiple Ship-to Orders";
        SalesLine: Record "Sales Line";
        NumberOfIterations: Integer;
        Util: Codeunit "DOK Test Utilities";
    begin
        // populate MSTOrders with random address data
        SalesLine.SetRange("Document Type", SalesLine."Document Type"::Order);
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetRange(Type, SalesLine.Type::Item);
        SalesLine.FindSet();
        repeat
            NumberOfIterations := 0;
            Repeat
                Clear(MSTOrders);
                MSTOrders.INIT;
                MSTOrders."Order No." := SalesHeader."No.";
                MSTOrders."Line No." := SalesLine."Line No.";
                MSTOrders."Ship-to Name" := Util.GetRandomString(8);
                MSTOrders."Ship-to Address" := Util.GetRandomString(8);
                MSTOrders."Ship-to City" := Util.GetRandomString(8);
                MSTOrders."Ship-to State" := Util.GetRandomString(8);
                MSTOrders."Ship-to Post Code" := '84454';
                MSTOrders."Ship-to Country" := 'US';
                MSTOrders."Ship-to Phone No." := '333.333.3333';
                MSTOrders."Ship-to Email" := 'bob@bob.com';
                MSTOrders.Validate("Quantity", random(100));
                MSTOrders.INSERT(TRUE);
                NumberOfIterations += 1;
            until NumberOfIterations = NumberOfMSTOrders;
        until SalesLine.Next = 0;

    end;

    var
        TestHelpers: Codeunit "DOK Test Helpers";
        TestHelpersUtilities: Codeunit "DOK Test Utilities";
}