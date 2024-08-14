tableextension 50004 "DOK Sales Shipment Line Ext" extends "Sales Shipment Line"
{
    fields
    {
        field(50000; "DOK MST Order No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
    }
}