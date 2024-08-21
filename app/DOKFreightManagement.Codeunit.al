codeunit 50006 "DOK Freight Management"
{

    procedure CalculateFreight(SalesHeader: Record "Sales Header"): Decimal
    var
        bypassAPIFunction: Boolean;
        FreightAmount: Decimal;
    begin
        OnBeforeCalculateFreight(bypassAPIFunction, FreightAmount);
        if bypassAPIFunction then
            exit(FreightAmount);
        FreightAmount := CallAPIFreightCalc(SalesHeader);
    end;

    procedure AddFreightLine(SalesHeader: Record "Sales Header"; FreightAmount: Decimal)
    var
        SalesLine: Record "Sales Line";
        Setup: Record "DOK Setup";
    begin
        Setup.Get();
        SalesLine.Init();
        SalesLine.Validate("Document Type", SalesLine."Document Type"::Order);
        SalesLine.Validate("Document No.", SalesHeader."No.");
        SalesLine.Validate("Line No.", 999999);
        SalesLine.Validate("Type", SalesLine."Type"::Resource);
        SalesLine.Validate("No.", Setup."Freight No.");
        SalesLine.Validate(Description, 'Freight');
        SalesLine.Validate(Quantity, 1);
        SalesLine.Validate("Unit Price", FreightAmount);
        SalesLine.Validate("Unit Cost", 0);
        SalesLine."Tax Group Code" := 'VAT';
        if SalesLine.Insert(true) then;
    end;

    local procedure CallAPIFreightCalc(SalesHeader: Record "Sales Header"): Decimal
    var
        SalesLine: Record "Sales Line";
    begin
        SalesLine.SetRange("Document Type", SalesLine."Document Type"::Order);
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetRange("Type", SalesLine."Type"::Item);
        SalesLine.CalcSums(Amount);
        Sleep(500); // Simulate a long running process, API call, etc.
        exit(SalesLine.Amount * 0.1);
    end;

    [IntegrationEvent(false, false)]
    procedure OnBeforeCalculateFreight(var ByPassAPIFunction: Boolean; var FreightAmount: Decimal);
    begin
    end;

}