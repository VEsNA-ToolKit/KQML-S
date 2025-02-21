+ntpp( Person, Region )
    :   .my_name( Person )
    <-  update_location( Person, Region ).

+notify( tell, Receiver, Msg )[ source( Sender ) ]
    :   credolous
    <-  .print( "Oops! I heard ", Msg, " with performative tell from ", Sender, " to ", Receiver );
        .print( "I believe it! I add it to beliefs" );
        +Msg[ source( Sender ) ].

+notify( Performative, Receiver, Msg )[ source( Sender ) ]
    <-  .print( "Oops! I heard ", Msg, " with performative ", Performative, " from ", Sender, " to ", Receiver ).