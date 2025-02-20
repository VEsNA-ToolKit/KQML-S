package vesna;

import jason.asSemantics.*;
import jason.asSyntax.*;

import java.util.Set;

import org.json.JSONObject;

public class walk extends DefaultInternalAction {

    private static Set<String> available_actions = Set.of( "random", "stop", "door" );

    @Override
    public Object execute( TransitionSystem ts, Unifier un, Term[] args ) throws Exception {

        String target = args[0].toString();
        // if ( !available_actions.contains( target ) )
        //     throw new Exception( "Available arguments for functor 'walk' are: " + available_actions.toString() + ", given: " + target );

        long id = -1;
        switch ( target ) {
            case "random":
                id = 0;
                break;
            case "door":
                id = (long)( (NumberTerm) args[1] ).solve();
                break;
            default:
                // System.out.println( "Action " + target + " not implemented yet" );
                break;
        }

        JSONObject action = new JSONObject();
        action.put( "sender", "mind" );
        action.put( "receiver", "body" );
        action.put( "type", "walk" );
        JSONObject data = new JSONObject();
        data.put( "target", target );
        data.put( "id", id );
        action.put( "data", data );

        VesnaAgent ag = ( VesnaAgent ) ts.getAg();
        ag.perform( action.toString() );

        return true;
    }
    
}
