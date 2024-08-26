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

    var
        MSTNoSeriesCode: Code[20];

}