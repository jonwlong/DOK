codeunit 50007 "DOK Release Sales Doc Subs"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Release Sales Document", OnBeforeReleaseSalesDoc, '', false, false)]
    local procedure "Release Sales Document_OnBeforeReleaseSalesDoc"(var SalesHeader: Record "Sales Header"; PreviewMode: Boolean; var IsHandled: Boolean; var SkipCheckReleaseRestrictions: Boolean; SkipWhseRequestOperations: Boolean)
    var
        FreightManagement: Codeunit "DOK Freight Management";
        FreightAmount: Decimal;
    begin
        // FreightAmount := FreightManagement.CalculateFreight(SalesHeader);
        // FreightManagement.AddFreightLine(SalesHeader, FreightAmount);
    end;

}