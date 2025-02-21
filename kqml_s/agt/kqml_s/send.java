package kqml_s;

import java.util.concurrent.TimeUnit;

import jason.JasonException;
import jason.architecture.*;
import jason.asSemantics.*;
import jason.asSyntax.*;
import static jason.asSyntax.ASSyntax.*;
import cartago.*;

import java.util.Map;
import java.util.ArrayList;
import java.util.List;

import kqml_s.WhitePages;

public class send extends DefaultInternalAction {

    private boolean lastSendWasSyncAsk = false;

    @Override
    protected void checkArguments( Term[] args ) throws JasonException {

        super.checkArguments( args );

        // * NEW IN KQML-S SEND 
        if ( !( args[0].toString().equals( "public" ) || args[0].toString().equals( "private" ) ) )
            throw JasonException.createWrongArgument( this, "Privacy parameter ('" + args[0] + "') must be 'public' or 'private'!" );

        if ( !args[1].isAtom() && !args[1].isList() && !args[1].isString() )
            throw JasonException.createWrongArgument( this, "TO parameter ('" + args[1] + "') must be an atom, a string or a list of receivers!" );

        if ( !args[2].isAtom() )
            throw JasonException.createWrongArgument( this, "illocutionary force parameter ('" + args[2] + "') must be an atom!" );

    }

    @Override
    public Object execute( TransitionSystem ts, Unifier un, Term[] args ) throws Exception {

        checkArguments( args );

        // * NEW IN KQML-S SEND
        Term privacy = args[0];
        final Term to;//= args[1];
        Term ilf = args[2];
        Term pcnt = args[3];

        final Message m = new Message( ilf.toString(), ts.getAgArch().getAgName(), null, pcnt );

        lastSendWasSyncAsk = m.isAsk() && args.length > 4;
        if ( lastSendWasSyncAsk ) {
            m.setSyncAskMsgId();
            ts.getC().addPendingIntention( m.getMsgId(), ASSyntax.createAtom( "waiting_ask" ), ts.getC().getSelectedIntention(), false );
        }

        if ( ( m.isTell() || m.isUnTell() || !m.isKnownPerformative() ) && args.length > 4 ) {
            Term mid = args[4];
            if ( !mid.isAtom() )
                throw new JasonException( "The message ID ('" + mid +"') parameter of the internal action ssend is not an atom!" );
            m.setInReplyTo( mid.toString() );
        }

        // * NEW IN KQML-S SEND
        if ( args[1].toString().equals( "all" ) ){
            List<String> near_agents = WhitePages.get_near_agents( ts.getAgArch().getAgName() );
            ListTerm near_agents_list = new ListTermImpl();
            for ( String ag : near_agents ) {
                if ( !ag.equals( ts.getAgArch().getAgName().toString() ) )
                    near_agents_list.add( new Atom( ag ) );
            }
            to = near_agents_list;
        } else {
            to = args[1];
        }

        List<String> recipients = new ArrayList<>();
        String room = WhitePages.get_agent_room( ts.getAgArch().getAgName() );
        if ( to.isList() ) {
            for ( Term t : ( ListTerm ) to ) {
                if ( WhitePages.is_agent_in_room( t.toString(), room ) ){
                    recipients.add( t.toString() );
                    delegateSendToArch( t, ts, m );
                }
            }
        } else {
            if ( WhitePages.is_agent_in_room( to.toString(), room ) ) {
                recipients.add( to.toString() );
                delegateSendToArch( to, ts, m );
            }
        }
        if ( privacy.toString().equals( "public" ) )
            notifyAgentsInRoom( ts, m, to, recipients );

        if ( lastSendWasSyncAsk && args.length == 6 ) {
            Term tto = args[5];
            if ( tto.isNumeric() ) {
                Agent.getScheduler().schedule( new Runnable() {
                    public void run() {
                        Intention intention = ts.getC().removePendingIntention( m.getMsgId() );
                        if ( intention != null ) {
                            Structure send = ( Structure ) intention.peek().removeCurrentStep();
                            Term timeoutAns = null;
                            if ( to.isList() ) {
                                VarTerm answers = new VarTerm( "AnsList___" + m.getMsgId() );
                                Unifier un = intention.peek().getUnif();
                                timeoutAns = un.get( answers );
                                if ( timeoutAns == null )
                                    timeoutAns = new ListTermImpl();
                            } else {
                                timeoutAns = new Atom( "timeout" );
                            }
                            intention.peek().getUnif().unifies( send.getTerm( 3 ), timeoutAns );
                            ts.getC().resumeIntention( intention, ASSyntax.createAtom( "send_ask_msg_timeout" ) );
                            ts.getAgArch().wakeUpAct();
                        }
                    }
                }, ( long ) ( ( NumberTerm ) tto).solve(),TimeUnit.MILLISECONDS );
            } else {
                throw new JasonException( "The 5th parameter of send must be a number (timeout) and not '" + tto + "'!" );
            }
        }

        return true;

    }

    private void delegateSendToArch( Term to, TransitionSystem ts, Message m ) throws Exception {
        if ( !to.isAtom() && !to.isString() )
            throw new JasonException( "The TO parameter '" + to + "' of the internal action 'ssend' is not an atom!" );
        
        String rec = null;
        if ( to.isString() )
            rec = ( ( StringTerm ) to ).getString();
        else if ( to.isAtom() )
            rec = ( ( Atom ) to ).getFunctor();
        else
            rec = to.toString();
        if ( rec.equals( "self" ) )
            rec = ts.getAgArch().getAgName();
        m.setReceiver( rec );
        ts.getAgArch().sendMsg( m );
    }

    @Override
    public boolean suspendIntention() {
        return lastSendWasSyncAsk;
    }

    private void notifyAgentsInRoom( TransitionSystem ts, Message m, Term to, List<String> recipients ) throws Exception {
        String agName = ts.getAgArch().getAgName().toString();
        List<String> agents = WhitePages.get_near_agents( agName );
        agents.remove( agName );
        for ( String rec : recipients ) {
            agents.remove( rec );
        }
        // // System.out.println( "Notified agents in same room: " + agents.toString() );
        String msg = m.getPropCont().toString();
        String performative = m.getIlForce();
        // String to = m.getReceiver();
        for ( String ag : agents ){
            System.out.println( "TO "+ ag + " performative: " + performative + " agName: " + agName + " to: " +  recipients + " msg: " + msg );
            Literal msgLit = ASSyntax.createLiteral( "notify", parseLiteral( performative), parseLiteral( agName ), to, parseLiteral( msg ) );
            Message signal_m = new Message( "signal", agName, ag, msgLit );
            ts.getAgArch().sendMsg( signal_m );
        }
    }
    
}
