codeunit 50014 "DOK Test Logs"
{

    Subtype = Test;

    [TEST]
    procedure Test_Logs()
    var
        SalesHeaderInsertLog: Record "DOK Sales Header Insert Log";
        SalesHdrInsertLogRunCount: Record "DOK SalesHdrInsertLog RunCount";
        ThisTestRunCount: BigInteger;
        NoOfSalesHeadersCreated: BigInteger;
    begin
        SalesHeaderInsertLog.Init();
        SalesHeaderInsertLog.Insert();
        NoOfSalesHeadersCreated := SalesHeaderInsertLog."No. of Sales Headers Created";
        SalesHdrInsertLogRunCount.Init();
        SalesHdrInsertLogRunCount.Insert();
        ThisTestRunCount := SalesHdrInsertLogRunCount."Run Count";
        Error('✅ No of Sales Orders: %1', NoOfSalesHeadersCreated - ThisTestRunCount);
    end;


}