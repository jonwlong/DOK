table 50004 "DOK SalesHdrInsertLog RunCount"
{

    fields
    {
        field(1; "Run Count"; BigInteger)
        {
            DataClassification = AccountData;
            Editable = false;
            AutoIncrement = true;
        }
    }

    keys
    {
        key(PK; "Run Count")
        {
            Clustered = true;
        }
    }

}