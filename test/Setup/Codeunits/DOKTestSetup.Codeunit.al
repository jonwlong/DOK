codeunit 50017 "DOK Test Setup"
{

    procedure CreateFreightResource(): Code[20]
    var
        Resource: Record Resource;
        Setup: Record "DOK Setup";
        FreightCode: Code[20];
    begin
        FreightCode := TestHelperUtilities.GetRandomCode20();
        if not Setup.Get() then begin
            Setup.Init();
            Setup."Freight No." := FreightCode;
            Setup.Insert();
        end else begin
            Setup."Freight No." := FreightCode;
            Setup.Modify()
        end;
        CreateResource(FreightCode);
    end;

    local procedure CreateResource(ResourceNo: Code[20])
    var
        Resource: Record Resource;
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

    procedure CreateNoSeries() NoSeriesCode: Code[20]
    var
        NoSeries: Record "No. Series";
    begin
        NoSeriesCode := TestHelperUtilities.GetRandomCode20();
        NoSeries.Init();
        NoSeries.Code := NoSeriesCode;
        NoSeries."Default Nos." := true;
        NoSeries.Insert(true);
        CreateNoSeriesLine(NoSeriesCode, '10000', '99999');
    end;

    local procedure CreateNoSeriesLine(NoSeriesCode: Code[20]; StartingNo: Code[20]; EndingNo: Code[20]) NoSeriesLine: Record "No. Series Line"
    var
    begin
        NoSeriesLine.Init();
        NoSeriesLine."Series Code" := NoSeriesCode;
        NoSeriesLine."Starting No." := StartingNo;
        NoSeriesLine."Ending No." := EndingNo;
        NoSeriesLine."Increment-by No." := 1;
        NoSeriesLine.Insert(true);
        exit(NoSeriesLine);
    end;

    procedure SetupSalesAndRcvbls()
    var
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
        SetupSingletonVars: Codeunit "DOK Setup Singleton Vars";
        MSTNoSeriesCode: Code[20];
    begin
        MSTNoSeriesCode := SetupSingletonVars.GetMSTNoSeriesCode();
        SetupSingletonVars.SetMSTNoSeriesCode(MSTNoSeriesCode);
        SetupSingletonVars.GetMSTNoSeriesCode();
        SalesReceivablesSetup.Get();
        SalesReceivablesSetup."DOK MST Entries No." := MSTNoSeriesCode;
        SalesReceivablesSetup.Modify();
    end;

    var
        TestHelperUtilities: Codeunit "DOK Test Helper Utilities";

}