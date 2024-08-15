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
        exit(Rec."DOK MST Order No." <> '');
        // if Rec."Document Type" <> Rec."Document Type"::Order then
        //     exit(false);
        // MST.SETRANGE("Order No.", Rec."No.");
        // exit(NOT MST.IsEmpty);
    end;

    procedure HasMSTOrders(): Boolean;
    var
        MST: Record "DOK Multiple Ship-to Orders";
    begin
        if Rec."Document Type" <> Rec."Document Type"::Order then
            exit(false);
        MST.SETRANGE("Order No.", Rec."No.");
        exit(NOT MST.IsEmpty);
    end;

    procedure PostShipMSTOrder();
    var
        MSTManagement: Codeunit "DOK MST Management";
    begin
        MSTManagement.PostOrdersCreatedFromMST(Rec);
    end;


}