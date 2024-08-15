codeunit 50008 "DOK Sales Post Subs"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", OnBeforePostSalesDoc, '', false, false)]
    local procedure "Sales-Post_OnBeforePostSalesDoc"(var Sender: Codeunit "Sales-Post"; var SalesHeader: Record "Sales Header"; CommitIsSuppressed: Boolean; PreviewMode: Boolean; var HideProgressWindow: Boolean; var IsHandled: Boolean; var CalledBy: Integer)
    begin
        if SalesHeader.HasMSTOrders() then // if the order has MST orders, don't post this order
            Error('This is an MST Order. Please use the Post MST action for this order.');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", OnAfterPostSalesDoc, '', false, false)]
    local procedure "Sales-Post_OnAfterPostSalesDoc"(var SalesHeader: Record "Sales Header"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; SalesShptHdrNo: Code[20]; RetRcpHdrNo: Code[20]; SalesInvHdrNo: Code[20]; SalesCrMemoHdrNo: Code[20]; CommitIsSuppressed: Boolean; InvtPickPutaway: Boolean; var CustLedgerEntry: Record "Cust. Ledger Entry"; WhseShip: Boolean; WhseReceiv: Boolean; PreviewMode: Boolean)
    var
        ShipLine: Record "Sales Shipment Line";
    begin
        if SalesHeader.IsMSTOrder() then begin
            ShipLine.SetRange("Document No.", SalesShptHdrNo);
            if ShipLine.FindSet() then
                repeat
                    ShipLine."DOK MST Order No." := SalesHeader."DOK MST Order No.";
                    ShipLine.Modify(true);
                until ShipLine.Next() = 0;
        end;
    end;


}