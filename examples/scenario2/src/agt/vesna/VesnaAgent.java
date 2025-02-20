package vesna;

import jason.asSemantics.*;
import jason.asSyntax.*;
import static jason.asSyntax.ASSyntax.*;

import java.net.URI;
import org.json.JSONObject;

public class VesnaAgent extends Agent implements WsClientMsgHandler {

    private WsClient client;

    @Override
    public void loadInitialAS( String asSrc ) throws Exception {

        super.loadInitialAS( asSrc );

        Unifier address_unifier = new Unifier();
        believes( parseLiteral( "address( Address )" ), address_unifier );
        String address = address_unifier.get( "Address" ).toString();

        Unifier port_unifier = new Unifier();
        believes( parseLiteral( "port( Port )" ), port_unifier );
        int port = ( int ) ( ( NumberTerm ) port_unifier.get( "Port" ) ).solve();
        System.out.println( "Body is at " + address + ":" + port );

        URI body_address = new URI( "ws://" + address + ":" + port );
        client = new WsClient( body_address );
        client.setMsgHandler( this::handle_msg );
        client.connect();

    }

    public void perform( String action ) {
        client.send( action );
    }

    private void sense( Literal perception ) {
        try {
            InternalAction signal = getIA( ".signal" );
            StringTerm type = createString( "+" + perception.toString() );
            Unifier un = new Unifier();
            TransitionSystem ts = getTS();
            Term[] event_list = new Term[] { type };
            signal.execute( ts, un, event_list );
        } catch ( Exception e ) {
            e.printStackTrace();
        }
    }

    private void handle_event( JSONObject event ) {
        String event_type = event.getString( "type" );
        String event_status = event.getString( "status" );
        String event_reason = event.getString( "reason" );
        Literal perception = createLiteral( event_type, createLiteral( event_status ), createLiteral( event_reason ) );
        sense(perception);
    }

    private void handle_sight( JSONObject sight ) {
        String object = sight.getString( "sight" );
        long id = sight.getLong( "id" );
        Literal sight_belief = createLiteral( "sight", createLiteral( object ), createNumber( id ) );
        try{
            addBel( sight_belief );
        } catch ( Exception e ) {
            e.printStackTrace();
        }
    }

    @Override
    public void handle_msg( String msg ) {
        // System.out.println( "Received message: " + msg );
        JSONObject log = new JSONObject( msg );
        String sender = log.getString( "sender" );
        String receiver = log.getString( "receiver" );
        String type = log.getString( "type" );
        JSONObject data = log.getJSONObject( "data" );
        switch( type ){
            case "signal":
                handle_event( data );
                break;
            case "sight":
                handle_sight( data );
                break;
            default:
                System.out.println( "Unknown message type: " + type );
        }
    }
}