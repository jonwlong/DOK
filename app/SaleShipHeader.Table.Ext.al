tableextension 50003 "DOK Sales Ship Header Ext" extends "Sales Shipment Header"
{
    fields
    {
        // MSTOrderNo
        field(50000; "DOK MST Order No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
    }
}