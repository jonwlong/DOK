tableextension 50001 "Sales Header Ext" extends "Sales Header"
{
    fields
    {
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


}