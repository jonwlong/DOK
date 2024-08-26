codeunit 50010 "DOK Test Helper Utilities"
{

    procedure GetLastPostedSalesInvoice() LastPostedSalesInvoice: Record "Sales Invoice Header"
    var
        NoSeriesLine: Record "No. Series Line";
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
    begin
        SalesReceivablesSetup.Get();
        NoSeriesLine.Get(SalesReceivablesSetup."Posted Invoice Nos.", 10000);
        LastPostedSalesInvoice.Get(NoSeriesLine."Last No. Used");
    end;

    procedure GetRandomString(Length: Integer): Text
    begin
        exit(CopyStr(DelChr(Format(CreateGuid()), '=', '{}-'), 1, Length));
    end;

    procedure GetRandomText20(): Text[20]
    begin
        exit(CopyStr(DelChr(Format(CreateGuid()), '=', '{}-'), 1, 20));
    end;

    procedure GetRandomText30(): Text[30]
    begin
        exit(CopyStr(DelChr(Format(CreateGuid()), '=', '{}-'), 1, 30));
    end;

    procedure GetRandomCode10(): Code[10]
    begin
        exit(CopyStr(DelChr(Format(CreateGuid()), '=', '{}-'), 1, 10));
    end;

    procedure GetRandomCode20(): Code[20]
    begin
        exit(CopyStr(DelChr(Format(CreateGuid()), '=', '{}-'), 1, 20));
    end;

    procedure GetRandomCode30(): Code[30]
    begin
        exit(CopyStr(DelChr(Format(CreateGuid()), '=', '{}-'), 1, 30));
    end;

}