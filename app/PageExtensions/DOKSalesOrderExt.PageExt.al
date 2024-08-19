pageextension 50000 "DOK Sales Order Ext" extends "Sales Order"
{
    // add acction to Create Multiple Ship-to Orders
    actions
    {
        addafter("F&unctions")
        {
            action("Post & Ship MST Invoice")
            {
                ApplicationArea = All;
                Caption = 'Post & Ship MST Invoice';
                Promoted = true;
                ToolTip = 'Post & Ship MST Invoice';
                PromotedCategory = Process;
                Image = Document;
                trigger OnAction()
                var
                    MSTMgt: Codeunit "DOK MST Management";
                begin
                    MSTMgt.CreateMockMSTOrders(Rec."No.", 10);
                    MSTMgt.CreateOrdersFromMSTEntries(Rec);
                    MSTMgt.PostShipOrdersCreatedFromMST(Rec);
                    MSTMgt.CreateInvoiceWithCombinedMSTShipments(Rec."No.");
                end;
            }
        }
    }
}