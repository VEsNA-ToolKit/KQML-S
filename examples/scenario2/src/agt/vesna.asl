// RCC Rules
po( X, Y ) :- map_po( X, Y ).
po( Y, X ) :- map_po( X, Y ).

ntpp( X, Y ) :- map_ntpp( X, Y ).
ntppi( Y, X ) :- map_ntpp( X, Y ).

ec( X, Y ) :- map_ec( X, Y ).
ec( Y, X ) :- map_ec( X, Y ).

// Check if two regions are subregions of the same one
same_region( Region1, Region2 ) :- ntpp( Region1, SuperRegion ) & ntpp( Region2, SuperRegion ).

+!go_to( Target )
    :   .my_name( Me ) & same_region( Me, Target )
    <-  // .print( "I want to go to ", Target, " and we are in the same region" );
        vesna.walk( Target, _ );
        .wait( {+movement( completed, destination_reached ) } );
        -at( Me, _ );
        +at( Me, Target ).
        // .print( "I arrived to ", Target ).

+!go_to( Target )
    :   .my_name( Me ) & ntpp( Me, MyRegion ) & ntpp( Target, TargetRegion ) & po( MyRegion, Door ) & po( Door, TargetRegion )
    <-  // .print( "I want to go to ", TargetRegion, " and I know there is ", Door, " that can lead me there");
        vesna.walk( Door, _ );
        .wait( { +movement( completed, destination_reached ) } );
        // .print( "I arrived to ", Door , " and I go inside" );
        vesna.walk( TargetRegion, _ );
        .wait( { +movement( completed, destination_reached ) } );
        // .print( "I arrived to final region ", TargetRegion );
        -ntpp( Me, _ );
        +ntpp( Me, TargetRegion ).

+!go_to( Target )
    :   .my_name( Me ) & ntpp( Me, MyRegion ) & ntpp( Target, TargetRegion ) & ec( MyRegion, Corridor) & ec( Corridor, TargetRegion )
    <-  // .print( "I want to go to ", TargetRegion, " and I know there is ", Corridor, " that can lead me there");
        Path = [ Corridor, TargetRegion ];
        !follow_path( Path );
        !go_to( Target ).

// TODO: Questo if then else non funziona
+!go_to( Target )
    :   .my_name( Me ) & ntpp( Me, MyRegion ) & ntpp( Target, TargetRegion )
    <-  // .print( "I am really far away, I have to reason a bit logically...");
        if ( TargetRegion == office ){
            ?find_path( MyRegion, Target, RPath );
        } else {
            ?find_path( MyRegion, TargetRegion, RPath );
        }
        .delete( MyRegion, RPath, LPath );
        .reverse( LPath, Path );
        // .print( "I follow ", Path );
        !follow_path( Path );
        // .print( "I go to ", Target );
        if ( not TargetRegion == office ) {
            !go_to( Target );
        }.

+!follow_path( [] )
    <-  true. //.print( "Destination reached").

@atomic
+!follow_path( [ Head | Tail ] )
    :   .my_name( Me )
    <-  //.print( "Moving to ", Head, ", tail = ", Tail );
        vesna.walk( Head, _ );
        .wait( {+movement( completed, destination_reached ) } );
        -ntpp( Me, _ );
        +ntpp( Me, Head );
        !follow_path( Tail ).

// //  -ntpp( Person, Region )
// //      :   .my_name( Person )
// //      <-  .broadcast( untell, ntpp( Person, Region ) ).

// // +ntpp( Person, Region )
// //     :   .my_name( Person )
// //     <-  update_location( Person, Region ).
// //        .broadcast( tell, ntpp( Person, Region ) ).

find_path( Start, Target, Path ) :- find_path_recursive( Start, Target, [ Start ], Path ).

find_path_recursive( Target, Target, Visited, Visited ).
find_path_recursive( Current, Target, Visited, Path ) :- ( po( Current, Next ) | ec( Current, Next ) ) & not .member( Next, Visited ) & find_path_recursive( Next, Target, [ Next | Visited ], Path ).

{ include("$jacamoJar/templates/common-cartago.asl") }
{ include("$jacamoJar/templates/common-moise.asl") }