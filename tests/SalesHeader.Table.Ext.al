tableextension 50001 "Sales Header Ext" extends "Sales Header"
{
    fields
    {
        // MSTOrderNo
        field(50000; "DOK MST Order No."; Code[20])
        {
            DataClassification = ToBeClassified;
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
    var
        MST: Record "DOK Multiple Ship-to Orders";
    begin
        MST.SETRANGE("Order No.", Rec."No.");
        exit(NOT MST.IsEmpty);
    end;


}