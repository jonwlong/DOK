page 50000 "DOK Multiple Ship-to List"
{
    PageType = List;
    SourceTable = "DOK Multiple Ship-to Entries";
    ApplicationArea = All;
    UsageCategory = Lists;
    Caption = 'DOK Multiple Ship to Orders';
    layout
    {
        area(Content)
        {
            repeater(Entries)
            {
                field("Order No."; Rec."Order No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the order number.';
                }
                field("Line No."; Rec."Line No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the line number.';
                }
                field("Ship-to Name"; Rec."Ship-to Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the ship-to address.';
                }
                field("Ship-to Address"; Rec."Ship-to Address")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the address of the ship-to location.';
                }
                field("Ship-to City"; Rec."Ship-to City")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the city of the ship-to location.';
                }
                field("Ship-to State"; Rec."Ship-to State")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the state of the ship-to location.';
                }
                field("Ship-to Post Code"; Rec."Ship-to Post Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the postal code of the ship-to location.';
                }
                field("Ship-to Country"; Rec."Ship-to Country")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the country of the ship-to location.';
                }
                field("Ship-to Phone No."; Rec."Ship-to Phone No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the phone number of the ship-to location.';
                }
                field("Ship-to Email"; Rec."Ship-to Email")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the email address of the ship-to location.';
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the quantity of items to be shipped.';
                }
            }
        }
    }
}