codeunit 50009 "DOK MST Management"
{
    procedure CreateMockMSTEntries(SalesHeaderNo: Code[20]; NumberOfMSTEntries: Integer);
    var
        MSTEntries: Record "DOK Multiple Ship-to Entries";
        SalesLine: Record "Sales Line";
        Util: Codeunit "DOK Utilities";
        NumberOfIterations: Integer;
    begin
        // populate MSTEntries with random address data
        SalesLine.SetRange("Document Type", SalesLine."Document Type"::Order);
        SalesLine.SetRange("Document No.", SalesHeaderNo);
        SalesLine.SetRange(Type, SalesLine.Type::Item);
        SalesLine.FindSet();
        repeat
            NumberOfIterations := 0;
            repeat
                Clear(MSTEntries);
                MSTEntries.Init();
                MSTEntries."Order No." := SalesHeaderNo;
                MSTEntries."Line No." := SalesLine."Line No.";
                MSTEntries."Ship-to Name" := Util.GetRandomText30();
                MSTEntries."Ship-to Address" := Util.GetRandomText30();
                MSTEntries."Ship-to City" := Util.GetRandomText30();
                MSTEntries."Ship-to State" := Util.GetRandomCode10();
                MSTEntries."Ship-to Post Code" := '84454';
                MSTEntries."Ship-to Country" := 'US';
                MSTEntries."Ship-to Phone No." := '333.333.3333';
                MSTEntries."Ship-to Email" := 'bob@bob.com';
                MSTEntries.Validate(Quantity, Random(100));
                MSTEntries.Insert(true);
                NumberOfIterations += 1;
            until NumberOfIterations = NumberOfMSTEntries;
        until SalesLine.Next() = 0;
    end;

    // procedure CreateOrdersFromMSTEntries(MSTSalesHeader: Record "Sales Header")
    // var
    //     MST: Record "DOK Multiple Ship-to Entries";
    //     SalesHeader: Record "Sales Header";
    //     SalesLine: Record "Sales Line";
    //     MSTSalesLine: Record "Sales Line";
    // begin
    //     MST.SetRange("Order No.", MSTSalesHeader."No.");
    //     if MST.FindSet() then
    //         repeat
    //             // Create a new Sales Order with lines from the MST. The ship to addresses come from the MST Lines
    //             // The Sales Header is a duplicate of the original Sales Order
    //             SalesHeader.TransferFields(MSTSalesHeader);
    //             SalesHeader.Validate("Document Type", SalesHeader."Document Type"::Order);
    //             SalesHeader."No." := 'MST' + Format(MST."Entry No.");
    //             SalesHeader.Validate("Sell-to Customer No.");
    //             SalesHeader.Validate("DOK MST Order No.", MST."Order No.");
    //             SalesHeader.Validate(Ship, true);
    //             SalesHeader.Validate(Invoice, false);
    //             // validate the address fields from the MST
    //             SalesHeader.Validate("Ship-to Name", MST."Ship-to Name");
    //             SalesHeader.Validate("Ship-to Address", MST."Ship-to Address");
    //             SalesHeader.Validate("Ship-to City", MST."Ship-to City");
    //             SalesHeader.Validate("Ship-to Post Code", MST."Ship-to Post Code");
    //             SalesHeader.Validate("Ship-to Country/Region Code", MST."Ship-to Country");
    //             SalesHeader.Insert(true);
    //             MSTSalesLine.Get(SalesLine."Document Type"::Order, MST."Order No.", MST."Line No.");
    //             SalesLine.TransferFields(MSTSalesLine);
    //             SalesLine."Document No." := SalesHeader."No.";
    //             SalesLine.Validate("Sell-to Customer No.");
    //             SalesLine.Validate(Quantity, MST.Quantity);
    //             SalesLine.Insert(true);
    //         until MST.Next() = 0;
    // end;


    // procedure MSTEntriesAndCreatedSalesOrdersReconcile(MSTSalesHeaderNo: Text[20]): Boolean
    // var
    //     SalesHeader: Record "Sales Header";
    //     SalesLine: Record "Sales Line";
    //     MSTEntries: Record "DOK Multiple Ship-to Entries";
    //     QtyOnOrderLinesCreatedFromMSTOrders: Decimal;
    // begin
    //     SalesHeader.SetRange("DOK MST Order No.", MSTSalesHeaderNo);
    //     if SalesHeader.FindSet() then
    //         repeat
    //             SalesLine.SetRange("Document Type", SalesLine."Document Type"::Order);
    //             SalesLine.SetRange("Document No.", SalesHeader."No.");
    //             SalesLine.SetRange(Type, SalesLine.Type::Item);
    //             SalesLine.CalcSums(Quantity);
    //             QtyOnOrderLinesCreatedFromMSTOrders += SalesLine.Quantity;
    //         until SalesHeader.Next() = 0;
    //     MSTEntries.SetRange("Order No.", MSTSalesHeaderNo);
    //     MSTEntries.CalcSums(Quantity);
    //     exit(QtyOnOrderLinesCreatedFromMSTOrders = MSTEntries.Quantity);
    // end;

}