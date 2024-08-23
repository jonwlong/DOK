table 50003 "DOK Sales Header Insert Log"
{

    fields
    {
        field(1; "No. of Sales Headers Created"; BigInteger)
        {
            DataClassification = AccountData;
            Editable = false;
            AutoIncrement = true;
        }
    }

    keys
    {
        key(PK; "No. of Sales Headers Created")
        {
            Clustered = true;
        }
    }

}