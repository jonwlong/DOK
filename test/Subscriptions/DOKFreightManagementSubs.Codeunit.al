codeunit 50013 "DOK Freight Management Subs"
{

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"DOK Freight Management", OnBeforeCalculateFreight, '', false, false)]
    local procedure "DOK Freight Management_OnBeforeCalculateFreight"(var ByPassAPIFunction: Boolean; var FreightAmount: Decimal)
    begin
        // ByPassAPIFunction := true;
        // FreightAmount := 1;
    end;


}