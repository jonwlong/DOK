tableextension 50100 "DOK Sales Line Ext" extends "Sales Line"
{
    fields
    {
        field(50000; "DOK MST Order No."; Code[20])
        {
            DataClassification = SystemMetadata;
        }
        field(50001; "DOK Original Order Qty."; Integer)
        {
            DataClassification = SystemMetadata;
            Editable = false;
        }

    }
}