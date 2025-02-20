{ include( "vesna.asl" ) }
{ include( "kqml_s.asl" ) }

+!go_to_work
    :   .my_name( Me ) & my_desk( MyDesk )
    <-  !go_to( MyDesk );
        .print( "I am at my desk" ).

+!work
    :   .my_name( Me ) & my_desk( MyDesk ) & at( Me, MyDesk )
    <-  .print( "I am working..." );
        .wait( 10000 ).

+!work
    :   .my_name( Me ) & my_desk( MyDesk )
    <-  .print( "I am not at my work station!" );
        !go_to_work;
        !work.

+!take_coffee
    <-  !go_to(  coffee_machine );
        .print( "I'm taking a coffee" );
        .wait( 5000 );
        .print( "Back to work!" ).

+!speak_with( Privacy, Person, Performative, Msg )
    <-  get_location( Person, Location );
        !go_to( Location );
        kqml_s.send( Privacy, Person, Performative, Msg );
        vesna.says( Performative, Person, Msg ).

+!print( Stuff )
    :   .my_name( Me) & my_desk( Desk ) & at( Me, Desk )
    <-  .print( "I am printing ", Stuff, "...");
        .random( X );
        .wait( 2000 + X * 1000 );
        +printed( Stuff );
        .print( "Printed!" ).

+!print( Stuff )
    <-  .print( "To print I have to go at my desk" );
        !go_to_work;
        .print( "Arrived" );
        !print( Stuff ).

+!give( Person, Object )
    :   Object
    <-  .print( "I want to give ", Person, ": ", Object );
        get_location( Person, Location );
        !go_to( Location );
        .print( "Giving ", Object, " to ", Person );
        kqml_s.send( private, Person, tell, Object );
        !go_to_work.

+!give( Person, paper( Paper, N ) )
    <-  .print( "I do not have ", N, " copies of ", Paper );
        !print( Object );
        .wait( 3000 );
        !give( Person, printed( paper( Paper, N ) ) ).