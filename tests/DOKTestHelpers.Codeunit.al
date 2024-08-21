codeunit 50002 "DOK Test Helpers"
{
    procedure AssertTrue(condition: Boolean; errorMessage: Variant);
    var
        errorMessageLbl: Label 'Error: %1', Comment = '%1 is the Error message';
    begin
        if not condition then
            Error(errorMessageLbl, errorMessage);
    end;

    procedure AreEqual(value1: Integer; value2: Integer; errorMessage: Variant);
    begin
        if value1 <> value2 then
            Error('Error: %1', errorMessage);
    end;

    procedure AreEqual(value1: Text; value2: Text; errorMessage: Variant);
    begin
        if value1 <> value2 then
            Error('Error: %1', errorMessage);
    end;

    procedure IsNotBlank(value: Text[1024]; errorMessage: Variant);
    begin
        if value.Trim() = '' then
            Error('Error: %1', errorMessage);
    end;

    procedure AssertTrue(condition: Boolean; errorMessage: Variant; Arg1: Variant);
    begin
        if not condition then
            Error((StrSubstNo(errorMessage, Arg1)));
    end;

    procedure AssertTrue(condition: Boolean; errorMessage: Variant; Arg1: Variant; Arg2: Variant);
    begin
        if not condition then
            Error((StrSubstNo(errorMessage, Arg1, Arg2)));
    end;

    procedure AssertTrue(condition: Boolean; errorMessage: Variant; Arg1: Variant; Arg2: Variant; Arg3: Variant);
    begin
        if not condition then
            Error((StrSubstNo(errorMessage, Arg1, Arg2, Arg3)));
    end;

    procedure AssertTrue(condition: Boolean; errorMessage: Variant; Arg1: Variant; Arg2: Variant; Arg3: Variant; Arg4: Variant);
    begin
        if not condition then
            Error((StrSubstNo(errorMessage, Arg1, Arg2, Arg3, Arg4)));
    end;

    procedure AssertTrue(condition: Boolean; errorMessage: Variant; Arg1: Variant; Arg2: Variant; Arg3: Variant; Arg4: Variant; Arg5: Variant);
    begin
        if not condition then
            Error((StrSubstNo(errorMessage, Arg1, Arg2, Arg3, Arg4, Arg5)));
    end;

}