/*codeunit 50101 TestWebApi

{

   trigger OnRun()

   begin

   end;

   procedure GET_Request(uri: Text) responseText: Text

   begin

       //json := StrSubstNo('localhost:63273/.../LeaveAccrual');

       json := StrSubstNo(uri);

       if client.Get(json, Response) then begin

           Response.Content.ReadAs(json);

           Message(json);

           exit(json);

       end;

   end;

   procedure POST_Request(uri: Text; _queryObj: Text) responseText: Text;

   var

       client: HttpClient;

       request: HttpRequestMessage;

       response: HttpResponseMessage;

       contentHeaders: HttpHeaders;

       content: HttpContent;

   begin

       // Add the payload to the content

       content.WriteFrom(_queryObj);

       // Retrieve the contentHeaders associated with the content

       content.GetHeaders(contentHeaders);

       contentHeaders.Clear();

       contentHeaders.Add('Content-Type', 'application/json');

       // Assigning content to request.Content will actually create a copy of the content and assign it.

       // After this line, modifying the content variable or its associated headers will not reflect in

       // the content associated with the request message

       request.Content := content;

       request.SetRequestUri(uri);

       request.Method := 'POST';

       client.Send(request, response);

       // Read the response content as json.

       response.Content().ReadAs(responseText);

   end;

   var

       Client: HttpClient;

       Response: HttpResponseMessage;

       json: Text;

       _httpContent: HttpContent;

       jsonObj: JsonObject;
       

}*/