codeunit 50016 "DOK General Setup Singleton"
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