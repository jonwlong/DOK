codeunit 50009 "DOK MST Management"
{
    procedure CreateMockMSTEntries(SalesHeaderNo: Code[20]; NumberOfMSTEntries: Integer);
    var
        MSTEntries: Record "DOK Multiple Ship-to Entries";
        SalesLine: Record "Sales Line";
        Util: Codeunit "DOK Utilities";
        NumberOfIterations: Integer;
    begin
        // populate MSTEntries with random address data
        SalesLine.SetRange("Document Type", SalesLine."Document Type"::Order);
        SalesLine.SetRange("Document No.", SalesHeaderNo);
        SalesLine.SetRange(Type, SalesLine.Type::Item);
        SalesLine.FindSet();
        repeat
            NumberOfIterations := 0;
            repeat
                Clear(MSTEntries);
                MSTEntries.Init();
                MSTEntries."Order No." := SalesHeaderNo;
                MSTEntries."Line No." := SalesLine."Line No.";
                MSTEntries."Ship-to Name" := Util.GetRandomText30();
                MSTEntries."Ship-to Address" := Util.GetRandomText30();
                MSTEntries."Ship-to City" := Util.GetRandomText30();
                MSTEntries."Ship-to State" := Util.GetRandomCode10();
                MSTEntries."Ship-to Post Code" := '84454';
                MSTEntries."Ship-to Country" := 'US';
                MSTEntries."Ship-to Phone No." := '333.333.3333';
                MSTEntries."Ship-to Email" := 'bob@bob.com';
                MSTEntries.Validate(Quantity, Random(100));
                MSTEntries.Insert(true);
                NumberOfIterations += 1;
            until NumberOfIterations = NumberOfMSTEntries;
        until SalesLine.Next() = 0;
    end;

}