codeunit 50505 "OpenRates Mgt"
{
    trigger OnRun()
    begin
        GetRateForDate(Today());
    end;

    procedure GetRateForDate(D: Date)
    var
        GenLedSetup: Record "General Ledger Setup";
        Client: HttpClient;
        Response: HttpResponseMessage;
        ContentTxt: Text;

        JsObj: JsonObject;

        jsArray: JsonArray;
        jsToken: JsonToken;
        jsToken1: JsonToken;
        jsToken2: JsonToken;

        Totoken: JsonToken;
        timestampToken: JsonToken;
        DateToken: JsonToken;

        CurRate: Decimal;
        CurDate: Date;
        DateData: DateTime;
        userName: Text;
        Password: Text;

        CurRec: Record Currency;
        ExchangeRate: Record "Currency Exchange Rate";
        AuthString: Text;
        base64Convert: Codeunit "Base64 Convert";

    begin
        GenLedSetup.Get();
        //Add User authentication in API url with your API_Id & API_Password
        userName := 'amy137779907';
        Password := '2jamp6nqbctteje1h832m47otj';
        AuthString := STRSUBSTNO('%1:%2', userName, Password);
        AuthString := base64Convert.ToBase64(AuthString);
        AuthString := STRSUBSTNO('Basic %1', AuthString);
        Client.DefaultRequestHeaders().Add('Authorization', AuthString);

        //Get API URL throgh HTTP CLIENT
        if Client.Get('https://xecdapi.xe.com/v1/convert_from?from=AED&to=*', Response) then begin

            if Response.IsSuccessStatusCode() then begin
                if Response.Content().ReadAs(ContentTxt) then begin
                    if JsObj.ReadFrom(ContentTxt) then begin
                        if JsObj.Get('to', ToToken) then begin
                            JsObj.Get('timestamp', timestampToken);
                            DateData := timestampToken.AsValue().AsDateTime();

                            //change DATETIME data type into DATE data type
                            CurDate := DT2DATE(DateData);

                            if CurRec.FindSet() then
                                repeat

                                    // here 'ToToken' is a JsonArray then
                                    foreach jsToken in ToToken.AsArray() do begin

                                        if jsToken.IsObject then begin
                                            jsObj := jsToken.AsObject();
                                            jsObj.Get('quotecurrency', jsToken1);
                                            jsObj.get('mid', jsToken2);

                                            CurRec.Code := jsToken1.AsValue().AsCode();
                                            CurRate := jsToken2.AsValue().AsDecimal();

                                            ExchangeRate.Init();
                                            ExchangeRate."Currency Code" := CurRec.Code;
                                            ExchangeRate."Starting Date" := CurDate;

                                            if ExchangeRate.Insert(true) then begin
                                                ExchangeRate.Validate("Exchange Rate Amount", 1);
                                                ExchangeRate.Validate("Adjustment Exch. Rate Amount", 1);
                                                ExchangeRate.Validate("Relational Exch. Rate Amount", 1 / CurRate);
                                                ExchangeRate.Validate("Relational Adjmt Exch Rate Amt", 1 / CurRate);
                                                ExchangeRate.Modify(true);
                                            end;
                                        end;
                                    end;
                                until CurRec.Next() = 0;
                        end else
                            error('Could not find "TO" in json (%1)', ContentTxt);
                    end else
                        error('Malformed JSON (%1)', ContentTxt);
                end else
                    error('Server did not return any data');
            end else begin
                if Response.Content().ReadAs(ContentTxt) then
                    error('Http call failed, return value (%1) (Info %2)', Response.HttpStatusCode(), ContentTxt)
                else
                    error('Http call failed, return value (%1)', Response.HttpStatusCode());
            end;
        end else
            error('Could not connect to openrates.io');
    end;
}