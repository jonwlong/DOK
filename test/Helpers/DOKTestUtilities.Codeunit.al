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

}