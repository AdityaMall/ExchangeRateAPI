/*codeunit 50102 "Fetch Exchange Rate"
{
    trigger OnRun()
    begin

    end;

    var
        myInt: Integer;


    local procedure DoFetchExchangeRate()
    var
        TempRestWebServiceArgument: Record "Rest Web Service Arguments";
    begin

        InItArguments(TempRestWebServiceArgument);
        FetchExchangeRate(TempRestWebServiceArgument);
        ViewResult(TempRestWebServiceArgument);
    end;

    local procedure InItArguments(var TempAvlrestWebServiceArgumnet: Record "Rest Web Service Arguments" temporary)
    begin
        TempAvlrestWebServiceArgumnet.URL := 'https://xecdapi.xe.com/v1/convert_from.xml?from=AED&to=*&amount=1';
    end;

    local procedure FetchExchangeRate(var TempAvlrestWebServiceArgumnet: Record "Rest Web Service Arguments" temporary)
    var
        success: Boolean;
    begin
        Success := callRestWebService(TempAvlrestWebServiceArgumnet);
    end;

    local procedure ViewResult(var TempAvlrestWebServiceArgumnet: Record "Rest Web Service Arguments" temporary)
    begin
        JSONResult.ReadFrom(TempAvlrestWebServiceArgumnet.GetResponseContantAsText());
    end;

    procedure callRestWebService(var RestWEBServiceArgument: Record "Rest Web Service Arguments"): Boolean
    var
        HttpClient: HttpClient;
        HttpHeaders: HttpHeaders;
        HttpRequestMessage: HttpRequestMessage;
        HttpResponseMessage: HttpResponseMessage;
        HttpContent: HttpContent;
    begin
        HttpRequestMessage.SetRequestUri(RestWEBServiceArgument.URL);
        HttpRequestMessage.GetHeaders(HttpHeaders);

        if RestWEBServiceArgument.HasRequestHttpContent() then begin

            RestWEBServiceArgument.GetRequestHttpContent(HttpContent);
            HttpRequestMessage.Content := HttpContent;
        end;

        HttpClient.Send(HttpRequestMessage, HttpResponseMessage);

        HttpHeaders := HttpResponseMessage.Headers();
        RestWEBServiceArgument.setResponseHeaders(HttpHeaders);
        HttpContent := HttpResponseMessage.Content();
        RestWEBServiceArgument.setResponseContent(HttpContent);
        exit(HttpResponseMessage.IsSuccessStatusCode());

    end;

    [EventSubscriber(ObjectType::Table, database::Currency, 'OnAfterModifyEvent', '', false, false)]
    local procedure currencyOnafterModify(var rec: Record Currency; var xRec: Record Currency; RunTrigger: Boolean);
    var
        CurrencyExchangeRate: Record "Currency Exchange Rate";
        StartingDate: Date;
    begin
        if not RunTrigger then
            exit;

        DoFetchExchangeRate();

        if JSONResult.Get(DateLbl, JsToken) then
            StartingDate := JsToken.AsValue().AsDate();

        CurrencyExchangeRate.Reset();
        CurrencyExchangeRate.SetRange(CurrencyExchangeRate."Currency Code", rec.Code);
        if not CurrencyExchangeRate.FindFirst() then
            if jsonObjectExchRate.Get(rec.Code, JsToken) then begin
                CurrencyExchangeRate.Init();
                CurrencyExchangeRate."Starting Date" := StartingDate;
                CurrencyExchangeRate."Currency Code" := rec.Code;
                CurrencyExchangeRate."Exchange Rate Amount" := 100.0;
                CurrencyExchangeRate."Relational Exch. Rate Amount" := JsToken.AsValue().AsDecimal();
                CurrencyExchangeRate."Adjustment Exch. Rate Amount" := 100.0;
                CurrencyExchangeRate."Relational Adjmt Exch Rate Amt" := JsToken.AsValue().AsDecimal();
                CurrencyExchangeRate.Insert();


            end;

    end;


}
*/