permissionset 50000 GeneratedPermission
{
    Assignable = true;
    Permissions = tabledata "DOK Multiple Ship-to Orders"=RIMD,
        tabledata "DOK Setup"=RIMD,
        table "DOK Multiple Ship-to Orders"=X,
        table "DOK Setup"=X,
        codeunit "DOK Batch Post MST SalesOrders"=X,
        codeunit "DOK Freight Management"=X,
        codeunit "DOK Freight Management Subs"=X,
        codeunit "DOK MST Management"=X,
        codeunit "DOK Release Sales Doc Subs"=X,
        codeunit "DOK Sales Get Shipment Subs"=X,
        codeunit "DOK Sales Post Subs"=X,
        codeunit "DOK Test Fixtures Sales"=X,
        codeunit "DOK Test Helpers"=X,
        codeunit "DOK Test Sales Orders"=X,
        codeunit "DOK Test Tinker"=X,
        codeunit "DOK Test Utilities"=X;
}