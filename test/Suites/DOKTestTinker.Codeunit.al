codeunit 50000 "DOK Test Tinker"
{
    Subtype = Test;

    [Test]
    procedure Test_First()
    begin
        // [GIVEN] Given Some State 
        // [WHEN] When Some Action 
        // [THEN] Then Expected Output 
    end;

    [Test]
    procedure Test_AllItemsHaveAUnitPrice()
    var
        Item: Record Item;
    begin
        Item.FindSet();
        repeat
            TestHelpers.AssertTrue(Item."Unit Price" > 0, 'Item ' + Format(Item."No.") + ' has no unit price');
        until Item.Next() = 0;
    end;

    [Test]
    procedure Test_CountOfItemsWithZeroUnitPrice()
    var
        Item: Record Item;
        CountOfItemsWithZeroPrice: Integer;
    begin
        Item.FindSet();
        repeat
            if Item."Unit Price" = 0 then
                CountOfItemsWithZeroPrice += 1;
        until Item.Next() = 0;
        if CountOfItemsWithZeroPrice > 0 then
            Error('%1 items of %2 have no unit price', CountOfItemsWithZeroPrice, Item.Count);
    end;

    [Test]
    procedure Test_RandomIntOutPut()
    var
        tb: TextBuilder;
        i: Integer;
    begin
        for i := 1 to 10 do
            tb.AppendLine(Format(Random(100)));
        Error(tb.ToText());
    end;

    [Test]
    procedure Test_Wild1()
    var
        boo: Boolean;
    begin
        TestHelpers.AssertTrue(boo, 'This is a test with %1', 1);
    end;

    [Test]
    procedure Test_Wild2()
    var
        boo: Boolean;
    begin
        TestHelpers.AssertTrue(boo, 'This is a test with %1 and %2', '1', '2');
    end;

    [Test]
    procedure Test_Wild3()
    var
        boo: Boolean;
    begin
        TestHelpers.AssertTrue(boo, 'This is a test with %1 and %2 and %3', '1', '2', '3');
    end;

    [Test]
    procedure Test_Wild4()
    var
        boo: Boolean;
    begin
        TestHelpers.AssertTrue(boo, 'This is a test with %1 and %2 and %3 and %4', '1', '2', '3', '4');
    end;

    [Test]
    procedure Test_Wild5()
    var
        boo: Boolean;
    begin
        TestHelpers.AssertTrue(boo, 'This is a test with %1 and %2 and %3 and %4 and %5', '1', '2', '3', '4', '5');
    end;

    [Test]
    procedure Test_TestPage()
    var
        Customer: Record Customer;
        CustomerPage: TestPage "Customer Card";
    begin
        Customer.FindFirst();
        CustomerPage.OpenEdit();
        CustomerPage.GoToRecord(Customer);
        CustomerPage."Credit Limit (LCY)".SetValue(0);
        CustomerPage.Next();

        // [GIVEN] Given Some State 
        // [WHEN] When Some Action 
        // [THEN] Then Expected Output 
    end;

    var
        TestHelpers: Codeunit "DOK Test Helpers";

}
