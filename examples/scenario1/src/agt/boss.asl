+!kqml_received( Sender, Performative, Msg, _ )
    <-  .print( "Received ", Msg, " from ", Sender, " with performative ", Performative ).

!start.

+!start
    :   .my_name( Me )
    <-  update_location( Me, boss_office_1 ).

{ include("$jacamoJar/templates/common-cartago.asl") }
{ include("$jacamoJar/templates/common-moise.asl") }