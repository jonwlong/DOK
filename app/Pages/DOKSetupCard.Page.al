page 50001 "DOK Setup Card"
{
    ApplicationArea = All;
    UsageCategory = Administration;
    Caption = 'DOK Setup';
    PageType = Card;
    SourceTable = "DOK Setup";
    Editable = true;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

                field("Freight No."; Rec."Freight No.")
                {
                    ToolTip = 'Specifies the value of the Freight No. field.', Comment = '%';
                }
            }
        }
    }
}
