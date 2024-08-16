tableextension 50000 "DOK Sales Invoice Line Ext" extends "Sales Invoice Line"
{
    fields
    {
        field(50001; "DOK Original Order Qty."; Integer)
        {
            DataClassification = SystemMetadata;
            Editable = false;
        }

        modify(Quantity)
        {
            trigger OnAfterValidate();
            begin
                if "DOK Original Order Qty." = 0 then
                    "DOK Original Order Qty." := Quantity;
            end;
        }
    }
}