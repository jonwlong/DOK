codeunit 50008 "DOK Post Sales Subs"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", OnBeforePostSalesDoc, '', false, false)]
    local procedure "Sales-Post_OnBeforePostSalesDoc"(var Sender: Codeunit "Sales-Post"; var SalesHeader: Record "Sales Header"; CommitIsSuppressed: Boolean; PreviewMode: Boolean; var HideProgressWindow: Boolean; var IsHandled: Boolean; var CalledBy: Integer)
    var
        MSTManagement: Codeunit "DOK MST Management";
    begin
        if SalesHeader.IsMSTOrder then begin
            IsHandled := true;
            MSTManagement.CreateOrdersFromMST(SalesHeader);
            MSTManagement.PostOrdersCreatedFromMST(SalesHeader);
        end;
    end;

}