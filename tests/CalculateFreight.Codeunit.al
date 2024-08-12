codeunit 50006 "DOK Freight Management"
{

    procedure CalculateFreight(SalesHeader: Record "Sales Header"): Decimal
    var
        SalesLine: Record "Sales Line";
        bypassAPIFunction: Boolean;
    begin
        SalesLine.SetRange("Document Type", SalesLine."Document Type"::Order);
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetRange("Type", SalesLine."Type"::Item);
        SalesLine.CalcSums(Amount);
        // add an integration event with IsHandled
        OnBeforeCalculateFreight(BypassAPIFunction);
        if not BypassAPIFunction then
            sleep(500); // Simulate a long running process, API call, etc.
        exit(SalesLine.Amount * 0.1);
    end;

    procedure AddFreightLine(SalesHeader: Record "Sales Header"; FreightAmount: Decimal)
    var
        SalesLine: Record "Sales Line";
    begin
        // Add a Resource line to the Sales Order with line no 999999
        SalesLine.INIT;
        SalesLine."Document Type" := SalesLine."Document Type"::Order;
        SalesLine."Document No." := SalesHeader."No.";
        SalesLine."Line No." := 999999;
        SalesLine."Type" := SalesLine."Type"::Resource;
        SalesLine."No." := 'FREIGHT';
        SalesLine."Description" := 'Freight';
        SalesLine."Quantity" := 1;
        SalesLine."Unit Price" := FreightAmount;
        SalesLine."Unit Cost" := 0;
        SalesLine.Insert(true);
    end;

    [IntegrationEvent(false, false)]
    procedure OnBeforeCalculateFreight(var ByPassAPIFunction: Boolean);
    begin
    end;

}