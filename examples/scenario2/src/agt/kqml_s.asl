+ntpp( Person, Region )
    :   .my_name( Person )
    <-  update_location( Person, Region ).

+notify( tell, Sender, Recipients, Msg )
    :   credolous
    <-  .print( "Oops! I heard ", Msg, " with performative tell from ", Sender, " to ", Recipients );
        .print( "I believe it! I add it to beliefs" );
        +Msg[ source( Sender ) ].

+notify( tell, Sender, Recipients, Msg )
    <-  .print( "Oops! I heard ", Msg, " with performative tell from ", Sender, " to ", Recipients ).