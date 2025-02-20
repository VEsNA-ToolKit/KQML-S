{ include( "office_map.asl" ) }
{ include( "academic.asl" ) }

+!start
    :   .my_name( Me )
    <-  +ntpp( Me, senior_office_2 );
        +my_desk( senior_3_desk );
        .wait( 15000 );
        !go_to( open_office );
        .print( "I tell bob that we won the big project");
        kqml_s.send( public, all, achieve, give( Me, paper( emas_call, 1 ) ) );
        vesna.says( achieve, all, give( Me, paper( emas_call, 1 ) ) );
        .wait( 2000 );
        !go_to_work.

+!kqml_received( Sender, tell, rules( Project, Rules ), _ )
    <-  .print( "I received rules for ", Project, ": ", Rules );
        .print( "Thanks ", Sender, "!").