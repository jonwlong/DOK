codeunit 50018 "DOKMockReleaseSalesDoc" implements "DOK IReleaseSalesDocumentHandler"
{
    // This is a mock implementation of the Release Sales Document codeunit
    // It is used to test the OnBeforeReleaseSalesDoc procedure in the DOK Release Sales Doc Subs codeunit
    procedure OnBeforeReleaseSalesDoc(var SalesHeader: Record "Sales Header");
    var
    begin
        FreightAmount := 1;
        // Add your mock implementation here
    end;

    procedure OnBeforeReleaseSalesDoc(var SalesHeader: Record "Sales Header"; PreviewMode: Boolean; IsHandled: Boolean; SkipCheckReleaseRestrictions: Boolean; SkipWhseRequestOperations: Boolean);
    begin
        // Add your mock implementation here
    end;

    procedure GetFreightAmount(): Decimal;
    begin
        exit(FreightAmount);
    end;

    var
        FreightAmount: Decimal;


}