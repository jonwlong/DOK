// write an interface to apply inversion of control over the Release Sales Document codeunit
interface "DOK IReleaseSalesDocumentHandler"
{
    procedure OnBeforeReleaseSalesDoc(var SalesHeader: Record "Sales Header");
    procedure OnBeforeReleaseSalesDoc(var SalesHeader: Record "Sales Header"; PreviewMode: Boolean; IsHandled: Boolean; SkipCheckReleaseRestrictions: Boolean; SkipWhseRequestOperations: Boolean);
}