credolous.

+!start
    :   .my_name( Me )
    <-  +ntpp( Me, reception );
        +my_desk( junior_11_desk );
        .wait( 1000 );
        !go_to_work.

+notify( achieve, Sender, Recipients, check_rules( Project ) )
    :   credolous
    <-  .print( "Oops! I heard ", check_rules( Project ), " with performative ", Performative, " from ", Sender, " to ", Recipients );
        vesna.says( tell, Sender, i_can_do( check_rules( Project ) ) );
        kqml_s.send( public, Sender, tell, i_can_do( check_rules( Project ) ) );
        !check_rules( Project, Rules );
        .print( "I tell ", Sender, " the rules" );
        !speak_with( public, Sender, tell, rules( Project, Rules ) ).

+!check_rules( Project, Rules )
    <-  .print( "Ok, I look for rules of project ", Project );
        .wait( 8000 );
        .print( "Ok found!" );
        Rules = [ rule1, rule2, rule3 ].

{ include( "office_map.asl" ) }
{ include( "academic.asl" ) }