codeunit 50016 "DOK Setup Singleton Vars"
{

    SingleInstance = true;

    procedure GetMSTNoSeriesCode(): Code[20];
    begin
        exit(MSTNoSeriesCode);
    end;

    procedure SetMSTNoSeriesCode(SetToMSTNoSeriesCode: Code[20]);
    begin
        MSTNoSeriesCode := SetToMSTNoSeriesCode;
    end;

    procedure GetSingletonInteger(): Integer;
    begin
        exit(SingletonInteger);
    end;

    procedure SetSingletonInteger(SetToSomeInteger: Integer);
    begin
        SingletonInteger := SetToSomeInteger;
    end;

    procedure SetSingletonSalesHeader(SalesHeader: Record "Sales Header");
    begin
        SingletonSalesHeader := SalesHeader;
    end;

    procedure GetSingletonSalesHeader(): Record "Sales Header";
    begin
        exit(SingletonSalesHeader);
    end;

    var
        SingletonSalesHeader: Record "Sales Header";
        MSTNoSeriesCode: Code[20];
        SingletonInteger: Integer;

}