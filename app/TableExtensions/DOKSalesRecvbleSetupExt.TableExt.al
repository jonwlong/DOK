tableextension 50005 "DOK Sales Recvble Setup Ext" extends "Sales & Receivables Setup"
{
    fields
    {
        field(50000; "DOK MST Entries No."; Code[20])
        {
            DataClassification = SystemMetadata;
        }
    }
}