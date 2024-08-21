tableextension 50001 "DOK Sales Header Ext" extends "Sales Header"
{
    fields
    {
        // MSTOrderNo
        field(50000; "DOK MST Order No."; Code[20])
        {
            DataClassification = SystemMetadata;
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

}