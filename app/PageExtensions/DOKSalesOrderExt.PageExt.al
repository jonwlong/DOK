pageextension 50000 "DOK Sales Order Ext" extends "Sales Order"
{
    actions
    {
        addafter("F&unctions")
        {
            action("Generat MST Invoice")
            {
                ApplicationArea = All;
                Caption = 'Generate MST Invoice';
                Promoted = true;
                ToolTip = 'Generates MST Invoice';
                PromotedCategory = Process;
                Image = Document;
                trigger OnAction()
                var
                    SalesInvoiceHeader: Record "Sales Header";
                    MSTMgt: Codeunit "DOK MST Management";
                    SalesInvoicePage: Page "Sales Invoice";
                begin
                    MSTMgt.CreateMockMSTEntries(Rec."No.", 10);
                    MSTMgt.CreateOrdersFromMSTEntries(Rec);
                    MSTMgt.PostShipOrdersCreatedFromMST(Rec);
                    MSTMgt.CreateInvoiceWithCombinedMSTShipments(Rec."No.");
                    SalesInvoiceHeader.SetRange("DOK MST Order No.", Rec."No.");
                    SalesInvoiceHeader.SetRange("Document Type", SalesInvoiceHeader."Document Type"::Invoice);
                    if SalesInvoiceHeader.FindSet() then begin
                        SalesInvoicePage.SetRecord(SalesInvoiceHeader);
                        SalesInvoicePage.Run();
                    end;
                end;
            }
            action("Show MST Entries")
            {
                ApplicationArea = All;
                Caption = 'Show MST Entries';
                Promoted = true;
                ToolTip = 'Opens MST Entries Page';
                PromotedCategory = Process;
                Image = Document;
                trigger OnAction()
                var
                    MSTEntries: Record "DOK Multiple Ship-to Entries";
                    MSTPage: Page "DOK Multiple Ship-to List";
                begin
                    MSTEntries.SetRange("Order No.", Rec."No.");
                    if MSTEntries.FindSet() then begin
                        MSTPage.SetRecord(MSTEntries);
                        MSTPage.RunModal();
                    end;
                end;
            }
        }
    }
}