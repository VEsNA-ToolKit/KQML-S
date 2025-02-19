{ include( "office_map.asl" ) }
{ include( "academic.asl" ) }

credolous.

+!start
    :   .my_name( Me )
    <-  +ntpp( Me, reception );
        +my_desk( junior_12_desk );
        .wait( 1000 );
        !go_to_work.