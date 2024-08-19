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
        SalesLine."Package Tracking No." := CopyStr(TestUtilities.GetRandomString(8), 1, MaxStrLen(SalesLine."Package Tracking No."));
        SalesLine."Line No." := LineNo;
        if SalesLine.Quantity = 0 then
            SalesLine.Validate(Quantity, 1);
    end;

    procedure CreateSalesLine(Quantity: Decimal): Record "Sales Line"
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
    begin
        SalesHeader := CreateSalesOrder();
        SalesLine.Init();
        SalesLine."Document Type" := SalesLine."Document Type"::Order;
        SalesLine."Document No." := SalesHeader."No.";
        SalesLine.Type := SalesLine.Type::Item;
        SalesLine."No." := GetRandomItem()."No.";
        SalesLine."Package Tracking No." := CopyStr(TestUtilities.GetRandomString(8), 1, MaxStrLen(SalesLine."Package Tracking No."));
        SalesLine.Validate(Quantity, 1);
    end;

    procedure GetRandomSalesHeaderOfTypeOrder() SalesHeader: Record "Sales Header"
    begin
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
        SalesHeader.FindSet();
        SalesHeader.Next(Random(SalesHeader.Count));
        SalesHeader."Shipment Date" := WORKDATE();
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

    procedure CreateSalesInvoiceWithMSTShipmentLines(SalesHeader: Record "Sales Header"; NumberOfSalesLines: Integer; NumberOfMSTOrders: Integer) SalesInvoiceHeader: Record "Sales Header"
    var
        MSTMgt: Codeunit "DOK MST Management";
        MSTOrderNo: Code[20];
    begin
        SalesHeader := CreateSalesOrder();
        AddSalesLinesToSalesHeader(SalesHeader, NumberOfSalesLines);
        CreateMSTEntries(SalesHeader, NumberOfMSTOrders);
        MSTOrderNo := SalesHeader."No.";
        MSTMgt.CreateOrdersFromMSTEntries(SalesHeader);
        MSTMgt.PostShipOrdersCreatedFromMST(SalesHeader);
        MSTMgt.CreateInvoiceWithCombinedMSTShipments(MSTOrderNo);
        SalesInvoiceHeader.SetRange("DOK MST Order No.", MSTOrderNo);
        SalesInvoiceHeader.SetRange("Document Type", SalesInvoiceHeader."Document Type"::Invoice);
        SalesInvoiceHeader.FindFirst();
    end;

    procedure CreateMSTSalesOrderWithMSTEntries(NumberOfSalesLines: Integer; NumberOfMSTOrders: Integer) SalesHeader: Record "Sales Header"
    var
    begin
        SalesHeader := CreateSalesOrder();
        AddSalesLinesToSalesHeader(SalesHeader, NumberOfSalesLines);
        CreateMSTEntries(SalesHeader, NumberOfMSTOrders);
    end;

    procedure CreateMSTSalesOrderReadyToPost(NumberOfSalesLines: Integer; NumberOfMSTOrders: Integer) SalesHeader: Record "Sales Header"
    var
        MSTManagement: Codeunit "DOK MST Management";
    begin
        SalesHeader := CreateSalesOrder();
        AddSalesLinesToSalesHeader(SalesHeader, NumberOfSalesLines);
        CreateMSTEntries(SalesHeader, NumberOfMSTOrders);
        MSTManagement.CreateOrdersFromMSTEntries(SalesHeader);
    end;

    procedure CreateMSTSalesOrderWithPostedShipments(NumberOfSalesLines: Integer; NumberOfMSTOrders: Integer) SalesHeader: Record "Sales Header"
    var
        MSTManagement: Codeunit "DOK MST Management";
    begin
        SalesHeader := CreateSalesOrder();
        AddSalesLinesToSalesHeader(SalesHeader, NumberOfSalesLines);
        CreateMSTEntries(SalesHeader, NumberOfMSTOrders);
        MSTManagement.CreateOrdersFromMSTEntries(SalesHeader);
        MSTManagement.PostShipOrdersCreatedFromMST(SalesHeader);
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

    procedure CreateMSTEntries(SalesHeader: Record "Sales Header"; NumberOfMSTOrders: Integer);
    var
        MSTOrders: Record "DOK Multiple Ship-to Entries";
        SalesLine: Record "Sales Line";
        Util: Codeunit "DOK Test Utilities";
        MSTMgt: Codeunit "DOK MST Management";
        NumberOfIterations: Integer;
    begin
        MSTMgt.CreateMockMSTOrders(SalesHeader."No.", NumberOfMSTOrders);
        exit;
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

    var
        TestUtilities: Codeunit "DOK Test Utilities";

}