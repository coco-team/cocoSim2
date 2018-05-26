// Generated from TransitionLabel.g4 by ANTLR 4.7.1
package edu.uiowa.chart.transition.antlr;
import org.antlr.v4.runtime.atn.*;
import org.antlr.v4.runtime.dfa.DFA;
import org.antlr.v4.runtime.*;
import org.antlr.v4.runtime.misc.*;
import org.antlr.v4.runtime.tree.*;
import java.util.List;
import java.util.Iterator;
import java.util.ArrayList;

@SuppressWarnings({"all", "warnings", "unchecked", "unused", "cast"})
public class TransitionLabelParser extends Parser {
	static { RuntimeMetaData.checkVersion("4.7.1", RuntimeMetaData.VERSION); }

	protected static final DFA[] _decisionToDFA;
	protected static final PredictionContextCache _sharedContextCache =
		new PredictionContextCache();
	public static final int
		LeftSquareBracket=1, RightSquareBracket=2, LeftCurlyBracket=3, RightCurlyBracket=4, 
		Slash=5, Identifier=6, IdentifierLetter=7, Digit=8, LineComment=9, WhiteSpace=10, 
		AnyCharacter=11;
	public static final int
		RULE_transitionLabel = 0, RULE_eventOrMessage = 1, RULE_condition = 2, 
		RULE_conditionAction = 3, RULE_transitionAction = 4;
	public static final String[] ruleNames = {
		"transitionLabel", "eventOrMessage", "condition", "conditionAction", "transitionAction"
	};

	private static final String[] _LITERAL_NAMES = {
		null, "'['", "']'", "'{'", "'}'", "'/'"
	};
	private static final String[] _SYMBOLIC_NAMES = {
		null, "LeftSquareBracket", "RightSquareBracket", "LeftCurlyBracket", "RightCurlyBracket", 
		"Slash", "Identifier", "IdentifierLetter", "Digit", "LineComment", "WhiteSpace", 
		"AnyCharacter"
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
	public String getGrammarFileName() { return "TransitionLabel.g4"; }

	@Override
	public String[] getRuleNames() { return ruleNames; }

	@Override
	public String getSerializedATN() { return _serializedATN; }

	@Override
	public ATN getATN() { return _ATN; }

	public TransitionLabelParser(TokenStream input) {
		super(input);
		_interp = new ParserATNSimulator(this,_ATN,_decisionToDFA,_sharedContextCache);
	}
	public static class TransitionLabelContext extends ParserRuleContext {
		public EventOrMessageContext eventOrMessage() {
			return getRuleContext(EventOrMessageContext.class,0);
		}
		public TerminalNode LeftSquareBracket() { return getToken(TransitionLabelParser.LeftSquareBracket, 0); }
		public ConditionContext condition() {
			return getRuleContext(ConditionContext.class,0);
		}
		public TerminalNode RightSquareBracket() { return getToken(TransitionLabelParser.RightSquareBracket, 0); }
		public List<TerminalNode> LeftCurlyBracket() { return getTokens(TransitionLabelParser.LeftCurlyBracket); }
		public TerminalNode LeftCurlyBracket(int i) {
			return getToken(TransitionLabelParser.LeftCurlyBracket, i);
		}
		public ConditionActionContext conditionAction() {
			return getRuleContext(ConditionActionContext.class,0);
		}
		public List<TerminalNode> RightCurlyBracket() { return getTokens(TransitionLabelParser.RightCurlyBracket); }
		public TerminalNode RightCurlyBracket(int i) {
			return getToken(TransitionLabelParser.RightCurlyBracket, i);
		}
		public TerminalNode Slash() { return getToken(TransitionLabelParser.Slash, 0); }
		public TransitionActionContext transitionAction() {
			return getRuleContext(TransitionActionContext.class,0);
		}
		public TransitionLabelContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_transitionLabel; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof TransitionLabelListener ) ((TransitionLabelListener)listener).enterTransitionLabel(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof TransitionLabelListener ) ((TransitionLabelListener)listener).exitTransitionLabel(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof TransitionLabelVisitor ) return ((TransitionLabelVisitor<? extends T>)visitor).visitTransitionLabel(this);
			else return visitor.visitChildren(this);
		}
	}

	public final TransitionLabelContext transitionLabel() throws RecognitionException {
		TransitionLabelContext _localctx = new TransitionLabelContext(_ctx, getState());
		enterRule(_localctx, 0, RULE_transitionLabel);
		int _la;
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(11);
			_errHandler.sync(this);
			_la = _input.LA(1);
			if (_la==Identifier) {
				{
				setState(10);
				eventOrMessage();
				}
			}

			setState(17);
			_errHandler.sync(this);
			_la = _input.LA(1);
			if (_la==LeftSquareBracket) {
				{
				setState(13);
				match(LeftSquareBracket);
				setState(14);
				condition();
				setState(15);
				match(RightSquareBracket);
				}
			}

			setState(23);
			_errHandler.sync(this);
			_la = _input.LA(1);
			if (_la==LeftCurlyBracket) {
				{
				setState(19);
				match(LeftCurlyBracket);
				setState(20);
				conditionAction();
				setState(21);
				match(RightCurlyBracket);
				}
			}

			setState(30);
			_errHandler.sync(this);
			_la = _input.LA(1);
			if (_la==Slash) {
				{
				setState(25);
				match(Slash);
				setState(26);
				match(LeftCurlyBracket);
				setState(27);
				transitionAction();
				setState(28);
				match(RightCurlyBracket);
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

	public static class EventOrMessageContext extends ParserRuleContext {
		public TerminalNode Identifier() { return getToken(TransitionLabelParser.Identifier, 0); }
		public EventOrMessageContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_eventOrMessage; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof TransitionLabelListener ) ((TransitionLabelListener)listener).enterEventOrMessage(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof TransitionLabelListener ) ((TransitionLabelListener)listener).exitEventOrMessage(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof TransitionLabelVisitor ) return ((TransitionLabelVisitor<? extends T>)visitor).visitEventOrMessage(this);
			else return visitor.visitChildren(this);
		}
	}

	public final EventOrMessageContext eventOrMessage() throws RecognitionException {
		EventOrMessageContext _localctx = new EventOrMessageContext(_ctx, getState());
		enterRule(_localctx, 2, RULE_eventOrMessage);
		try {
			enterOuterAlt(_localctx, 1);
			{
			setState(32);
			match(Identifier);
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

	public static class ConditionContext extends ParserRuleContext {
		public ConditionContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_condition; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof TransitionLabelListener ) ((TransitionLabelListener)listener).enterCondition(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof TransitionLabelListener ) ((TransitionLabelListener)listener).exitCondition(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof TransitionLabelVisitor ) return ((TransitionLabelVisitor<? extends T>)visitor).visitCondition(this);
			else return visitor.visitChildren(this);
		}
	}

	public final ConditionContext condition() throws RecognitionException {
		ConditionContext _localctx = new ConditionContext(_ctx, getState());
		enterRule(_localctx, 4, RULE_condition);
		try {
			int _alt;
			enterOuterAlt(_localctx, 1);
			{
			setState(37);
			_errHandler.sync(this);
			_alt = getInterpreter().adaptivePredict(_input,4,_ctx);
			while ( _alt!=1 && _alt!=org.antlr.v4.runtime.atn.ATN.INVALID_ALT_NUMBER ) {
				if ( _alt==1+1 ) {
					{
					{
					setState(34);
					matchWildcard();
					}
					} 
				}
				setState(39);
				_errHandler.sync(this);
				_alt = getInterpreter().adaptivePredict(_input,4,_ctx);
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

	public static class ConditionActionContext extends ParserRuleContext {
		public ConditionActionContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_conditionAction; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof TransitionLabelListener ) ((TransitionLabelListener)listener).enterConditionAction(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof TransitionLabelListener ) ((TransitionLabelListener)listener).exitConditionAction(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof TransitionLabelVisitor ) return ((TransitionLabelVisitor<? extends T>)visitor).visitConditionAction(this);
			else return visitor.visitChildren(this);
		}
	}

	public final ConditionActionContext conditionAction() throws RecognitionException {
		ConditionActionContext _localctx = new ConditionActionContext(_ctx, getState());
		enterRule(_localctx, 6, RULE_conditionAction);
		try {
			int _alt;
			enterOuterAlt(_localctx, 1);
			{
			setState(43);
			_errHandler.sync(this);
			_alt = getInterpreter().adaptivePredict(_input,5,_ctx);
			while ( _alt!=1 && _alt!=org.antlr.v4.runtime.atn.ATN.INVALID_ALT_NUMBER ) {
				if ( _alt==1+1 ) {
					{
					{
					setState(40);
					matchWildcard();
					}
					} 
				}
				setState(45);
				_errHandler.sync(this);
				_alt = getInterpreter().adaptivePredict(_input,5,_ctx);
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

	public static class TransitionActionContext extends ParserRuleContext {
		public TransitionActionContext(ParserRuleContext parent, int invokingState) {
			super(parent, invokingState);
		}
		@Override public int getRuleIndex() { return RULE_transitionAction; }
		@Override
		public void enterRule(ParseTreeListener listener) {
			if ( listener instanceof TransitionLabelListener ) ((TransitionLabelListener)listener).enterTransitionAction(this);
		}
		@Override
		public void exitRule(ParseTreeListener listener) {
			if ( listener instanceof TransitionLabelListener ) ((TransitionLabelListener)listener).exitTransitionAction(this);
		}
		@Override
		public <T> T accept(ParseTreeVisitor<? extends T> visitor) {
			if ( visitor instanceof TransitionLabelVisitor ) return ((TransitionLabelVisitor<? extends T>)visitor).visitTransitionAction(this);
			else return visitor.visitChildren(this);
		}
	}

	public final TransitionActionContext transitionAction() throws RecognitionException {
		TransitionActionContext _localctx = new TransitionActionContext(_ctx, getState());
		enterRule(_localctx, 8, RULE_transitionAction);
		try {
			int _alt;
			enterOuterAlt(_localctx, 1);
			{
			setState(49);
			_errHandler.sync(this);
			_alt = getInterpreter().adaptivePredict(_input,6,_ctx);
			while ( _alt!=1 && _alt!=org.antlr.v4.runtime.atn.ATN.INVALID_ALT_NUMBER ) {
				if ( _alt==1+1 ) {
					{
					{
					setState(46);
					matchWildcard();
					}
					} 
				}
				setState(51);
				_errHandler.sync(this);
				_alt = getInterpreter().adaptivePredict(_input,6,_ctx);
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
		"\3\u608b\ua72a\u8133\ub9ed\u417c\u3be7\u7786\u5964\3\r\67\4\2\t\2\4\3"+
		"\t\3\4\4\t\4\4\5\t\5\4\6\t\6\3\2\5\2\16\n\2\3\2\3\2\3\2\3\2\5\2\24\n\2"+
		"\3\2\3\2\3\2\3\2\5\2\32\n\2\3\2\3\2\3\2\3\2\3\2\5\2!\n\2\3\3\3\3\3\4\7"+
		"\4&\n\4\f\4\16\4)\13\4\3\5\7\5,\n\5\f\5\16\5/\13\5\3\6\7\6\62\n\6\f\6"+
		"\16\6\65\13\6\3\6\5\'-\63\2\7\2\4\6\b\n\2\2\28\2\r\3\2\2\2\4\"\3\2\2\2"+
		"\6\'\3\2\2\2\b-\3\2\2\2\n\63\3\2\2\2\f\16\5\4\3\2\r\f\3\2\2\2\r\16\3\2"+
		"\2\2\16\23\3\2\2\2\17\20\7\3\2\2\20\21\5\6\4\2\21\22\7\4\2\2\22\24\3\2"+
		"\2\2\23\17\3\2\2\2\23\24\3\2\2\2\24\31\3\2\2\2\25\26\7\5\2\2\26\27\5\b"+
		"\5\2\27\30\7\6\2\2\30\32\3\2\2\2\31\25\3\2\2\2\31\32\3\2\2\2\32 \3\2\2"+
		"\2\33\34\7\7\2\2\34\35\7\5\2\2\35\36\5\n\6\2\36\37\7\6\2\2\37!\3\2\2\2"+
		" \33\3\2\2\2 !\3\2\2\2!\3\3\2\2\2\"#\7\b\2\2#\5\3\2\2\2$&\13\2\2\2%$\3"+
		"\2\2\2&)\3\2\2\2\'(\3\2\2\2\'%\3\2\2\2(\7\3\2\2\2)\'\3\2\2\2*,\13\2\2"+
		"\2+*\3\2\2\2,/\3\2\2\2-.\3\2\2\2-+\3\2\2\2.\t\3\2\2\2/-\3\2\2\2\60\62"+
		"\13\2\2\2\61\60\3\2\2\2\62\65\3\2\2\2\63\64\3\2\2\2\63\61\3\2\2\2\64\13"+
		"\3\2\2\2\65\63\3\2\2\2\t\r\23\31 \'-\63";
	public static final ATN _ATN =
		new ATNDeserializer().deserialize(_serializedATN.toCharArray());
	static {
		_decisionToDFA = new DFA[_ATN.getNumberOfDecisions()];
		for (int i = 0; i < _ATN.getNumberOfDecisions(); i++) {
			_decisionToDFA[i] = new DFA(_ATN.getDecisionState(i), i);
		}
	}
}