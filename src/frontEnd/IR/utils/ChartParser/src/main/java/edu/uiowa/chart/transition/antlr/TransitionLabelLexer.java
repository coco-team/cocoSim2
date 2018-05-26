// Generated from TransitionLabel.g4 by ANTLR 4.7.1
package edu.uiowa.chart.transition.antlr;
import org.antlr.v4.runtime.Lexer;
import org.antlr.v4.runtime.CharStream;
import org.antlr.v4.runtime.Token;
import org.antlr.v4.runtime.TokenStream;
import org.antlr.v4.runtime.*;
import org.antlr.v4.runtime.atn.*;
import org.antlr.v4.runtime.dfa.DFA;
import org.antlr.v4.runtime.misc.*;

@SuppressWarnings({"all", "warnings", "unchecked", "unused", "cast"})
public class TransitionLabelLexer extends Lexer {
	static { RuntimeMetaData.checkVersion("4.7.1", RuntimeMetaData.VERSION); }

	protected static final DFA[] _decisionToDFA;
	protected static final PredictionContextCache _sharedContextCache =
		new PredictionContextCache();
	public static final int
		LeftSquareBracket=1, RightSquareBracket=2, LeftCurlyBracket=3, RightCurlyBracket=4, 
		Slash=5, Identifier=6, IdentifierLetter=7, Digit=8, LineComment=9, WhiteSpace=10, 
		AnyCharacter=11;
	public static String[] channelNames = {
		"DEFAULT_TOKEN_CHANNEL", "HIDDEN"
	};

	public static String[] modeNames = {
		"DEFAULT_MODE"
	};

	public static final String[] ruleNames = {
		"LeftSquareBracket", "RightSquareBracket", "LeftCurlyBracket", "RightCurlyBracket", 
		"Slash", "Identifier", "IdentifierLetter", "Digit", "LineComment", "WhiteSpace", 
		"AnyCharacter"
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


	public TransitionLabelLexer(CharStream input) {
		super(input);
		_interp = new LexerATNSimulator(this,_ATN,_decisionToDFA,_sharedContextCache);
	}

	@Override
	public String getGrammarFileName() { return "TransitionLabel.g4"; }

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
		"\3\u608b\ua72a\u8133\ub9ed\u417c\u3be7\u7786\u5964\2\rC\b\1\4\2\t\2\4"+
		"\3\t\3\4\4\t\4\4\5\t\5\4\6\t\6\4\7\t\7\4\b\t\b\4\t\t\t\4\n\t\n\4\13\t"+
		"\13\4\f\t\f\3\2\3\2\3\3\3\3\3\4\3\4\3\5\3\5\3\6\3\6\3\7\3\7\3\7\7\7\'"+
		"\n\7\f\7\16\7*\13\7\3\b\3\b\3\t\3\t\3\n\3\n\7\n\62\n\n\f\n\16\n\65\13"+
		"\n\3\n\3\n\3\n\3\n\3\13\6\13<\n\13\r\13\16\13=\3\13\3\13\3\f\3\f\3\63"+
		"\2\r\3\3\5\4\7\5\t\6\13\7\r\b\17\t\21\n\23\13\25\f\27\r\3\2\4\5\2C\\a"+
		"ac|\5\2\13\13\17\17\"\"\2F\2\3\3\2\2\2\2\5\3\2\2\2\2\7\3\2\2\2\2\t\3\2"+
		"\2\2\2\13\3\2\2\2\2\r\3\2\2\2\2\17\3\2\2\2\2\21\3\2\2\2\2\23\3\2\2\2\2"+
		"\25\3\2\2\2\2\27\3\2\2\2\3\31\3\2\2\2\5\33\3\2\2\2\7\35\3\2\2\2\t\37\3"+
		"\2\2\2\13!\3\2\2\2\r#\3\2\2\2\17+\3\2\2\2\21-\3\2\2\2\23/\3\2\2\2\25;"+
		"\3\2\2\2\27A\3\2\2\2\31\32\7]\2\2\32\4\3\2\2\2\33\34\7_\2\2\34\6\3\2\2"+
		"\2\35\36\7}\2\2\36\b\3\2\2\2\37 \7\177\2\2 \n\3\2\2\2!\"\7\61\2\2\"\f"+
		"\3\2\2\2#(\5\17\b\2$\'\5\17\b\2%\'\5\21\t\2&$\3\2\2\2&%\3\2\2\2\'*\3\2"+
		"\2\2(&\3\2\2\2()\3\2\2\2)\16\3\2\2\2*(\3\2\2\2+,\t\2\2\2,\20\3\2\2\2-"+
		".\4\62;\2.\22\3\2\2\2/\63\7\'\2\2\60\62\13\2\2\2\61\60\3\2\2\2\62\65\3"+
		"\2\2\2\63\64\3\2\2\2\63\61\3\2\2\2\64\66\3\2\2\2\65\63\3\2\2\2\66\67\7"+
		"\f\2\2\678\3\2\2\289\b\n\2\29\24\3\2\2\2:<\t\3\2\2;:\3\2\2\2<=\3\2\2\2"+
		"=;\3\2\2\2=>\3\2\2\2>?\3\2\2\2?@\b\13\2\2@\26\3\2\2\2AB\13\2\2\2B\30\3"+
		"\2\2\2\7\2&(\63=\3\b\2\2";
	public static final ATN _ATN =
		new ATNDeserializer().deserialize(_serializedATN.toCharArray());
	static {
		_decisionToDFA = new DFA[_ATN.getNumberOfDecisions()];
		for (int i = 0; i < _ATN.getNumberOfDecisions(); i++) {
			_decisionToDFA[i] = new DFA(_ATN.getDecisionState(i), i);
		}
	}
}