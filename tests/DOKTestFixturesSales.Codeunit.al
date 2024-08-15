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
        SalesLine."Line No." := LineNo;
        if SalesLine.Quantity = 0 then
            SalesLine.Validate(Quantity, 1);
    end;

    procedure CreateSalesLines(SalesHeader: Record "Sales Header"; NumberOfLines: Integer)
    var
        SalesLine: Record "Sales Line";
        i: Integer;
    begin
        for i := 1 to NumberOfLines do begin
            SalesLine := CreateSalesLine(SalesHeader);
            SalesLine.Insert(true);
        end;
    end;

    procedure CreateSalesInvoiceWithMSTShipmentLines(SalesHeader: Record "Sales Header"; NumberOfMSTOrders: Integer) SalesInvoiceHeader: Record "Sales Header"
    var
        MSTMgt: Codeunit "DOK MST Management";
        BatchPostMSTSalesOrders: Codeunit "DOK Batch Post MST SalesOrders";
        MSTOrderNo: Code[20];
    begin
        SalesHeader := CreateSalesOrder();
        CreateSalesLines(SalesHeader, 1);
        CreateMSTOrders(SalesHeader, 4);
        MSTOrderNo := SalesHeader."No.";
        MSTMgt.CreateOrdersFromMST(SalesHeader);
        BatchPostMSTSalesOrders.PostShipMSTSalesOrders(MSTOrderNo);
        BatchPostMSTSalesOrders.CreateInvoiceWithCombinedMSTShipments(MSTOrderNo);
        SalesInvoiceHeader.SetRange("DOK MST Order No.", MSTOrderNo);
        SalesInvoiceHeader.SetRange("Document Type", SalesInvoiceHeader."Document Type"::Invoice);
        SalesInvoiceHeader.FindFirst();
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

    procedure CreateMSTOrders(SalesHeader: Record "Sales Header"; NumberOfMSTOrders: Integer);
    var
        MSTOrders: Record "DOK Multiple Ship-to Orders";
        SalesLine: Record "Sales Line";
        Util: Codeunit "DOK Test Utilities";
        NumberOfIterations: Integer;
    begin
        // populate MSTOrders with random address data
        SalesLine.SetRange("Document Type", SalesLine."Document Type"::Order);
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetRange(Type, SalesLine.Type::Item);
        SalesLine.FindSet();
        repeat
            NumberOfIterations := 0;
            repeat
                Clear(MSTOrders);
                MSTOrders.Init();
                MSTOrders."Order No." := SalesHeader."No.";
                MSTOrders."Line No." := SalesLine."Line No.";
                MSTOrders."Ship-to Name" := CopyStr(Util.GetRandomString(8), 1, MaxStrLen(MSTOrders."Ship-to Name"));
                MSTOrders."Ship-to Address" := CopyStr(Util.GetRandomString(8), 1, MaxStrLen(MSTOrders."Ship-to Address"));
                MSTOrders."Ship-to City" := CopyStr(Util.GetRandomString(8), 1, MaxStrLen(MSTOrders."Ship-to City"));
                MSTOrders."Ship-to State" := CopyStr(Util.GetRandomString(8), 1, MaxStrLen(MSTOrders."Ship-to State"));
                MSTOrders."Ship-to Post Code" := '84454';
                MSTOrders."Ship-to Country" := 'US';
                MSTOrders."Ship-to Phone No." := '333.333.3333';
                MSTOrders."Ship-to Email" := 'bob@bob.com';
                MSTOrders.Validate(Quantity, Random(100));
                MSTOrders.Insert(true);
                NumberOfIterations += 1;
            until NumberOfIterations = NumberOfMSTOrders;
        until SalesLine.Next() = 0;

    end;
}