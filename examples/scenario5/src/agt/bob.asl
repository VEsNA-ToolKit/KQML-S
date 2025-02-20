{ include( "office_map.asl" ) }
{ include( "academic.asl" ) }

+!start
    :   .my_name( Me )
    <-  +ntpp( Me, reception );
        +my_desk( junior_10_desk );
        !take_coffee.