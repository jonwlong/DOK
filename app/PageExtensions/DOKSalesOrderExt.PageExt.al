pageextension 50000 "DOK Sales Order Ext" extends "Sales Order"
{
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
                    MSTMgt.CreateMockMSTEntries(Rec."No.", 10);
                    MSTMgt.CreateOrdersFromMSTEntries(Rec);
                    MSTMgt.PostShipOrdersCreatedFromMST(Rec);
                    MSTMgt.CreateInvoiceWithCombinedMSTShipments(Rec."No.");
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