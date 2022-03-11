/*table 50100 "Rest Web Service Arguments"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; PrimaryKey; Integer)
        {
            DataClassification = ToBeClassified;

        }
        field(2; URL; text[250])
        {
            DataClassification = ToBeClassified;
        }
        field(3; blob; Blob)
        {
            DataClassification = ToBeClassified;
        }
    }

    keys
    {
        key(pk; PrimaryKey)
        {
            Clustered = true;
        }
    }

    var
        myInt: Integer;

    trigger OnInsert()
    begin

    end;

    trigger OnModify()
    begin

    end;

    trigger OnDelete()
    begin

    end;

    trigger OnRename()
    begin

    end;

}*/