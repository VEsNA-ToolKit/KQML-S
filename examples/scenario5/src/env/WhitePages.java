package kqml_s;

import jason.asSemantics.*;
import jason.asSyntax.*;
import cartago.*;

import java.util.HashMap;
import java.util.Map;
import java.util.List;
import java.util.ArrayList;

public class WhitePages extends Artifact {

    protected static Map<String, String> whitePages = new HashMap<>();
    //TODO: forse meglio al contrario con location come chiave e agent come valore in lista?

    @OPERATION
    public void update_location( String agent, String location ) {
        // // System.out.println( "Got location update: " + agent + " is at " + location );
        whitePages.put( agent, location );
    }

    @OPERATION
    public void get_location( String agent, OpFeedbackParam<Literal> location ){
        String address = whitePages.get( agent );
        if ( address == null ) {
            location.set( ASSyntax.createLiteral( "unknown" ) );
        } else {
            location.set( ASSyntax.createLiteral( address ) );
        }
    }

    public static Map<String, String> get_white_pages() {
        return whitePages;
    }

    public static List<String> get_near_agents( String agent ) {
        List<String> near_agents = new ArrayList<>();
        String location = whitePages.get( agent );
        for ( String other_agent : whitePages.keySet() ) {
            if ( whitePages.get( other_agent ).equals( location ) )
                near_agents.add( other_agent );
        }
        return near_agents;
    }

    public static boolean is_agent_in_room( String agent, String room ) {
        return whitePages.get( agent ).equals( room );
    }

    public static String get_agent_room( String agent ) {
        return whitePages.get( agent );
    }

}