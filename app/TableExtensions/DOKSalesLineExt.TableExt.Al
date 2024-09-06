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
        // flowfield to calculate the sum of the quantity of the related DOKMultipleShipToEntries
        field(50002; "DOK MST Order Qty."; Decimal)
        {
            Caption = 'MST Quantity';
            Editable = false;
            FieldClass = FlowField;
            DecimalPlaces = 0 : 5;
            CalcFormula = sum("DOK Multiple Ship-to Entries".Quantity where("Order No." = field("Document No."), "Line No." = field("Line No.")));

        }
    }
}