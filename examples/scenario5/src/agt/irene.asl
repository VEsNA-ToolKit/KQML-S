credolous.

+!start
    :   .my_name( Me )
    <-  +ntpp( Me, reception );
        +my_desk( junior_2_desk );
        .wait( 1000 );
        !go_to_work.

+notify( achieve, Sender, Recipients, print( Stuff ) )
    :   credolous
    <-  .print( "Oops! I heard ", print( Stuff ), " with performative ", Performative, " from ", Sender, " to ", Recipients );
        vesna.says( tell, Sender, i_can_do( print( Stuff ) ) );
        kqml_s.send( public, Sender, tell, i_can_do( print( Stuff ) ) );
        !print( Stuff );
        !give( Sender, printed( Stuff ) ).

+!check_rules( Project, Rules )
    <-  .print( "Ok, I look for rules of project ", Project );
        .wait( 8000 );
        .print( "Ok found!" );
        Rules = [ rule1, rule2, rule3 ].

{ include( "office_map.asl" ) }
{ include( "academic.asl" ) }