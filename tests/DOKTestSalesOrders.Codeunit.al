codeunit 50001 "DOK Test Sales Orders"
{
    Subtype = Test;

    [Test]
    procedure Test_PostSalesOrder()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SalesPost: Codeunit "Sales-Post";
        PostedWithoutErrors: Boolean;
    begin

        // [GIVEN] a Sales Order with 1 Sales Line
        SalesHeader.Init();
        SalesHeader.Validate("Document Type", SalesHeader."Document Type"::Order);
        SalesHeader.Validate("Sell-to Customer No.", '10000');
        SalesHeader.Insert(true);
        SalesLine.Init();
        SalesLine.Validate("Document Type", SalesHeader."Document Type");
        SalesLine.Validate("Document No.", SalesHeader."No.");
        SalesLine.Validate("Line No.", 10000);
        SalesLine.Validate("Type", SalesLine.Type::Item);
        SalesLine.Validate("No.", '1896-S');
        SalesLine.Validate("Quantity", 1);
        SalesLine.Insert(true);

        // [WHEN] we post the Sales Order
        Commit();
        PostedWithoutErrors := SalesPost.Run(SalesHeader);

        // [THEN] the Sales Order is posted without errors
        TestHelpers.AssertTrue(PostedWithoutErrors, 'Sales Order was not posted without error. %1', GetLastErrorText());

    end;

    var
        TestHelpers: Codeunit "DOK Test Helpers";
}