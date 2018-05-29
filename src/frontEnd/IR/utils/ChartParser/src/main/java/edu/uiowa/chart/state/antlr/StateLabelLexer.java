// Generated from StateLabel.g4 by ANTLR 4.7.1
package edu.uiowa.chart.state.antlr;
import org.antlr.v4.runtime.Lexer;
import org.antlr.v4.runtime.CharStream;
import org.antlr.v4.runtime.Token;
import org.antlr.v4.runtime.TokenStream;
import org.antlr.v4.runtime.*;
import org.antlr.v4.runtime.atn.*;
import org.antlr.v4.runtime.dfa.DFA;
import org.antlr.v4.runtime.misc.*;

@SuppressWarnings({"all", "warnings", "unchecked", "unused", "cast"})
public class StateLabelLexer extends Lexer {
	static { RuntimeMetaData.checkVersion("4.7.1", RuntimeMetaData.VERSION); }

	protected static final DFA[] _decisionToDFA;
	protected static final PredictionContextCache _sharedContextCache =
		new PredictionContextCache();
	public static final int
		T__0=1, T__1=2, T__2=3, T__3=4, T__4=5, T__5=6, Entry=7, During=8, Exit=9, 
		Bind=10, On=11, After=12, Before=13, At=14, Every=15, Identifier=16, IdentifierLetter=17, 
		Number=18, Integer=19, Float=20, Digit=21, LineComment=22, WhiteSpace=23, 
		AnyCharacter=24;
	public static String[] channelNames = {
		"DEFAULT_TOKEN_CHANNEL", "HIDDEN"
	};

	public static String[] modeNames = {
		"DEFAULT_MODE"
	};

	public static final String[] ruleNames = {
		"T__0", "T__1", "T__2", "T__3", "T__4", "T__5", "Entry", "During", "Exit", 
		"Bind", "On", "After", "Before", "At", "Every", "Identifier", "IdentifierLetter", 
		"Number", "Integer", "Float", "Digit", "LineComment", "WhiteSpace", "AnyCharacter"
	};

	private static final String[] _LITERAL_NAMES = {
		null, "'\r'", "'\n'", "','", "':'", "'('", "')'", null, null, null, "'bind'", 
		"'on'", "'after'", "'before'", "'at'", "'every'"
	};
	private static final String[] _SYMBOLIC_NAMES = {
		null, null, null, null, null, null, null, "Entry", "During", "Exit", "Bind", 
		"On", "After", "Before", "At", "Every", "Identifier", "IdentifierLetter", 
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


	public StateLabelLexer(CharStream input) {
		super(input);
		_interp = new LexerATNSimulator(this,_ATN,_decisionToDFA,_sharedContextCache);
	}

	@Override
	public String getGrammarFileName() { return "StateLabel.g4"; }

	@Override
	public String[] getRuleNames() { return ruleNames; }

	@Override
	public String getSerializedATN() { return _serializedATN; }

	@Override
	public String[] getChannelNames() { return channelNames; }

	@Override
	public String[] getModeNames() { return modeNames; }

	@Override
	public ATN getATN() { return _ATN; }

	public static final String _serializedATN =
		"\3\u608b\ua72a\u8133\ub9ed\u417c\u3be7\u7786\u5964\2\32\u00b5\b\1\4\2"+
		"\t\2\4\3\t\3\4\4\t\4\4\5\t\5\4\6\t\6\4\7\t\7\4\b\t\b\4\t\t\t\4\n\t\n\4"+
		"\13\t\13\4\f\t\f\4\r\t\r\4\16\t\16\4\17\t\17\4\20\t\20\4\21\t\21\4\22"+
		"\t\22\4\23\t\23\4\24\t\24\4\25\t\25\4\26\t\26\4\27\t\27\4\30\t\30\4\31"+
		"\t\31\3\2\3\2\3\3\3\3\3\4\3\4\3\5\3\5\3\6\3\6\3\7\3\7\3\b\3\b\3\b\3\b"+
		"\3\b\3\b\3\b\5\bG\n\b\3\t\3\t\3\t\3\t\3\t\3\t\3\t\3\t\5\tQ\n\t\3\n\3\n"+
		"\3\n\3\n\3\n\3\n\5\nY\n\n\3\13\3\13\3\13\3\13\3\13\3\f\3\f\3\f\3\r\3\r"+
		"\3\r\3\r\3\r\3\r\3\16\3\16\3\16\3\16\3\16\3\16\3\16\3\17\3\17\3\17\3\20"+
		"\3\20\3\20\3\20\3\20\3\20\3\21\3\21\3\21\7\21|\n\21\f\21\16\21\177\13"+
		"\21\3\22\3\22\3\23\3\23\5\23\u0085\n\23\3\24\6\24\u0088\n\24\r\24\16\24"+
		"\u0089\3\25\6\25\u008d\n\25\r\25\16\25\u008e\3\25\3\25\7\25\u0093\n\25"+
		"\f\25\16\25\u0096\13\25\3\25\3\25\6\25\u009a\n\25\r\25\16\25\u009b\5\25"+
		"\u009e\n\25\3\26\3\26\3\27\3\27\7\27\u00a4\n\27\f\27\16\27\u00a7\13\27"+
		"\3\27\3\27\3\27\3\27\3\30\6\30\u00ae\n\30\r\30\16\30\u00af\3\30\3\30\3"+
		"\31\3\31\3\u00a5\2\32\3\3\5\4\7\5\t\6\13\7\r\b\17\t\21\n\23\13\25\f\27"+
		"\r\31\16\33\17\35\20\37\21!\22#\23%\24\'\25)\26+\27-\30/\31\61\32\3\2"+
		"\4\5\2C\\aac|\5\2\13\13\17\17\"\"\2\u00c1\2\3\3\2\2\2\2\5\3\2\2\2\2\7"+
		"\3\2\2\2\2\t\3\2\2\2\2\13\3\2\2\2\2\r\3\2\2\2\2\17\3\2\2\2\2\21\3\2\2"+
		"\2\2\23\3\2\2\2\2\25\3\2\2\2\2\27\3\2\2\2\2\31\3\2\2\2\2\33\3\2\2\2\2"+
		"\35\3\2\2\2\2\37\3\2\2\2\2!\3\2\2\2\2#\3\2\2\2\2%\3\2\2\2\2\'\3\2\2\2"+
		"\2)\3\2\2\2\2+\3\2\2\2\2-\3\2\2\2\2/\3\2\2\2\2\61\3\2\2\2\3\63\3\2\2\2"+
		"\5\65\3\2\2\2\7\67\3\2\2\2\t9\3\2\2\2\13;\3\2\2\2\r=\3\2\2\2\17F\3\2\2"+
		"\2\21P\3\2\2\2\23X\3\2\2\2\25Z\3\2\2\2\27_\3\2\2\2\31b\3\2\2\2\33h\3\2"+
		"\2\2\35o\3\2\2\2\37r\3\2\2\2!x\3\2\2\2#\u0080\3\2\2\2%\u0084\3\2\2\2\'"+
		"\u0087\3\2\2\2)\u009d\3\2\2\2+\u009f\3\2\2\2-\u00a1\3\2\2\2/\u00ad\3\2"+
		"\2\2\61\u00b3\3\2\2\2\63\64\7\17\2\2\64\4\3\2\2\2\65\66\7\f\2\2\66\6\3"+
		"\2\2\2\678\7.\2\28\b\3\2\2\29:\7<\2\2:\n\3\2\2\2;<\7*\2\2<\f\3\2\2\2="+
		">\7+\2\2>\16\3\2\2\2?@\7g\2\2@A\7p\2\2AB\7v\2\2BC\7t\2\2CG\7{\2\2DE\7"+
		"g\2\2EG\7p\2\2F?\3\2\2\2FD\3\2\2\2G\20\3\2\2\2HI\7f\2\2IJ\7w\2\2JK\7t"+
		"\2\2KL\7k\2\2LM\7p\2\2MQ\7i\2\2NO\7f\2\2OQ\7w\2\2PH\3\2\2\2PN\3\2\2\2"+
		"Q\22\3\2\2\2RS\7g\2\2ST\7z\2\2TU\7k\2\2UY\7v\2\2VW\7g\2\2WY\7z\2\2XR\3"+
		"\2\2\2XV\3\2\2\2Y\24\3\2\2\2Z[\7d\2\2[\\\7k\2\2\\]\7p\2\2]^\7f\2\2^\26"+
		"\3\2\2\2_`\7q\2\2`a\7p\2\2a\30\3\2\2\2bc\7c\2\2cd\7h\2\2de\7v\2\2ef\7"+
		"g\2\2fg\7t\2\2g\32\3\2\2\2hi\7d\2\2ij\7g\2\2jk\7h\2\2kl\7q\2\2lm\7t\2"+
		"\2mn\7g\2\2n\34\3\2\2\2op\7c\2\2pq\7v\2\2q\36\3\2\2\2rs\7g\2\2st\7x\2"+
		"\2tu\7g\2\2uv\7t\2\2vw\7{\2\2w \3\2\2\2x}\5#\22\2y|\5#\22\2z|\5+\26\2"+
		"{y\3\2\2\2{z\3\2\2\2|\177\3\2\2\2}{\3\2\2\2}~\3\2\2\2~\"\3\2\2\2\177}"+
		"\3\2\2\2\u0080\u0081\t\2\2\2\u0081$\3\2\2\2\u0082\u0085\5\'\24\2\u0083"+
		"\u0085\5)\25\2\u0084\u0082\3\2\2\2\u0084\u0083\3\2\2\2\u0085&\3\2\2\2"+
		"\u0086\u0088\5+\26\2\u0087\u0086\3\2\2\2\u0088\u0089\3\2\2\2\u0089\u0087"+
		"\3\2\2\2\u0089\u008a\3\2\2\2\u008a(\3\2\2\2\u008b\u008d\5+\26\2\u008c"+
		"\u008b\3\2\2\2\u008d\u008e\3\2\2\2\u008e\u008c\3\2\2\2\u008e\u008f\3\2"+
		"\2\2\u008f\u0090\3\2\2\2\u0090\u0094\7\60\2\2\u0091\u0093\5+\26\2\u0092"+
		"\u0091\3\2\2\2\u0093\u0096\3\2\2\2\u0094\u0092\3\2\2\2\u0094\u0095\3\2"+
		"\2\2\u0095\u009e\3\2\2\2\u0096\u0094\3\2\2\2\u0097\u0099\7\60\2\2\u0098"+
		"\u009a\5+\26\2\u0099\u0098\3\2\2\2\u009a\u009b\3\2\2\2\u009b\u0099\3\2"+
		"\2\2\u009b\u009c\3\2\2\2\u009c\u009e\3\2\2\2\u009d\u008c\3\2\2\2\u009d"+
		"\u0097\3\2\2\2\u009e*\3\2\2\2\u009f\u00a0\4\62;\2\u00a0,\3\2\2\2\u00a1"+
		"\u00a5\7\'\2\2\u00a2\u00a4\13\2\2\2\u00a3\u00a2\3\2\2\2\u00a4\u00a7\3"+
		"\2\2\2\u00a5\u00a6\3\2\2\2\u00a5\u00a3\3\2\2\2\u00a6\u00a8\3\2\2\2\u00a7"+
		"\u00a5\3\2\2\2\u00a8\u00a9\7\f\2\2\u00a9\u00aa\3\2\2\2\u00aa\u00ab\b\27"+
		"\2\2\u00ab.\3\2\2\2\u00ac\u00ae\t\3\2\2\u00ad\u00ac\3\2\2\2\u00ae\u00af"+
		"\3\2\2\2\u00af\u00ad\3\2\2\2\u00af\u00b0\3\2\2\2\u00b0\u00b1\3\2\2\2\u00b1"+
		"\u00b2\b\30\2\2\u00b2\60\3\2\2\2\u00b3\u00b4\13\2\2\2\u00b4\62\3\2\2\2"+
		"\20\2FPX{}\u0084\u0089\u008e\u0094\u009b\u009d\u00a5\u00af\3\b\2\2";
	public static final ATN _ATN =
		new ATNDeserializer().deserialize(_serializedATN.toCharArray());
	static {
		_decisionToDFA = new DFA[_ATN.getNumberOfDecisions()];
		for (int i = 0; i < _ATN.getNumberOfDecisions(); i++) {
			_decisionToDFA[i] = new DFA(_ATN.getDecisionState(i), i);
		}
	}
}