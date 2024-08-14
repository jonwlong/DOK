tableextension 50100 "Sales Line Ext" extends "Sales Line"
{
    fields
    {
        field(50000; "DOK MST Order No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(50001; "DOK Original Order Qty."; Integer)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }

        modify("Quantity")
        {
            trigger OnAfterValidate();
            begin
                if "DOK Original Order Qty." = 0 then
                    "DOK Original Order Qty." := Quantity;
            end;
        }
    }
}