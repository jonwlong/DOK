codeunit 50012 "DOK Sales Get Shipment Subs"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Get Shipment", OnBeforeInsertInvoiceLineFromShipmentLine, '', false, false)]
    local procedure "Sales-Get Shipment_OnBeforeInsertInvoiceLineFromShipmentLine"(SalesShptHeader: Record "Sales Shipment Header"; var SalesShptLine2: Record "Sales Shipment Line"; var SalesHeader: Record "Sales Header"; var PrepmtAmtToDeductRounding: Decimal; TransferLine: Boolean; var IsHandled: Boolean; var SalesShptLine: Record "Sales Shipment Line"; var SalesLine: Record "Sales Line")
    begin
        SalesLine."DOK MST Order No." := SalesShptHeader."DOK MST Order No.";
    end;

}