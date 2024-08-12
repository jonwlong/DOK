codeunit 50005 "Test Validate Credit Limit"
{

    Subtype = Test;

    [Test]
    procedure "Given Some State_When Some Action_Then Expected Output"()
    var
        Customer: Record Customer;
        CustPage: TestPage "Customer Card";
    begin
        Customer.FindFirst();
        CustPage.OpenEdit();
        CustPage.GoToRecord(Customer);
        CustPage."Credit Limit (LCY)".SetValue(1000);
        CustPage.Next();
        // [GIVEN] Given Some State 
        // [WHEN] When Some Action 
        // [THEN] Then Expected Output 
    end;

}