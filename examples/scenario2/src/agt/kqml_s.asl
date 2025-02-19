+ntpp( Person, Region )
    :   .my_name( Person )
    <-  update_location( Person, Region ).

+notify( tell, Sender, Recipients, Msg )
    :   credolous
    <-  .print( "Oops! I heard ", Msg, " with performative ", Performative, " from ", Sender, " to ", Recipients );
        +Msg[ source( Sender ) ].

+notify( tell, Sender, Recipients, Msg )
    <-  .print( "Oops! I heard ", Msg, " with performative ", Performative, " from ", Sender, " to ", Recipients ).