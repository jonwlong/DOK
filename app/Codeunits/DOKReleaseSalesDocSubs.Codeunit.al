codeunit 50007 "DOK Release Sales Doc Subs"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Release Sales Document", OnBeforeReleaseSalesDoc, '', false, false)]
    local procedure "Release Sales Document_OnBeforeReleaseSalesDoc"(var SalesHeader: Record "Sales Header"; PreviewMode: Boolean; var IsHandled: Boolean; var SkipCheckReleaseRestrictions: Boolean; SkipWhseRequestOperations: Boolean)
    var
        SalesLine: Record "Sales Line";
    begin
        if SalesHeader."Document Type" = SalesHeader."Document Type"::Order then
            SalesHeader.AddFreightLine(SalesHeader.CalculateFreight());
        SalesLine.SetRange("Document Type", SalesLine."Document Type"::Order);
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetRange("Type", SalesLine."Type"::Item);
        if SalesLine.FindSet() then
            repeat
                if SalesLine."DOK Original Order Qty." = 0 then
                    SalesLine."DOK Original Order Qty." := SalesLine.Quantity;
                SalesLine.Modify();
            until SalesLine.Next() = 0;
    end;

}