codeunit 50010 "DOK Test Utilities"
{
    // procedure CreateGenProdPostingGroup(var GenProductPostingGroup: Record "Gen. Product Posting Group"; NoToUse: Code[20])
    // begin
    //     if not GenProductPostingGroup.Get(NoToUse) then begin
    //         GenProductPostingGroup.Init();
    //         GenProductPostingGroup.Code := NoToUse;
    //         GenProductPostingGroup.Description := NoToUse;
    //         GenProductPostingGroup.Insert()
    //     end;
    // end;

    // procedure CreateResource(var Resource: Record Resource; ResourceNo: Code[20]; VATBusPostingGroup: Code[20])
    procedure CreateResource(var Resource: Record Resource; ResourceNo: Code[20])
    var
        GeneralPostingSetup: Record "General Posting Setup";
        UnitOfMeasure: Record "Unit of Measure";
    begin
        Resource.Init();
        Resource.Validate("No.", ResourceNo);
        Resource.Insert(true);

        UnitOfMeasure.FindFirst();

        GeneralPostingSetup.SetFilter("Gen. Bus. Posting Group", '<>%1', '');
        GeneralPostingSetup.SetFilter("Gen. Prod. Posting Group", '<>%1', '');
        GeneralPostingSetup.FindLast();

        Resource.Validate(Name, ResourceNo);
        Resource.Validate("Base Unit of Measure", UnitOfMeasure.Code);
        Resource.Validate("Direct Unit Cost", Random(100));  // Required field - value is not important.
        Resource.Validate("Unit Price", Random(100));  // Required field - value is not important.
        Resource.Validate("Gen. Prod. Posting Group", GeneralPostingSetup."Gen. Prod. Posting Group");

        Resource.Modify(true);
    end;

    procedure GetRandomString(Length: Integer): Text
    begin
        exit(CopyStr(DelChr(Format(CreateGuid()), '=', '{}-'), 1, Length));
    end;
}