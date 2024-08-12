table 50000 "DOK Multiple Ship-to Orders"
{
    // create a table with address fields with key field Order No., Line No.
    DataClassification = ToBeClassified;
    fields
    {
        field(1; "Entry No."; BigInteger)
        {
            DataClassification = ToBeClassified;
            Editable = false;
            AutoIncrement = true;
        }
        field(2; "Order No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(3; "Line No."; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(4; "Ship-to Name"; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(5; "Ship-to Address"; Text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(6; "Ship-to City"; Text[30])
        {
            DataClassification = ToBeClassified;
        }
        field(7; "Ship-to State"; Code[10])
        {
            DataClassification = ToBeClassified;
        }
        field(8; "Ship-to Post Code"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(9; "Ship-to Country"; Code[10])
        {
            DataClassification = ToBeClassified;
        }
        // phone
        field(10; "Ship-to Phone No."; Code[30])
        {
            DataClassification = ToBeClassified;
        }
        // email
        field(11; "Ship-to Email"; Code[80])
        {
            DataClassification = ToBeClassified;
        }
        // quantity
        field(12; "Quantity"; Decimal)
        {
            DataClassification = ToBeClassified;
            trigger OnValidate()
            var
                SalesLine: Record "Sales Line";
                MST: Record "DOK Multiple Ship-to Orders";
            begin
                MST.SetRange("Order No.", Rec."Order No.");
                MST.SetRange("Line No.", Rec."Line No.");
                MST.SetFilter("Entry No.", '<>%1', Rec."Entry No.");
                MST.CalcSums("Quantity");
                SalesLine.Get(SalesLine."Document Type"::Order, Rec."Order No.", Rec."Line No.");
                SalesLine.Validate("Quantity", MST.Quantity + Rec."Quantity");
                SalesLine.Modify(true);
            end;
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
}