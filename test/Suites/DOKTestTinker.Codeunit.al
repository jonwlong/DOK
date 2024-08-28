codeunit 50000 "DOK Test Tinker"
{
    Subtype = Test;

    local procedure Initialize()
    begin

        if Initialized then
            exit;
        Initialized := true;

        TestSetup.CreateFreightResource();
        TestSetupSingletonVars.SetMSTNoSeriesCode(TestSetup.CreateNoSeries());
        TestSetup.SetupSalesAndRcvbls();

    end;

    [TEST]
    procedure Test_AutoIncrementMetaDataDoesNotGetRolledBack()
    var
        newtable: Record "NewTable";
    begin
        // [GIVEN] a new table with a single field (autoincrement = true) that never had a record inserterd into it
        newtable.init();

        // [WHEN] we insert a record into it
        newtable.insert();

        // [THEN] the autoincrement field should be 1
        TestHelpers.AssertTrue(newtable."Entry No." = 1, 'The autoincrement field should be 1 but it''s %1', newtable."Entry No.");

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
    procedure Test_TestCustomerPage()
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

    [TEST]
    procedure Test_SalesInvoicePage()
    var
        SalesInvoiceHeader: Record "Sales Header";
        SalesInvoicePage: TestPage "Sales Invoice";
    begin
        SalesInvoiceHeader.SetRange("Document Type", SalesInvoiceHeader."Document Type"::Invoice);
        SalesInvoiceHeader.FindFirst();
        SalesInvoicePage.OpenView();
        SalesInvoicePage.GoToRecord(SalesInvoiceHeader);
        // [GIVEN] 

        // [WHEN] 

        // [THEN] 

    end;


    [TEST]
    procedure Test_NumberSequenceSpeed()
    var
        i: Integer;
    begin
        repeat
            i += 1000;
            if not NumberSequence.Exists('testns') then
                NumberSequence.Insert('testns', 1, 1);
        until i = 1000;
    end;

    [TEST]
    procedure Test_AutoIncrementSpeed()
    var
        newtable: Record "NewTable";
        i: Integer;
    begin
        repeat
            i += 1;
            Clear(newtable);
            newtable.init();
            newtable.insert();
        until i = 1000;

    end;

    [TransactionModel(TransactionModel::AutoRollback)]
    [TEST]
    procedure Test_TransactionModelRollbackInteger()
    var
        SingleTon: Codeunit "DOK Setup Singleton Vars";
        i: Integer;
    begin

        // [SETUP]
        SingleTon.SetSingletonInteger(1);

        // [WHEN] We call the GetSomeInteger function
        i := SingleTon.GetSingletonInteger();

        // [THEN] the variable should be 1
        TestHelpers.AssertTrue(i = 1, 'The variable should be 1 but it''s %1', i);

    end;

    [TransactionModel(TransactionModel::None)]
    [TEST]
    procedure Test_SingletonStateNotRolledBackIntegerFromPreviousTest()
    var
        SingleTon: Codeunit "DOK Setup Singleton Vars";
    begin
        // [THEN] The SingleTonInteger should be 0
        TestHelpers.AssertTrue(SingleTon.GetSingletonInteger() = 1, 'The variable should be 0 but it''s %1', SingleTon.GetSingletonInteger());

    end;

    [TransactionModel(TransactionModel::AutoRollback)]
    [TEST]
    procedure Test_SingleTonSalesheader()
    var
        SalesHeader: Record "Sales Header";
        Singleton: Codeunit "DOK Setup Singleton Vars";
    begin
        // [GIVEN] A Sales Header Record
        SalesHeader := TestFixturesSales.CreateSalesOrder();

        // [WHEN] we set the singleton sales header
        Singleton.SetSingletonSalesHeader(SalesHeader);

        // [THEN] it should exist in the singleton
        TestHelpers.AssertTrue(Singleton.GetSingletonSalesHeader()."No." = SalesHeader."No.", 'The Sales Header no. should be the same but it''s not');

    end;

    [TEST]
    procedure Test_SalesHeaderPersistsAfterPreviousRollbackTest()
    var
        Singleton: Codeunit "DOK Setup Singleton Vars";
    begin

        // [THEN] We should still have the Sales Header in the Singleton
        TestHelpers.AssertTrue(Singleton.GetSingletonSalesHeader()."No." <> '', 'The Sales Header no. should be SO001 but it''s %1', Singleton.GetSingletonSalesHeader()."No.");

    end;

    [TransactionModel(TransactionModel::AutoRollback)]
    [TEST]
    procedure Test_CreateSalesHeaderRollsBackInAutoRollback()
    var
        SalesHeader: Record "Sales Header";
    begin
        // [GIVEN] a new Sales Header Record 
        SalesHeader := TestFixturesSales.CreateSalesOrder();

        // [WHEN] we add the SalesHeader."No." to a variable
        SavedSalesHeaderNo := SalesHeader."No.";

        // [THEN] the variable should be set
        TestHelpers.AssertTrue(SavedSalesHeaderNo <> '', 'The Sales Header no. should be set but it''s not');

    end;

    [TEST]
    procedure Test_SaveSalesHeaderNoWasRolledBackFromPreviousTest()
    var
    begin

        // [THEN] SavedSalesHeaderNo should still be set because it's not in the same transaction as the previous test
        TestHelpers.AssertTrue(SavedSalesHeaderNo <> '', 'The Sales Header no. should be empty but it''s %1', SavedSalesHeaderNo);

    end;

    [TEST]
    procedure Test_SalesHeaderShouldNotExistAsItWasRolledBackInPreviousTests()
    var
        SalesHeader: Record "Sales Header";
        SalesHeaderExists: Boolean;
    begin
        // [GIVEN] The fact we created a Sales Header in a previous test that was rolled back

        // [WHEN] we try to get it
        SalesHeaderExists := SalesHeader.Get(SalesHeader."Document Type"::Order, SavedSalesHeaderNo);

        // [THEN] The Sales Header with No. = SavedSalesHeader.No. should not exist
        TestHelpers.AssertTrue(not SalesHeaderExists, 'The Sales Header with No. %1 should not exist but it does', SavedSalesHeaderNo);

    end;

    [TransactionModel(TransactionModel::AutoRollback)]
    [TEST]
    procedure Test_SalesHeaderAddedToSingletonTransactionModelRollBack()
    var
        SalesHeader: Record "Sales Header";
        Singleton: Codeunit "DOK Setup Singleton Vars";
    begin
        // [GIVEN] A Sales Header Record
        SalesHeader := TestFixturesSales.CreateSalesOrderWithSalesLines(1);

        // [WHEN] we add it to the singleton
        Singleton.SetSingletonSalesHeader(SalesHeader);

        // [THEN] it should exist in the singleton
        TestHelpers.AssertTrue(Singleton.GetSingletonSalesHeader()."No." = SalesHeader."No.", 'The Sales Header no. should be the same but it''s not');

    end;

    [TEST]
    procedure Test_TheSalesHeaderExistsInTheSingletonButNotInTheDB()
    var
        SalesHeaderFromSingleton: Record "Sales Header";
        SalesHeaderFromDB: Record "Sales Header";
        Singleton: Codeunit "DOK Setup Singleton Vars";
        SalesHeaderExistsInDB: Boolean;
    begin
        // [GIVEN] the SaleHeader in the Singleton
        SalesHeaderFromSingleton := Singleton.GetSingletonSalesHeader();

        // [WHEN] When we try to get it from the DB
        SalesHeaderExistsInDB := SalesHeaderFromDB.Get(SalesHeaderFromSingleton."Document Type"::Order, SalesHeaderFromSingleton."No.");

        // [THEN] The SalesHeader should not exist in the DB
        TestHelpers.AssertTrue(not SalesHeaderExistsInDB, 'The Sales Header with No. %1 should not exist but it does', SalesHeaderFromSingleton."No.");

        // [THEN] The SalesHeader should exist in the Singleton
        TestHelpers.AssertTrue(SalesHeaderFromSingleton."No." <> '', 'The Sales Header no. should be SO001 but it''s %1', SalesHeaderFromSingleton."No.");

    end;


    var
        TestHelpers: Codeunit "DOK Test Helpers";
        TestFixturesSales: Codeunit "DOK Test Fixtures Sales";
        TestSetup: Codeunit "DOK Test Setup";
        TestSetupSingletonVars: Codeunit "DOK Setup Singleton Vars";
        SavedSalesHeaderNo: Code[20];
        Initialized: Boolean;
}
