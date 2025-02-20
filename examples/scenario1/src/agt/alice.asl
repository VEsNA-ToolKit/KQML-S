{ include( "office_map.asl" ) }
{ include( "academic.asl" ) }

+!start
    :   .my_name( Me )
    <-  +ntpp( Me, senior_office_2 );
        +my_desk( senior_3_desk );
        .wait( 5000 );
        !go_to( open_office );
        .print( "I ask bob to print 2 exam texts" );
        kqml_s.send( public, bob, achieve, print( paper( exam, 2 ) ) );
        vesna.says( achieve, bob, print( paper( exam, 2 ) ) );
        .wait( 2000 );
        !go_to_work.