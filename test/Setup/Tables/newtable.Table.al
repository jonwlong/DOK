table 50002 newtable
{

    fields
    {
        field(1; "Entry No."; BigInteger)
        {
            DataClassification = AccountData;
            Editable = false;
            AutoIncrement = true;
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }

}
