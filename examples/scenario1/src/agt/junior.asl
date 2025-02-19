{ include( "vesna.asl" ) }
{ include( "office_map.asl" ) }

+!start
    :   .my_name( Me )
    <-  +ntpp( Me, reception );
        .concat( Me, "_desk", MyDeskStr );
        .term2string( MyDesk, MyDeskStr );
        +my_desk( MyDesk );
        .wait( 4000 );
        // !work;
        // !take_coffe;
        // !work;
        !speak_with_boss( boss_1, tell, ciao ).

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

+!speak_with_boss( Boss, Performative, Msg )
    <-  .concat( Boss, "_desk", BossDeskStr );
        .term2string( BossDesk, BossDeskStr );
        !go_to( BossDesk );
        .print( "I send a public ", Msg , " to ", Boss, "with performative ", Performative );
        kqml_s.send( public, Boss, Performative, Msg );
        .print( "I send a private ", Msg , " to ", Boss, "with performative ", Performative );
        kqml_s.send( private, Boss, Performative, Msg );
        .print( "I send a public ", Msg , " to all with performative ", Performative );
        kqml_s.send( public, all, Performative, Msg ).

+!take_coffe
    <-  !go_to(  coffee_machine );
        .print( "I'm taking a coffee" );
        .wait( 5000 );
        .print( "Back to work!" ).