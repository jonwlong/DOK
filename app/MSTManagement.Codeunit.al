codeunit 50009 "DOK MST Management"
{
    procedure CreateOrdersFromMST(MSTSalesHeader: Record "Sales Header")
    var
        MST: Record "DOK Multiple Ship-to Orders";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        MSTSalesLine: Record "Sales Line";
    begin
        MST.SETRANGE("Order No.", MSTSalesHeader."No.");
        if MST.FINDSET then begin
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
                MSTSalesLine.get(SalesLine."Document Type"::Order, MST."Order No.", MST."Line No.");
                SalesLine.TransferFields(MSTSalesLine);
                SalesLine."Document No." := SalesHeader."No.";
                SalesLine.Validate("Sell-to Customer No.");
                SalesLine.Validate(Quantity, MST.Quantity);
                SalesLine.INSERT(true);
            until MST.NEXT = 0;
        end;
    end;

    procedure PostOrdersCreatedFromMST(MSTSalesHeader: Record "Sales Header")
    var
        SalesHeader: Record "Sales Header";
        SalesPost: Codeunit "Sales-Post";
    begin
        SalesHeader.SETRANGE("DOK MST Order No.", MSTSalesHeader."No.");
        if SalesHeader.FINDSET then
            repeat
                SalesHeader.Ship := true;
                SalesHeader.Invoice := false;
                SalesHeader.Modify(true);
                SalesPost.Run(SalesHeader);
            until SalesHeader.NEXT = 0;
    end;

}