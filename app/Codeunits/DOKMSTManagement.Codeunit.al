codeunit 50009 "DOK MST Management"
{
    procedure CreateOrdersFromMSTEntries(MSTSalesHeader: Record "Sales Header")
    var
        MST: Record "DOK Multiple Ship-to Entries";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        MSTSalesLine: Record "Sales Line";
    begin
        MST.SetRange("Order No.", MSTSalesHeader."No.");
        if MST.FindSet() then
            repeat
                // Create a new Sales Order with lines from the MST. The ship to addresses come from the MST Lines
                // The Sales Header is a duplicate of the original Sales Order
                SalesHeader.TransferFields(MSTSalesHeader);
                SalesHeader.Validate("Document Type", SalesHeader."Document Type"::Order);
                SalesHeader."No." := 'MST' + Format(MST."Entry No.");
                SalesHeader.Validate("Sell-to Customer No.");
                SalesHeader.Validate("DOK MST Order No.", MST."Order No.");
                SalesHeader.Validate(Ship, true);
                SalesHeader.Validate(Invoice, false);
                // validate the address fields from the MST
                SalesHeader.Validate("Ship-to Name", MST."Ship-to Name");
                SalesHeader.Validate("Ship-to Address", MST."Ship-to Address");
                SalesHeader.Validate("Ship-to City", MST."Ship-to City");
                SalesHeader.Validate("Ship-to Post Code", MST."Ship-to Post Code");
                SalesHeader.Validate("Ship-to Country/Region Code", MST."Ship-to Country");
                SalesHeader.Insert(true);
                MSTSalesLine.Get(SalesLine."Document Type"::Order, MST."Order No.", MST."Line No.");
                SalesLine.TransferFields(MSTSalesLine);
                SalesLine."Document No." := SalesHeader."No.";
                SalesLine.Validate("Sell-to Customer No.");
                SalesLine.Validate(Quantity, MST.Quantity);
                SalesLine.Insert(true);
            until MST.Next() = 0;
    end;

    procedure CreateMockMSTOrders(SalesHeaderNo: Code[20]; NumberOfMSTOrders: Integer);
    var
        MSTOrders: Record "DOK Multiple Ship-to Entries";
        SalesLine: Record "Sales Line";
        Util: Codeunit "DOK Test Utilities";
        NumberOfIterations: Integer;
    begin
        // populate MSTOrders with random address data
        SalesLine.SetRange("Document Type", SalesLine."Document Type"::Order);
        SalesLine.SetRange("Document No.", SalesHeaderNo);
        SalesLine.SetRange(Type, SalesLine.Type::Item);
        SalesLine.FindSet();
        repeat
            NumberOfIterations := 0;
            repeat
                Clear(MSTOrders);
                MSTOrders.Init();
                MSTOrders."Order No." := SalesHeaderNo;
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

    procedure PostShipOrdersCreatedFromMST(MSTSalesHeader: Record "Sales Header")
    var
        SalesHeader: Record "Sales Header";
        SalesPost: Codeunit "Sales-Post";
    begin
        SalesHeader.SetRange("DOK MST Order No.", MSTSalesHeader."No.");
        if SalesHeader.FindSet() then
            repeat
                SalesHeader.Ship := true;
                SalesHeader.Invoice := false;
                SalesHeader.Modify(true);
                SalesPost.Run(SalesHeader);
            until SalesHeader.Next() = 0;
    end;

    procedure CreateInvoiceWithCombinedMSTShipments(MSTOrderNo: Text[20])
    var
        SalesHeader: Record "Sales Header";
        SalesShipLine: Record "Sales Shipment Line";
        SalesGetShipment: Codeunit "Sales-Get Shipment";
    begin
        SalesShipLine.SetRange("DOK MST Order No.", MSTOrderNo);
        if not SalesShipLine.FindSet() then
            Error('No Shipments found for MST Order No. %1', MSTOrderNo);
        SalesHeader.Init();
        SalesHeader.Validate("Document Type", SalesHeader."Document Type"::Invoice);
        SalesHeader.Validate("Sell-to Customer No.", SalesShipLine."Sell-to Customer No.");
        SalesHeader.Validate("DOK MST Order No.", MSTOrderNo);
        SalesHeader.Insert(true);
        SalesGetShipment.SetSalesHeader(SalesHeader);
        SalesGetShipment.CreateInvLines(SalesShipLine);
    end;

    procedure MSTEntriesAndCreatedSalesOrdersReconcile(MSTSalesHeaderNo: Text[20]): Boolean
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        MSTEntries: Record "DOK Multiple Ship-to Entries";
        QtyOnOrderLinesCreatedFromMSTOrders: Decimal;
    begin
        SalesHeader.SetRange("DOK MST Order No.", MSTSalesHeaderNo);
        if SalesHeader.FindSet() then
            repeat
                SalesLine.SetRange("Document Type", SalesLine."Document Type"::Order);
                SalesLine.SetRange("Document No.", SalesHeader."No.");
                SalesLine.SetRange(Type, SalesLine.Type::Item);
                SalesLine.CalcSums(Quantity);
                QtyOnOrderLinesCreatedFromMSTOrders += SalesLine.Quantity;
            until SalesHeader.Next() = 0;
        MSTEntries.SetRange("Order No.", MSTSalesHeaderNo);
        MSTEntries.CalcSums(Quantity);
        exit(QtyOnOrderLinesCreatedFromMSTOrders = MSTEntries.Quantity);
    end;

}