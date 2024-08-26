table 50000 "DOK Multiple Ship-to Entries"
{
    // create a table with address fields with key field Order No., Line No.
    DataClassification = AccountData;
    fields
    {
        field(1; "Entry No."; Code[20])
        {
            DataClassification = AccountData;
            Editable = false;
        }
        field(2; "Order No."; Code[20])
        {
            DataClassification = AccountData;
        }
        field(3; "Line No."; Integer)
        {
            DataClassification = AccountData;
        }
        field(4; "Ship-to Name"; Text[50])
        {
            DataClassification = AccountData;
        }
        field(5; "Ship-to Address"; Text[250])
        {
            DataClassification = AccountData;
        }
        field(6; "Ship-to City"; Text[30])
        {
            DataClassification = AccountData;
        }
        field(7; "Ship-to State"; Code[10])
        {
            DataClassification = AccountData;
        }
        field(8; "Ship-to Post Code"; Code[20])
        {
            DataClassification = AccountData;
        }
        field(9; "Ship-to Country"; Code[10])
        {
            DataClassification = AccountData;
        }
        // phone
        field(10; "Ship-to Phone No."; Code[30])
        {
            DataClassification = AccountData;
        }
        // email
        field(11; "Ship-to Email"; Code[80])
        {
            DataClassification = AccountData;
        }
        // quantity
        field(12; Quantity; Decimal)
        {
            DataClassification = AccountData;
        }

    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(Order; "Order No.", "Line No.")
        {
            Clustered = false;
        }
    }

    trigger OnInsert()
    var
        SalesAndReceivablesSetup: Record "Sales & Receivables Setup";
        NoSeries: Codeunit "No. series";
    begin
        SalesAndReceivablesSetup.Get();
        Rec."Entry No." := NoSeries.GetNextNo(SalesAndReceivablesSetup."DOK MST Entries No.", 0D);
    end;

}