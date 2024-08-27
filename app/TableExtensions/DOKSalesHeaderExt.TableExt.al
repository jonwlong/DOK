tableextension 50001 "DOK Sales Header Ext" extends "Sales Header"
{
    fields
    {
        // MSTOrderNo
        field(50000; "DOK MST Order No."; Code[20])
        {
            DataClassification = SystemMetadata;
        }
#pragma warning disable AL0432
        modify("Package Tracking No.")
#pragma warning restore AL0432
        {
            trigger OnAfterValidate()
            var
                SalesLine: Record "Sales Line";
            begin
                SalesLine.SetRange("Document Type", SalesLine."Document Type"::Order);
                SalesLine.SetRange("Document No.", Rec."No.");
                if SalesLine.FindSet() then
                    repeat
#pragma warning disable AL0432
                        SalesLine."Package Tracking No." := Rec."Package Tracking No.";
#pragma warning restore AL0432
                        SalesLine.Modify();
                    until SalesLine.Next() = 0;
            end;
        }
    }

    keys
    {
        key(DOKMSTOrder; "DOK MST Order No.")
        {
        }
        key(DOKSalesHeader; "No.")
        {
        }
    }

    procedure CalculateFreight(): Decimal;
    var
        FreightManagement: Codeunit "DOK Freight Management";
    begin
        exit(FreightManagement.CalculateFreight(Rec));
    end;

    procedure AddFreightLine(FreightAmount: Decimal);
    var
        FreightManagement: Codeunit "DOK Freight Management";
    begin
        FreightManagement.AddFreightLine(Rec, FreightAmount);
    end;

    procedure IsMSTOrder(): Boolean;
    begin
        exit(Rec."DOK MST Order No." <> '');
    end;

    procedure HasMSTOrders(): Boolean;
    var
        MST: Record "DOK Multiple Ship-to Entries";
    begin
        if Rec."Document Type" <> Rec."Document Type"::Order then
            exit(false);
        MST.SetRange("Order No.", Rec."No.");
        exit(not MST.IsEmpty);
    end;

    procedure HasFreightLine() FreightLineFound: Boolean;
    var
        SalesLine: Record "Sales Line";
        DOKSetup: Record "DOK Setup";
    begin
        DOKSetup.Get();
        SalesLine.SetRange("Document Type", SalesLine."Document Type"::Order);
        SalesLine.SetRange("Document No.", Rec."No.");
        SalesLine.SetRange("Type", SalesLine."Type"::Resource);
        SalesLine.SetRange("No.", DOKSetup."Freight No.");
        if SalesLine.IsEmpty then
            FreightLineFound := false
        else
            FreightLineFound := true;
        exit(FreightLineFound);
    end;

    procedure CreateMockMSTEntries(No: Code[20]; Count: Integer);
    var
        MSTManagement: Codeunit "DOK MST Management";
    begin
        MSTManagement.CreateMockMSTEntries(No, Count);
    end;

    procedure CreateOrdersFromMSTEntries();
    var
        MSTManagement: Codeunit "DOK MST Management";
    begin
        MSTManagement.CreateOrdersFromMSTEntries(Rec);
    end;

    procedure PostShipOrdersCreatedFromMST();
    var
        MSTManagement: Codeunit "DOK MST Management";
    begin
        MSTManagement.PostShipOrdersCreatedFromMST(Rec);
    end;

    procedure CreateInvoiceWithCombinedMSTShipments() SalesInvoiceHeader: Record "Sales Header";
    var
        MSTManagement: Codeunit "DOK MST Management";
    begin
        SalesInvoiceHeader := MSTManagement.CreateInvoiceWithCombinedMSTShipments(Rec."No.");
    end;



}