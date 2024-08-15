codeunit 50011 "DOK Batch Post MST SalesOrders"
{
    // batch post MST Sales Orders
    procedure PostShipMSTSalesOrders(MSTOrderNo: Text[20])
    var
        SalesHeader: Record "Sales Header";
        BatchPostReport: Report "Batch Post Sales Orders";
    begin
        SalesHeader.SetRange("DOK MST Order No.", MSTOrderNo);
        SalesHeader.FindSet();
        BatchPostReport.SetTableView(SalesHeader);
        Codeunit.Run(Codeunit::"Sales Batch Post Mgt.", SalesHeader);
    end;

    procedure CreateInvoiceWithCombinedMSTShipments(MSTOrderNo: Text[20])
    var
        SalesHeader: Record "Sales Header";
        SalesShipLine: Record "Sales Shipment Line";
        SalesGetShipment: Codeunit "Sales-Get Shipment";
    begin
        SalesShipLine.SetRange("DOK MST Order No.", MSTOrderNo);
        if not SalesShipLine.FindSet() then
            Error('No Shipments found for MST Order No. %1', MSTOrderNo);
        SalesHeader.Init();
        SalesHeader.Validate("Document Type", SalesHeader."Document Type"::Invoice);
        SalesHeader.Validate("Sell-to Customer No.", SalesShipLine."Sell-to Customer No.");
        SalesHeader.Validate("DOK MST Order No.", MSTOrderNo);
        SalesHeader.Insert(true);
        SalesGetShipment.SetSalesHeader(SalesHeader);
        SalesGetShipment.CreateInvLines(SalesShipLine);
    end;


}