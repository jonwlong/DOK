codeunit 50005 "DOK Utilities"
{

    // GetRandomString returns a random string of the specified length. Max is 32 due to using GUIDs to generate the random string.
    procedure GetRandomString(Length: Integer): Text
    begin
        exit(CopyStr(DelChr(Format(CreateGuid()), '=', '{}-'), 1, Length));
    end;

    procedure GetRandomText20(): Text[20]
    begin
        exit(CopyStr(DelChr(Format(CreateGuid()), '=', '{}-'), 1, 20));
    end;

    procedure GetRandomText30(): Text[30]
    begin
        exit(CopyStr(DelChr(Format(CreateGuid()), '=', '{}-'), 1, 30));
    end;

    procedure GetRandomCode10(): Code[10]
    begin
        exit(CopyStr(DelChr(Format(CreateGuid()), '=', '{}-'), 1, 10));
    end;

    procedure GetRandomCode20(): Code[20]
    begin
        exit(CopyStr(DelChr(Format(CreateGuid()), '=', '{}-'), 1, 20));
    end;

    procedure GetRandomCode30(): Code[30]
    begin
        exit(CopyStr(DelChr(Format(CreateGuid()), '=', '{}-'), 1, 30));
    end;


}