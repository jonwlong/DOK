codeunit 50015 "DOK Sales Header Subs"
{

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", OnValidateSellToCustomerNoOnAfterTestStatusOpen, '', false, false)]
    local procedure "Sales Header_OnValidateSellToCustomerNoOnAfterTestStatusOpen"(var SalesHeader: Record "Sales Header"; xSalesHeader: Record "Sales Header"; var IsHandled: Boolean)
    var
        SalesHeaderInsertLog: Record "DOK Sales Header Insert Log";
    begin
        SalesHeaderInsertLog.Init();
        SalesHeaderInsertLog.Insert();
    end;

}