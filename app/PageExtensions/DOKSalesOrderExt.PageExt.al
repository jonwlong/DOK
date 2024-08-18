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
                    MST: Record "DOK Multiple Ship-to Orders";
                    MSTMgt: Codeunit "DOK MST Management";
                    DOKMultipleShipToCard: Page "DOK Multiple Ship-to List";
                begin
                    MSTMgt.CreateMSTOrders(Rec, 10);
                    MST.SetRange("Order No.", Rec."No.");
                    MST.FindSet();
                    DOKMultipleShipToCard.SetTableView(MST);
                    DOKMultipleShipToCard.Run();
                end;
            }
        }
    }
}