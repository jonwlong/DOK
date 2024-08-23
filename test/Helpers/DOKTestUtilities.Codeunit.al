codeunit 50010 "DOK Test Utilities"
{
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

    procedure GetLastPostedSalesInvoice() LastPostedSalesInvoice: Record "Sales Invoice Header"
    var
        NoSeriesLine: Record "No. Series Line";
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
    begin
        SalesReceivablesSetup.Get();
        NoSeriesLine.Get(SalesReceivablesSetup."Posted Invoice Nos.", 10000);
        LastPostedSalesInvoice.Get(NoSeriesLine."Last No. Used");
    end;

    procedure CreateNoSeries(NoSeriesCode: Code[20])
    var
        NoSeries: Record "No. Series";
    begin
        NoSeries.Init();
        NoSeries.Code := NoSeriesCode;
        NoSeries."Default Nos." := true;
        NoSeries.Insert(true);
    end;

    procedure CreateNoSeriesLine(NoSeriesCode: Code[20]; StartingNo: Code[20]; EndingNo: Code[20]) NoSeriesLine: Record "No. Series Line"
    var
    begin
        NoSeriesLine.Init();
        NoSeriesLine."Series Code" := NoSeriesCode;
        NoSeriesLine."Starting No." := StartingNo;
        NoSeriesLine."Ending No." := EndingNo;
        NoSeriesLine."Starting Date" := Today;
        NoSeriesLine."Increment-by No." := 1;
        NoSeriesLine.Insert(true);
        exit(NoSeriesLine);
    end;

}