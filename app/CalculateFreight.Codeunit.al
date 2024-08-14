codeunit 50006 "DOK Freight Management"
{

    procedure CalculateFreight(SalesHeader: Record "Sales Header"): Decimal
    var
        bypassAPIFunction: Boolean;
        FreightAmount: Decimal;
    begin
        OnBeforeCalculateFreight(BypassAPIFunction, FreightAmount);
        if BypassAPIFunction then
            exit(FreightAmount);
        FreightAmount := CallAPIFreightCalc(SalesHeader);
    end;

    procedure AddFreightLine(SalesHeader: Record "Sales Header"; FreightAmount: Decimal)
    var
        SalesLine: Record "Sales Line";
        Setup: Record "DOK Setup";
    begin
        // Add a Resource line to the Sales Order with line no 999999
        Setup.Get();
        SalesLine.INIT;
        SalesLine.Validate("Document Type", SalesLine."Document Type"::Order);
        SalesLine.Validate("Document No.", SalesHeader."No.");
        SalesLine.Validate("Line No.", 999999);
        SalesLine.Validate("Type", SalesLine."Type"::Resource);
        SalesLine.Validate("No.", Setup."Freight No.");
        SalesLine.Validate("Description", 'Freight');
        SalesLine.Validate("Quantity", 1);
        SalesLine.Validate("Unit Price", FreightAmount);
        SalesLine.Validate("Unit Cost", 0);
        SalesLine."Tax Group Code" := 'VAT';
        SalesLine.Insert(true);
    end;

    local procedure CallAPIFreightCalc(SalesHeader: Record "Sales Header"): Decimal
    var
        SalesLine: Record "Sales Line";
        bypassAPIFunction: Boolean;
    begin
        SalesLine.SetRange("Document Type", SalesLine."Document Type"::Order);
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetRange("Type", SalesLine."Type"::Item);
        SalesLine.CalcSums(Amount);
        sleep(500); // Simulate a long running process, API call, etc.
        exit(SalesLine.Amount * 0.1);
    end;

    [IntegrationEvent(false, false)]
    procedure OnBeforeCalculateFreight(var ByPassAPIFunction: Boolean; var FreightAmount: Decimal);
    begin
    end;

}