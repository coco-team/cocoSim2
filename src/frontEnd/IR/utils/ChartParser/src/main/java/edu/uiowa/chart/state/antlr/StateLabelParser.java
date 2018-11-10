// Generated from StateLabel.g4 by ANTLR 4.7.1
package edu.uiowa.chart.state.antlr;
import org.antlr.v4.runtime.atn.*;
import org.antlr.v4.runtime.dfa.DFA;
import org.antlr.v4.runtime.*;
import org.antlr.v4.runtime.misc.*;
import org.antlr.v4.runtime.tree.*;
import java.util.List;
import java.util.Iterator;
import java.util.ArrayList;

@SuppressWarnings({"all", "warnings", "unchecked", "unused", "cast"})
public class StateLabelParser extends Parser {
	static { RuntimeMetaData.checkVersion("4.7.1", RuntimeMetaData.VERSION); }

	protected static final DFA[] _decisionToDFA;
	protected static final PredictionContextCache _sharedContextCache =
		new PredictionContextCache();
	public static final int
		T__0=1, T__1=2, T__2=3, T__3=4, T__4=5, T__5=6, T__6=7, Entry=8, During=9, 
		Exit=10, Bind=11, On=12, After=13, Before=14, At=15, Every=16, Identifier=17, 
		IdentifierLetter=18, Number=19, Integer=20, Float=21, Digit=22, LineComment=23, 
		WhiteSpace=24, AnyCharacter=25;
	public static final int
		RULE_stateLabel = 0, RULE_stateName = 1, RULE_actions = 2, RULE_action = 3, 
		RULE_actionType = 4, RULE_actionBody = 5;
	public static final String[] ruleNames = {
		"stateLabel", "stateName", "actions", "action", "actionType", "actionBody"
	};

	private static final String[] _LITERAL_NAMES = {
		null, "'\r'", "'\n'", "'/'", "','", "':'", "'('", "')'", null, null, null, 
		"'bind'", "'on'", "'after'", "'before'", "'at'", "'every'"
	};
	private static final String[] _SYMBOLIC_NAMES = {
		null, null, null, null, null, null, null, null, "Entry", "During", "Exit", 
		"Bind", "On", "After", "Before", "At", "Every", "Identifier", "IdentifierLetter", 
		"Number", "Integer", "Float", "Digit", "LineComment", "WhiteSpace", "AnyCharacter"
	};
	public static final Vocabulary VOCABULARY = new VocabularyImpl(_LITERAL_NAMES, _SYMBOLIC_NAMES);

	/**
	 * @deprecated Use {@link #VOCABULARY} instead.
	 */
	@Deprecated
	public static final String[] tokenNames;
	static {
		tokenNames = new String[_SYMBOLIC_NAMES.length];
		for (int i = 0; i < tokenNames.length; i++) {
			tokenNames[i] = VOCABULARY.getLiteralName(i);
			if (tokenNames[i] == null) {
				tokenNames[i] = VOCABULARY.getSymbolicName(i);
			}

			if (tokenNames[i] == null) {
				tokenNames[i] = "<INVALID>";
			}
		}
	}

	@Override
	@Deprecated
	public String[] getTokenNames() {
		return tokenNames;
	}

	@Override

	public Vocabulary getVocabulary() {
		return VOCABULARY;
	}

	@Override
	public String getGrammarFileName() { return "StateLabel.g4"; }

	@Override
	public String[] getRuleNames() { return ruleNames; }

	@Override
	public String getSerializedATN() { return _serializedATN; }

	@Override
	public ATN getATN() { return _ATN; }

	public StateLabelParser(TokenStream input) {
		super(input);
		_interp = new ParserATNSimulator(this,_ATN,_decisionToDFA,_sharedContextCache);
	}
	public static class StateLabelContext extends ParserRuleContext {
		public StateNameContext stateName() {
			return getRuleContext(StateNameContext.class,0);
		}
		public ActionsContext actions() {
			return getRuleContext(ActionsContext.class,0);
		}
		public StateLabelContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_stateLabel; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof StateLabelListener ) ((StateLabelListener)listener).enterStateLabel(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof StateLabelListener ) ((StateLabelListener)listener).exitStateLabel(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof StateLabelVisitor ) return ((StateLabelVisitor<? extends T>)visitor).visitStateLabel(this);
			else return visitor.visitChildren(this);
		}
	}

	public final StateLabelContext stateLabel() throws RecognitionException {
		StateLabelContext _localctx = new StateLabelContext(_ctx, getState());
		enterRule(_localctx, 0, RULE_stateLabel);
		int _la;
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(12);
			stateName();
			setState(14);
			_errHandler.sync(this);
			_la = _input.LA(1);
			if (_la==T__0) {
				{
				setState(13);
				match(T__0);
				}
			}

			setState(19);
			_errHandler.sync(this);
			_la = _input.LA(1);
			while (_la==T__1) {
				{
				{
				setState(16);
				match(T__1);
				}
				}
				setState(21);
				_errHandler.sync(this);
				_la = _input.LA(1);
			}
			setState(23);
			_errHandler.sync(this);
			_la = _input.LA(1);
			if ((((_la) & ~0x3f) == 0 && ((1L << _la) & ((1L << Entry) | (1L << During) | (1L << Exit) | (1L << Bind) | (1L << On))) != 0)) {
				{
				setState(22);
				actions();
				}
			}

			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	public static class StateNameContext extends ParserRuleContext {
		public TerminalNode Identifier() { return getToken(StateLabelParser.Identifier, 0); }
		public StateNameContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_stateName; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof StateLabelListener ) ((StateLabelListener)listener).enterStateName(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof StateLabelListener ) ((StateLabelListener)listener).exitStateName(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof StateLabelVisitor ) return ((StateLabelVisitor<? extends T>)visitor).visitStateName(this);
			else return visitor.visitChildren(this);
		}
	}

	public final StateNameContext stateName() throws RecognitionException {
		StateNameContext _localctx = new StateNameContext(_ctx, getState());
		enterRule(_localctx, 2, RULE_stateName);
		int _la;
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(25);
			match(Identifier);
			setState(27);
			_errHandler.sync(this);
			_la = _input.LA(1);
			if (_la==T__2) {
				{
				setState(26);
				match(T__2);
				}
			}

			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	public static class ActionsContext extends ParserRuleContext {
		public List<ActionContext> action() {
			return getRuleContexts(ActionContext.class);
		}
		public ActionContext action(int i) {
			return getRuleContext(ActionContext.class,i);
		}
		public ActionsContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_actions; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof StateLabelListener ) ((StateLabelListener)listener).enterActions(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof StateLabelListener ) ((StateLabelListener)listener).exitActions(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof StateLabelVisitor ) return ((StateLabelVisitor<? extends T>)visitor).visitActions(this);
			else return visitor.visitChildren(this);
		}
	}

	public final ActionsContext actions() throws RecognitionException {
		ActionsContext _localctx = new ActionsContext(_ctx, getState());
		enterRule(_localctx, 4, RULE_actions);
		int _la;
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(30); 
			_errHandler.sync(this);
			_la = _input.LA(1);
			do {
				{
				{
				setState(29);
				action();
				}
				}
				setState(32); 
				_errHandler.sync(this);
				_la = _input.LA(1);
			} while ( (((_la) & ~0x3f) == 0 && ((1L << _la) & ((1L << Entry) | (1L << During) | (1L << Exit) | (1L << Bind) | (1L << On))) != 0) );
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	public static class ActionContext extends ParserRuleContext {
		public List<ActionTypeContext> actionType() {
			return getRuleContexts(ActionTypeContext.class);
		}
		public ActionTypeContext actionType(int i) {
			return getRuleContext(ActionTypeContext.class,i);
		}
		public ActionBodyContext actionBody() {
			return getRuleContext(ActionBodyContext.class,0);
		}
		public ActionContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_action; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof StateLabelListener ) ((StateLabelListener)listener).enterAction(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof StateLabelListener ) ((StateLabelListener)listener).exitAction(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof StateLabelVisitor ) return ((StateLabelVisitor<? extends T>)visitor).visitAction(this);
			else return visitor.visitChildren(this);
		}
	}

	public final ActionContext action() throws RecognitionException {
		ActionContext _localctx = new ActionContext(_ctx, getState());
		enterRule(_localctx, 6, RULE_action);
		int _la;
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(34);
			actionType();
			setState(39);
			_errHandler.sync(this);
			_la = _input.LA(1);
			while (_la==T__3) {
				{
				{
				setState(35);
				match(T__3);
				setState(36);
				actionType();
				}
				}
				setState(41);
				_errHandler.sync(this);
				_la = _input.LA(1);
			}
			setState(42);
			match(T__4);
			setState(43);
			actionBody();
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	public static class ActionTypeContext extends ParserRuleContext {
		public TerminalNode Entry() { return getToken(StateLabelParser.Entry, 0); }
		public TerminalNode During() { return getToken(StateLabelParser.During, 0); }
		public TerminalNode Exit() { return getToken(StateLabelParser.Exit, 0); }
		public TerminalNode Bind() { return getToken(StateLabelParser.Bind, 0); }
		public TerminalNode On() { return getToken(StateLabelParser.On, 0); }
		public TerminalNode Identifier() { return getToken(StateLabelParser.Identifier, 0); }
		public TerminalNode After() { return getToken(StateLabelParser.After, 0); }
		public TerminalNode Number() { return getToken(StateLabelParser.Number, 0); }
		public TerminalNode Before() { return getToken(StateLabelParser.Before, 0); }
		public TerminalNode At() { return getToken(StateLabelParser.At, 0); }
		public TerminalNode Every() { return getToken(StateLabelParser.Every, 0); }
		public ActionTypeContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_actionType; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof StateLabelListener ) ((StateLabelListener)listener).enterActionType(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof StateLabelListener ) ((StateLabelListener)listener).exitActionType(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof StateLabelVisitor ) return ((StateLabelVisitor<? extends T>)visitor).visitActionType(this);
			else return visitor.visitChildren(this);
		}
	}

	public final ActionTypeContext actionType() throws RecognitionException {
		ActionTypeContext _localctx = new ActionTypeContext(_ctx, getState());
		enterRule(_localctx, 8, RULE_actionType);
		try {
			setState(79);
			_errHandler.sync(this);
			switch ( getInterpreter().adaptivePredict(_input,6,_ctx) ) {
			case 1:
				enterOuterAlt(_localctx, 1);
				{
				setState(45);
				match(Entry);
				}
				break;
			case 2:
				enterOuterAlt(_localctx, 2);
				{
				setState(46);
				match(During);
				}
				break;
			case 3:
				enterOuterAlt(_localctx, 3);
				{
				setState(47);
				match(Exit);
				}
				break;
			case 4:
				enterOuterAlt(_localctx, 4);
				{
				setState(48);
				match(Bind);
				}
				break;
			case 5:
				enterOuterAlt(_localctx, 5);
				{
				setState(49);
				match(On);
				setState(50);
				match(Identifier);
				}
				break;
			case 6:
				enterOuterAlt(_localctx, 6);
				{
				setState(51);
				match(On);
				setState(52);
				match(After);
				setState(53);
				match(T__5);
				setState(54);
				match(Number);
				setState(55);
				match(T__3);
				setState(56);
				match(Identifier);
				setState(57);
				match(T__6);
				}
				break;
			case 7:
				enterOuterAlt(_localctx, 7);
				{
				setState(58);
				match(On);
				setState(59);
				match(Before);
				setState(60);
				match(T__5);
				setState(61);
				match(Number);
				setState(62);
				match(T__3);
				setState(63);
				match(Identifier);
				setState(64);
				match(T__6);
				}
				break;
			case 8:
				enterOuterAlt(_localctx, 8);
				{
				setState(65);
				match(On);
				setState(66);
				match(At);
				setState(67);
				match(T__5);
				setState(68);
				match(Number);
				setState(69);
				match(T__3);
				setState(70);
				match(Identifier);
				setState(71);
				match(T__6);
				}
				break;
			case 9:
				enterOuterAlt(_localctx, 9);
				{
				setState(72);
				match(On);
				setState(73);
				match(Every);
				setState(74);
				match(T__5);
				setState(75);
				match(Number);
				setState(76);
				match(T__3);
				setState(77);
				match(Identifier);
				setState(78);
				match(T__6);
				}
				break;
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	public static class ActionBodyContext extends ParserRuleContext {
		public ActionBodyContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_actionBody; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof StateLabelListener ) ((StateLabelListener)listener).enterActionBody(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof StateLabelListener ) ((StateLabelListener)listener).exitActionBody(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof StateLabelVisitor ) return ((StateLabelVisitor<? extends T>)visitor).visitActionBody(this);
			else return visitor.visitChildren(this);
		}
	}

	public final ActionBodyContext actionBody() throws RecognitionException {
		ActionBodyContext _localctx = new ActionBodyContext(_ctx, getState());
		enterRule(_localctx, 10, RULE_actionBody);
		int _la;
		try {
			int _alt;
			enterOuterAlt(_localctx, 1);
			{
			setState(88);
			_errHandler.sync(this);
			_alt = getInterpreter().adaptivePredict(_input,9,_ctx);
			while ( _alt!=1 && _alt!=org.antlr.v4.runtime.atn.ATN.INVALID_ALT_NUMBER ) {
				if ( _alt==1+1 ) {
					{
					setState(86);
					_errHandler.sync(this);
					switch ( getInterpreter().adaptivePredict(_input,8,_ctx) ) {
					case 1:
						{
						setState(81);
						matchWildcard();
						}
						break;
					case 2:
						{
						setState(83);
						_errHandler.sync(this);
						_la = _input.LA(1);
						if (_la==T__0) {
							{
							setState(82);
							match(T__0);
							}
						}

						setState(85);
						match(T__1);
						}
						break;
					}
					} 
				}
				setState(90);
				_errHandler.sync(this);
				_alt = getInterpreter().adaptivePredict(_input,9,_ctx);
			}
			}
		}
		catch (RecognitionException re) {
			_localctx.exception = re;
			_errHandler.reportError(this, re);
			_errHandler.recover(this, re);
		}
		finally {
			exitRule();
		}
		return _localctx;
	}

	public static final String _serializedATN =
		"\3\u608b\ua72a\u8133\ub9ed\u417c\u3be7\u7786\u5964\3\33^\4\2\t\2\4\3\t"+
		"\3\4\4\t\4\4\5\t\5\4\6\t\6\4\7\t\7\3\2\3\2\5\2\21\n\2\3\2\7\2\24\n\2\f"+
		"\2\16\2\27\13\2\3\2\5\2\32\n\2\3\3\3\3\5\3\36\n\3\3\4\6\4!\n\4\r\4\16"+
		"\4\"\3\5\3\5\3\5\7\5(\n\5\f\5\16\5+\13\5\3\5\3\5\3\5\3\6\3\6\3\6\3\6\3"+
		"\6\3\6\3\6\3\6\3\6\3\6\3\6\3\6\3\6\3\6\3\6\3\6\3\6\3\6\3\6\3\6\3\6\3\6"+
		"\3\6\3\6\3\6\3\6\3\6\3\6\3\6\3\6\3\6\3\6\3\6\3\6\5\6R\n\6\3\7\3\7\5\7"+
		"V\n\7\3\7\7\7Y\n\7\f\7\16\7\\\13\7\3\7\3Z\2\b\2\4\6\b\n\f\2\2\2h\2\16"+
		"\3\2\2\2\4\33\3\2\2\2\6 \3\2\2\2\b$\3\2\2\2\nQ\3\2\2\2\fZ\3\2\2\2\16\20"+
		"\5\4\3\2\17\21\7\3\2\2\20\17\3\2\2\2\20\21\3\2\2\2\21\25\3\2\2\2\22\24"+
		"\7\4\2\2\23\22\3\2\2\2\24\27\3\2\2\2\25\23\3\2\2\2\25\26\3\2\2\2\26\31"+
		"\3\2\2\2\27\25\3\2\2\2\30\32\5\6\4\2\31\30\3\2\2\2\31\32\3\2\2\2\32\3"+
		"\3\2\2\2\33\35\7\23\2\2\34\36\7\5\2\2\35\34\3\2\2\2\35\36\3\2\2\2\36\5"+
		"\3\2\2\2\37!\5\b\5\2 \37\3\2\2\2!\"\3\2\2\2\" \3\2\2\2\"#\3\2\2\2#\7\3"+
		"\2\2\2$)\5\n\6\2%&\7\6\2\2&(\5\n\6\2\'%\3\2\2\2(+\3\2\2\2)\'\3\2\2\2)"+
		"*\3\2\2\2*,\3\2\2\2+)\3\2\2\2,-\7\7\2\2-.\5\f\7\2.\t\3\2\2\2/R\7\n\2\2"+
		"\60R\7\13\2\2\61R\7\f\2\2\62R\7\r\2\2\63\64\7\16\2\2\64R\7\23\2\2\65\66"+
		"\7\16\2\2\66\67\7\17\2\2\678\7\b\2\289\7\25\2\29:\7\6\2\2:;\7\23\2\2;"+
		"R\7\t\2\2<=\7\16\2\2=>\7\20\2\2>?\7\b\2\2?@\7\25\2\2@A\7\6\2\2AB\7\23"+
		"\2\2BR\7\t\2\2CD\7\16\2\2DE\7\21\2\2EF\7\b\2\2FG\7\25\2\2GH\7\6\2\2HI"+
		"\7\23\2\2IR\7\t\2\2JK\7\16\2\2KL\7\22\2\2LM\7\b\2\2MN\7\25\2\2NO\7\6\2"+
		"\2OP\7\23\2\2PR\7\t\2\2Q/\3\2\2\2Q\60\3\2\2\2Q\61\3\2\2\2Q\62\3\2\2\2"+
		"Q\63\3\2\2\2Q\65\3\2\2\2Q<\3\2\2\2QC\3\2\2\2QJ\3\2\2\2R\13\3\2\2\2SY\13"+
		"\2\2\2TV\7\3\2\2UT\3\2\2\2UV\3\2\2\2VW\3\2\2\2WY\7\4\2\2XS\3\2\2\2XU\3"+
		"\2\2\2Y\\\3\2\2\2Z[\3\2\2\2ZX\3\2\2\2[\r\3\2\2\2\\Z\3\2\2\2\f\20\25\31"+
		"\35\")QUXZ";
	public static final ATN _ATN =
		new ATNDeserializer().deserialize(_serializedATN.toCharArray());
	static {
		_decisionToDFA = new DFA[_ATN.getNumberOfDecisions()];
		for (int i = 0; i < _ATN.getNumberOfDecisions(); i++) {
			_decisionToDFA[i] = new DFA(_ATN.getDecisionState(i), i);
		}
	}
}