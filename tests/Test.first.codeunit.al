codeunit 50000 "Test First"
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
    procedure "Test_AllItemsHaveAUnitPrice"()
    var
        Item: Record Item;
    begin
        Item.FindSet();
        repeat
            if Item."Unit Price" = 0 then
                Error('Item %1 has no unit price', Item.Description);
        until Item.NEXT = 0;
    end;

    [Test]
    procedure "Test_CountOfItemsWithZeroUnitPrice"()
    var
        Item: Record Item;
        CountOfItemsWithZeroPrice: Integer;
    begin
        Item.FindSet();
        repeat
            if Item."Unit Price" = 0 then
                CountOfItemsWithZeroPrice += 1;
        until Item.NEXT = 0;
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

}
