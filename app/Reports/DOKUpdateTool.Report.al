report 50000 "DOK Update Tool"
{
    UsageCategory = Administration;
    ApplicationArea = All;
    ProcessingOnly = true;
    UseRequestPage = false;

    trigger OnInitReport()
    var
        selection: Integer;
    begin
        selection := Dialog.StrMenu('DO NOTHING, UpdateCode', 1, 'Choose an option to run');
        case selection of
            1:
                exit;
            2:
                if Confirm('Are you sure you want to run the update Freight Resource and MST No Series Function?', true) then
                    UpdateCode();

        end;
    end;

    local procedure UpdateCode()
    var
        Resource: Record Resource;
        Setup: Record "DOK Setup";
    begin

        if not Setup.Get() then begin
            Setup.Init();
            Setup."Freight No." := 'FREIGHT';
            Setup.Insert();
        end else begin
            Setup."Freight No." := 'FREIGHT';
            Setup.Modify()
        end;
        CreateResource(Resource, 'FREIGHT');
        WorkDate(Today);
        CreateNoSeries('MST');
        CreateNoSeriesLine('MST', '0000000001', '9999999999');

    end;

    procedure CreateResource(var Resource: Record Resource; ResourceNo: Code[20])
    var
        GeneralPostingSetup: Record "General Posting Setup";
        UnitOfMeasure: Record "Unit of Measure";
    begin
        Resource.Init();
        Resource.Validate("No.", ResourceNo);
        if not Resource.Insert(true) then
            exit;

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

    procedure CreateNoSeries(NoSeriesCode: Code[20])
    var
        NoSeries: Record "No. Series";
    begin
        NoSeries.Init();
        NoSeries.Code := NoSeriesCode;
        NoSeries."Default Nos." := true;
        if NoSeries.Insert(true) then;
    end;

    procedure CreateNoSeriesLine(NoSeriesCode: Code[20]; StartingNo: Code[20]; EndingNo: Code[20])
    var
        NoSeriesLine: Record "No. Series Line";
    begin
        NoSeriesLine.Init();
        NoSeriesLine."Series Code" := NoSeriesCode;
        NoSeriesLine."Starting No." := StartingNo;
        NoSeriesLine."Ending No." := EndingNo;
        NoSeriesLine."Starting Date" := Today;
        NoSeriesLine."Increment-by No." := 1;
        if NoSeriesLine.Insert(true) then;
    end;

}