tableextension 50002 "DOK Sales Invoice Header Ext" extends "Sales Invoice Header"
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
        key(DOKSalesInvoiceHeader; "No.")
        {
        }
    }
}