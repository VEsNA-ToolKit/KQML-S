package vesna;

import jason.asSemantics.*;
import jason.asSyntax.*;

import org.json.JSONObject;

public class says extends DefaultInternalAction {
   
    @Override
    public Object execute( TransitionSystem ts, Unifier un, Term[] args ) throws Exception {
        String performative = args[0].toString();
        String recipient = args[1].toString();
        String msg = args[2].toString();

        JSONObject action = new JSONObject();
        action.put( "sender", "mind" );
        action.put( "receiver", "body" );
        action.put( "type", "say" );
        JSONObject data = new JSONObject();
        data.put( "performative", performative );
        data.put( "recipient", recipient );
        data.put( "msg", msg );
        action.put( "data", data );

        VesnaAgent ag = ( VesnaAgent ) ts.getAg();
        ag.perform( action.toString() );

        return true;
    }
}
